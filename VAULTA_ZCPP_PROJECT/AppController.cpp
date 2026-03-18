#include "AppController.h"

AppController::AppController()
{
	m_auth = new AuthManager(this);
}
