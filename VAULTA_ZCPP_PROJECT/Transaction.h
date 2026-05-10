#pragma once
#include <string>
#include <QObject>

using namespace std;

class Transaction : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QString accountNumber READ getAccountNumber CONSTANT)
	Q_PROPERTY(double amount READ getAmount CONSTANT)
	Q_PROPERTY(QString date READ getTimestamp CONSTANT)
	Q_PROPERTY(QString type READ getType CONSTANT)
	Q_PROPERTY(QString targetAccount READ getTargetAccount CONSTANT)
private:
	int m_id;
	QString m_type, m_accountNumber, m_timestamp, m_targetAccount, getCurrentTimestamp();
	double m_amount;

public:
	explicit Transaction(QObject* parent = nullptr) : QObject(parent) {}
	Transaction(int id, QString type, QString accountNumber,double amount, QString targetAccount);
	Transaction(int id, QString type, QString accountNumber, double amount, QString targetAccount, QString date);

	int getTransactionId() const;
	QString getType() const;
	void setType(QString type);
	QString getAccountNumber() const;
	void setAccountNumber(QString accountNumber);
	double getAmount() const;
	void setAmount(double amount);
	QString getTimestamp() const;
	void setTimestamp(QString date);
	QString getTargetAccount() const;
	void setTargetAccount(QString targetAccount);
};

