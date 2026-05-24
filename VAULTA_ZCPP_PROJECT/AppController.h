#pragma once
#include <QObject>
#include "AuthManager.h"
#include "BankManager.h"
#include "LanguageManager.h"
#include "ATM.h"
#include "AdminManager.h"

class AppController : public QObject {
	Q_OBJECT;

	//let QML to use AuthManager by property
	Q_PROPERTY(AuthManager* auth READ auth CONSTANT)
	Q_PROPERTY(BankManager* bankManager READ bankManager CONSTANT)
	Q_PROPERTY(LanguageManager* L READ L CONSTANT)
	Q_PROPERTY(ATM* atm READ atm CONSTANT)
	Q_PROPERTY(AdminManager* adminManager READ adminManager CONSTANT)

public:
	AppController();
	AuthManager* auth() const { return m_auth; }
	BankManager* bankManager() const { return m_bankManager; }
	LanguageManager* L() const { return m_langManager;  }
	ATM* atm() const { return m_atm; }
	AdminManager* adminManager() const { return m_adminManager; }

private:
	AuthManager* m_auth;
	BankManager* m_bankManager;
	LanguageManager* m_langManager;
	ATM* m_atm;
	AdminManager* m_adminManager;
};