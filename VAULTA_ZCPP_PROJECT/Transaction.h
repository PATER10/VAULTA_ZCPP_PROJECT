#pragma once
#include <string>

using namespace std;

class Transaction
{
private:
	int m_id;
	string m_type, m_accountNumber, m_timestamp, m_targetAccount, getCurrentTimestamp();
	double m_amount;

public:
	Transaction(int id, string type, string accountNumber,double amount, string targetAccount);

	int getTransactionId() const;
	string getType() const;
	void setType(string type);
	string getAccountNumber() const;
	void setAccountNumber(string accountNumber);
	double getAmount() const;
	void setAmount(double amount);
	string getTimestamp() const;
	string getTargetAccount() const;
	void setTargetAccount(string targetAccount);
};

