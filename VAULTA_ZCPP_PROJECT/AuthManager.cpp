#include "AuthManager.h"
#include "StandardAccount.h"
#include "Card.h"
#include <string>
#include <iostream>
#include <random>
#include <bcrypt.h>
#include <QDate>
#include <sstream>
#include <iomanip>

using namespace std;

AuthManager::AuthManager(QObject* parent)
{
	m_currentUser = nullptr;
}

AuthManager::~AuthManager()
{
	if (m_currentUser) delete m_currentUser;
}

//register new user account
Q_INVOKABLE QVariantMap AuthManager::registerUser(QString name, QString surname, QString password, QString pin)
{
	QVariantMap result;
	result["success"] = false;

	if (name.length() < 1 || surname.length() < 1 || password.length() < 5 || pin.length() != 4) {;
		return result;
	}

	QSqlDatabase db = QSqlDatabase::database();
	if (!db.transaction()) return result;

	QSqlQuery query;

	int userId;
	string cardNumber, accountNumber, hashedPassword, hashedPin;
	hashedPassword = bcrypt::generateHash(password.toStdString(), 5);
	hashedPin = bcrypt::generateHash(pin.toStdString(), 4);

	query.prepare("INSERT INTO \"user\" (password, name, surname, role) VALUES(:pass, :name, :surname, :role) RETURNING id");

	query.bindValue(":pass", QString::fromStdString(hashedPassword));
	query.bindValue(":name", name);
	query.bindValue(":surname",surname);
	query.bindValue(":role", QStringLiteral("user"));

	if (!query.exec() || !query.next()) {
		db.rollback();
		return result;
	}

	userId = query.value(0).toInt();

	cardNumber = Card::generateCardNumber();
	accountNumber = StandardAccount::generateAccountNumber(userId);

	query.prepare("INSERT INTO account (user_id, account_number, balance, currency, account_type) VALUES (:uid, :accNo, :bal, :curr, :type) RETURNING id");

	query.bindValue(":uid",userId);
	query.bindValue(":accNo", QString::fromStdString(accountNumber));
	query.bindValue(":bal", 0.00);
	query.bindValue(":curr", QStringLiteral("PLN"));
	query.bindValue(":type", QStringLiteral("Standard Account"));

	if (!query.exec() || !query.next()) {
		db.rollback();
		return result;
	}

	int accId = query.value(0).toInt();

	query.prepare("INSERT INTO card (account_id, card_number, pin, expiry_date) VALUES (:accId, :cardNo, :pin, :expiry)");

	query.bindValue(":accId", accId);
	query.bindValue(":cardNo", QString::fromStdString(cardNumber));
	query.bindValue(":pin", QString::fromStdString(hashedPin));
	query.bindValue(":expiry", QDate::currentDate().addYears(4));

	if (!query.exec()) {
		db.rollback();
		return result;
	}

	if (db.commit()) {
		result["success"] = true;
		result["userId"] = userId;
		result["accountNumber"] = QString::fromStdString(accountNumber);
		result["cardNumber"] = QString::fromStdString(cardNumber);
	}
	return result;
}

//login is the same like userId
Q_INVOKABLE QVariantMap AuthManager::loginUser(int login, QString password)
{
	QVariantMap result;
	result["success"] = false;

	if (login < 1 || password.length() < 5) {
		return result;
	}
	
	QSqlDatabase db = QSqlDatabase::database();
	QSqlQuery query;

	query.prepare("SELECT name, surname, password, role FROM \"user\" WHERE id= :login");
	query.bindValue(":login", login);

	if (!query.exec() || !query.next()) {
		qDebug() << query.lastError();
		return result;
	}

	QString qName = query.value(0).toString();
	QString qSurname = query.value(1).toString();
	QString qPass = query.value(2).toString();
	QString qRole = query.value(3).toString();
	QString qInitials = qName.left(1) + qSurname.left(1);

	if (bcrypt::validatePassword(password.toStdString(), qPass.toStdString())) {
		m_currentUserId = login;
		result["success"]=true;
		result["name"] = qName;
		result["surname"] = qSurname;
		result["initials"] = qInitials;

		if (m_currentUser) {
			delete m_currentUser;
		}

		m_currentUser = new User(
			login,
			qName.toStdString(),
			qSurname.toStdString(),
			qRole.toStdString(),
			qPass.toStdString()
		);
	}

	return result;
}

Q_INVOKABLE void AuthManager::logout(){
	m_currentUserId = -1;
	if (m_currentUser) {
		delete m_currentUser;
		m_currentUser = nullptr;
	}
}
