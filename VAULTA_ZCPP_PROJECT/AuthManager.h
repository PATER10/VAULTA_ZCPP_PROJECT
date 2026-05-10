#pragma once
#include <QObject>
#include <QString>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <string>
#include "User.h"
#include "Account.h"

class AuthManager : public QObject {
	Q_OBJECT
	Q_PROPERTY(User* currentUser READ currentUser NOTIFY userChanged)
public:
	User* currentUser() const;

	explicit AuthManager(QObject* parent = nullptr);
	~AuthManager();

	Q_INVOKABLE QVariantMap registerUser(QString name, QString surname, QString password, QString pin);

	//login is the same like userId
	Q_INVOKABLE QVariantMap loginUser(int login, QString password);

	Q_INVOKABLE void logout();
	Q_INVOKABLE int currentUserId() const { return m_currentUserId; }
	Q_INVOKABLE bool isLoggedIn() const { return m_currentUserId != -1; }
	Q_INVOKABLE bool loginCard(QString cardNumber, QString pin);
	Q_INVOKABLE bool loadUserData(int login);

private: 
	int m_currentUserId = -1;
	User* m_currentUser = nullptr;
	Account* m_currentAccount = nullptr;
	Card* m_currentCard = nullptr;

signals:
	void userChanged();
};
