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
	std::string generateCardNumber();
	std::string generateAccountNumber(int id);

	explicit AuthManager(QObject* parent = nullptr);

	Q_INVOKABLE QVariantMap registerUser(QString name, QString surname, QString password, QString pin);

	//login is the same like userId
	Q_INVOKABLE QVariantMap loginUser(int login, QString password);
	

};
