#include "Transaction.h"
#include <sstream>

string Transaction::getCurrentTimestamp() {
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

Transaction::Transaction(int id, string type, string accountNumber, double amount, string targetAccount)
	:m_id(id), m_type(type), m_accountNumber(accountNumber), m_amount(amount), m_targetAccount(targetAccount)
{
	this->m_timestamp = getCurrentTimestamp();
}

int Transaction::getTransactionId() const
{
	return m_id;
}

string Transaction::getType() const
{
	return m_type;
}

void Transaction::setType(string type)
{
	m_type = type;
}

string Transaction::getAccountNumber() const
{
	return m_accountNumber;
}

void Transaction::setAccountNumber(string accountNumber) {
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

string Transaction::getTimestamp() const
{
	return m_timestamp;
}

string Transaction::getTargetAccount() const
{
	return m_targetAccount;
}

void Transaction::setTargetAccount(string targetAccount)
{
	m_targetAccount = targetAccount;
}


