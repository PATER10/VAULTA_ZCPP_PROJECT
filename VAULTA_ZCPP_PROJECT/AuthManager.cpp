#include "AuthManager.h"
#include <string>
#include <iostream>
#include <random>
#include <bcrypt.h>
#include <QDate>
#include <sstream>
#include <iomanip>

using namespace std;

//generate a unique card number
string AuthManager::generateCardNumber()
{
	random_device rd;
	mt19937 gen(rd());
	uniform_int_distribution<long long> dis(10000000LL, 99999999LL);
	long long number = dis(gen);
	return to_string(number);
}

//generate account number
string AuthManager::generateAccountNumber(int id)
{
	ostringstream oss;
	oss << "PL" << setw(8) << setfill('0') << id;
	return oss.str();
}

AuthManager::AuthManager(QObject* parent)
{
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

	query.prepare("INSERT INTO users (password, name, surname, role) VALUES (:pass, :name, :surname, :role) RETURNING id");

	query.bindValue(":pass", QString::fromStdString(hashedPassword));
	query.bindValue(":name", name);
	query.bindValue(":surname",surname);
	query.bindValue(":role", QStringLiteral("user"));

	if (!query.exec() || !query.next()) {
		db.rollback();
		return result;
	}

	userId = query.value(0).toInt();

	cardNumber = generateCardNumber();
	accountNumber = generateAccountNumber(userId);

	query.prepare("INSERT INTO accounts (user_id, account_number, balance, currency, account_type) VALUES (:uid, :accNo, :bal, :curr, :type) RETURNING id");

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

	query.prepare("INSERT INTO cards (account_id, card_number, pin, expiry_date) VALUES (:accId, :cardNo, :pin, :expiry)");

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

	query.prepare("SELECT name, surname, password, role FROM users WHERE id= :login");
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
		result["role"] = qRole;
		result["initials"] = qInitials;
	}

	return result;
}

Q_INVOKABLE void AuthManager::logout(){
	m_currentUserId = -1;
}
