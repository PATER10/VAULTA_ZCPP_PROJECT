#pragma once
#include <QObject>
#include <QString>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QVariantMap>
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
	Q_INVOKABLE bool addCurrencyAccount(QString currency);
	Q_INVOKABLE bool exchangeEuro(QString direction, double amountEuro);
	Q_INVOKABLE bool exchangeBetweenAccounts(QString fromAccountNumber, QString toAccountNumber, double fromAmount);
	Q_INVOKABLE QVariantMap currentEuroRates();
};
