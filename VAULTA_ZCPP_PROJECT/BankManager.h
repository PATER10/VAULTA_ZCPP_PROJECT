#pragma once
#include <QObject>
#include <QString>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <string>

class BankManager : public QObject {
	Q_OBJECT
public:
	explicit BankManager(QObject* parent = nullptr);
	Q_INVOKABLE QVariantMap getAccountData(int uId);
	Q_INVOKABLE QVariantList getLatestTransactions(int uid);
};
