#include "Transaction.h"
#include <sstream>

QString Transaction::getCurrentTimestamp() {
	time_t now = time(0);
	struct tm now_tm;
	char buffer[80];
	if (localtime_s(&now_tm, &now) != 0) {
		return "ERROR";
	}
	// Format: YYYY-MM-DD HH:MM:SS
	strftime(buffer, sizeof(buffer), "%Y-%m-%d %H:%M:%S", &now_tm);
	return buffer;
}

Transaction::Transaction(int id, QString type, QString accountNumber, double amount, QString targetAccount)
	:m_id(id), m_type(type), m_accountNumber(accountNumber), m_amount(amount), m_targetAccount(targetAccount)
{
	this->m_timestamp = getCurrentTimestamp();
}

Transaction::Transaction(int id, QString type, QString accountNumber, double amount, QString targetAccount, QString date)
	:m_id(id), m_type(type), m_accountNumber(accountNumber), m_amount(amount), m_targetAccount(targetAccount), m_timestamp(date)
{
}

int Transaction::getTransactionId() const
{
	return m_id;
}

QString Transaction::getType() const
{
	return m_type;
}

void Transaction::setType(QString type)
{
	m_type = type;
}

QString Transaction::getAccountNumber() const
{
	return m_accountNumber;
}

void Transaction::setAccountNumber(QString accountNumber) {
	m_accountNumber = accountNumber;
}

double Transaction::getAmount() const
{
	return m_amount;
}

void Transaction::setAmount(double amount)
{
	m_amount = amount;
}

QString Transaction::getTimestamp() const
{
	return m_timestamp;
}

void Transaction::setTimestamp(QString date)
{
	m_timestamp = date;
}

QString Transaction::getTargetAccount() const
{
	return m_targetAccount;
}

void Transaction::setTargetAccount(QString targetAccount)
{
	m_targetAccount = targetAccount;
}

double Transaction::getExchangeAmount() const
{
	return m_exchangeAmount;
}

void Transaction::setExchangeAmount(double exchangeAmount)
{
	m_exchangeAmount = exchangeAmount;
}


