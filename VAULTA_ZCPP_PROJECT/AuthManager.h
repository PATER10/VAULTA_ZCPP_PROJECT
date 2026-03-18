#pragma once

#include <QObject>
#include <QString>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <string>

class AuthManager : public QObject {
	Q_OBJECT
public: 
	explicit AuthManager(QObject* parent = nullptr);

	Q_INVOKABLE QVariantMap registerUser(QString name, QString surname, QString password, QString pin);
	std::string generateCardNumber();
	std::string generateAccountNumber(int id);

};
