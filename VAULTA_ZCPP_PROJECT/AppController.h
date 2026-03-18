#pragma once
#include <QObject>
#include "AuthManager.h"

class AppController : public QObject {
	Q_OBJECT

	//let QML to use AuthManager by property
	Q_PROPERTY(AuthManager* auth READ auth CONSTANT)

public:
	AppController();
	AuthManager* auth() const { return m_auth; }

private:
	AuthManager* m_auth;
};