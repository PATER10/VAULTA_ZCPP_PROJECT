#pragma once
#include <string>

using namespace std;

class Account
{
protected:
	int m_uId, m_id;
	string m_accountNumber;
	double m_balance;
	string m_currency;
	string m_accountType;

public:
	Account(int userId, string accountNumber, double balance, string currency, string accountType);
	virtual ~Account() {};
	int getUId() const;
	int getId() const;
	string getAccountNumber();
	void setAccountNumber(string accountNumber);
	double getBalance() const;
	void setBalance(double balance);
	string getCurrency() const;
	string getAccountType() const;
};

