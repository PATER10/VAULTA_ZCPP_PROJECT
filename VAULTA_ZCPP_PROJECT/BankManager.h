#pragma once
#include <QObject>
#include <QString>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <string>
#include <AuthManager.h>

class BankManager : public QObject {
	Q_OBJECT
	AuthManager* m_auth = nullptr;
public:
	explicit BankManager(QObject* parent = nullptr);
	Q_INVOKABLE void updateUserTransactions(bool limitToFive);
	void setAuth(AuthManager* auth) { m_auth = auth; }

    bool processTransaction(QString type, double amount); 
	Q_INVOKABLE bool transferFunds(QString targetAccNum, double amount);
};
