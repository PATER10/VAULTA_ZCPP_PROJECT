#include "AppController.h"

AppController::AppController()
{
	m_auth = new AuthManager(this);
	m_bankManager = new BankManager(this);
	m_langManager = new LanguageManager(this);

	m_langManager->loadSavedLanguage();
	m_bankManager->setAuth(m_auth);
}
