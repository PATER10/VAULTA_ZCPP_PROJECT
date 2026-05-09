#include "Account.h"


Account::Account(int userId, string accountNumber, double balance, string currency, string accountType)
    : m_uId(userId), m_accountNumber(accountNumber), m_balance(balance), m_currency(currency), m_accountType(accountType) {}

int Account::getUId() const
{
    return m_uId;
}

int Account::getId() const
{
    return m_id;
}

string Account::getAccountNumber()
{
    return m_accountNumber;
}

void Account::setAccountNumber(string accountNumber)
{
    m_accountNumber = accountNumber;
}

double Account::getBalance() const
{
    return m_balance;
}

void Account::setBalance(double balance)
{
    m_balance = balance;
}

string Account::getCurrency() const
{
    return m_currency;
}

string Account::getAccountType() const
{
    return m_accountType;
}
