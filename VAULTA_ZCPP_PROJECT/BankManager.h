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
};
