#pragma once
#include <QObject>
#include <QString>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <string>
#include "User.h"

class AuthManager : public QObject {
	Q_OBJECT
public:
	std::string generateCardNumber();
	std::string generateAccountNumber(int id);

	explicit AuthManager(QObject* parent = nullptr);
	~AuthManager();

	Q_INVOKABLE QVariantMap registerUser(QString name, QString surname, QString password, QString pin);

	//login is the same like userId
	Q_INVOKABLE QVariantMap loginUser(int login, QString password);

	Q_INVOKABLE void logout();
	Q_INVOKABLE int currentUserId() const { return m_currentUserId; }
	Q_INVOKABLE bool isLoggedIn() const { return m_currentUserId != -1; }

private: 
	int m_currentUserId = -1;
	User* m_currentUser;

};
