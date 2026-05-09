#pragma once
#include <string>
#include <QString>
#include <QObject>

using namespace std;

class Account : public QObject
{
	Q_OBJECT
	Q_PROPERTY(double balance READ getBalance NOTIFY balanceChanged)
	Q_PROPERTY(QString currency READ getCurrency CONSTANT)
	Q_PROPERTY(QString accountNumber READ getAccountNumber CONSTANT)
protected:
	int m_uId, m_id;
	QString m_accountNumber;
	double m_balance;
	QString m_currency;
	QString m_accountType;

public:
	explicit Account(QObject *parent = nullptr) : QObject(parent) {}
	Account(int userId, QString accountNumber, double balance, QString currency, QString accountType);
	virtual ~Account() {};
	int getUId() const;
	int getId() const;
	QString getAccountNumber();
	void setAccountNumber(QString accountNumber);
	double getBalance() const;
	void setBalance(double balance);
	QString getCurrency() const;
	QString getAccountType() const;
signals:
	void balanceChanged();
};

