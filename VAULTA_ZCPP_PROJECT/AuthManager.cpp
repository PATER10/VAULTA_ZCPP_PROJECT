#include "AuthManager.h"
#include "StandardAccount.h"
#include "Card.h"
#include "CurrencyAccount.h"
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

User* AuthManager::currentUser() const
{
	return m_currentUser;
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
	qDebug() <<"admin123(zahashowane): " << QString::fromStdString(bcrypt::generateHash("admin123", 5));
	QVariantMap result;
	result["success"] = false;

	if (login < 1 || password.length() < 5) {
		result["message"] = "Invalid login or password";
		return result;
	}

	QSqlQuery query;
	query.prepare("SELECT password, role, is_active FROM \"user\" WHERE id = :login");
	query.bindValue(":login", login);

	if (!query.exec()) {
		qDebug() << "Login query error:" << query.lastError().text();
		result["message"] = "Database error";
		return result;
	}

	if (!query.next()) {
		result["message"] = "Invalid login or password";
		return result;
	}

	QString hashedPass = query.value("password").toString();
	QString role = query.value("role").toString();
	bool isActive = query.value("is_active").toBool();

	if (!isActive) {
		result["message"] = "Account is inactive. Please contact with the Bank admin.";
		return result;
	}

	if (!bcrypt::validatePassword(password.toStdString(), hashedPass.toStdString())) {
		result["message"] = "Invalid login or password";
		return result;
	}

	if (!loadUserData(login)) {
		result["message"] = "Cannot load user data";
		return result;
	}

	result["success"] = true;
	result["role"] = role;
	result["message"] = "Login successful";

	return result;
}

Q_INVOKABLE void AuthManager::logout() {
	m_currentUserId = -1;
	if (m_currentUser) {
		delete m_currentUser;
		m_currentUser = nullptr;
	}
}


Q_INVOKABLE bool AuthManager::loginCard(QString cardNumber, QString pin)
{
	QSqlQuery query;
	query.prepare("SELECT a.user_id, c.pin FROM card c "
		"JOIN account a ON c.account_id = a.id "
		"WHERE c.card_number = :cardNum");
	query.bindValue(":cardNum", cardNumber);

	if (query.exec() && query.next()) {
		int userId = query.value(0).toInt();
		QString hashedPin = query.value(1).toString();

		if (bcrypt::validatePassword(pin.toStdString(), hashedPin.toStdString())) {
			return loadUserData(userId);
		}
	}
	return false;
}

Q_INVOKABLE bool AuthManager::loadUserData(int login)
{
	QSqlDatabase db = QSqlDatabase::database();
	QSqlQuery query;

	query.prepare("SELECT name, surname, password, role FROM \"user\" WHERE id= :login");
	query.bindValue(":login", login);

	if (!query.exec() || !query.next()) return false;

	QString qName = query.value(0).toString();
	QString qSurname = query.value(1).toString();
	QString qPass = query.value(2).toString();
	QString qRole = query.value(3).toString();

	m_currentUserId = login;
	if (m_currentUser) delete m_currentUser;
	m_currentUser = new User(login, qName, qSurname, qRole, qPass);
	emit userChanged();

	query.prepare("SELECT id, account_number, balance, currency, account_type FROM account WHERE user_id= :uid");
	query.bindValue(":uid", login);

	if (query.exec()) {
		while (query.next()) {
			int qAccountId = query.value(0).toInt();
			QString qAccNumber = query.value(1).toString();
			double qBalance = query.value(2).toDouble();
			QString qCurrency = query.value(3).toString();
			QString qAccType = query.value(4).toString();

			Account* account = nullptr;

			if (qCurrency == "PLN") {
				account = new StandardAccount(login, qAccNumber, qBalance, qCurrency, qAccType);
			}
			else {
				account = new CurrencyAccount(login, qAccNumber, qBalance, qCurrency, qAccType);
			}
			m_currentUser->addAccount(account);

			QSqlQuery cardQuery(db);
			
			cardQuery.prepare(
				"SELECT c.account_id, c.card_number, c.pin, c.expiry_date "
				"FROM card c "
				"JOIN account a ON c.account_id = a.id "
				"WHERE a.user_id = :uid AND a.currency = 'PLN' "
				"LIMIT 1");
			cardQuery.bindValue(":uid", login);

			if (cardQuery.exec() && cardQuery.next()) {
				QString qCardNumber = cardQuery.value(1).toString();
				QString qPin = cardQuery.value(2).toString();
				QString qExpiryDate = cardQuery.value(3).toDate().toString();

				if (m_currentCard) delete m_currentCard;
				m_currentCard = new Card(qAccountId, qCardNumber, qPin, qExpiryDate);
				m_currentUser->setCard(m_currentCard);
			}
		}
	}
	return true;
}
