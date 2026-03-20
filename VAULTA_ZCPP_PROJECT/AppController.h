#pragma once
#include <QObject>
#include "AuthManager.h"
#include "BankManager.h"

class AppController : public QObject {
	Q_OBJECT

	//let QML to use AuthManager by property
	Q_PROPERTY(AuthManager* auth READ auth CONSTANT)
	Q_PROPERTY(BankManager* bankManager READ bankManager CONSTANT)

public:
	AppController();
	AuthManager* auth() const { return m_auth; }
	BankManager* bankManager() const { return m_bankManager; }

private:
	AuthManager* m_auth;
	BankManager* m_bankManager;
};