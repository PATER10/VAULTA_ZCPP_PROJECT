#include "Account.h"


Account::Account(int userId, QString accountNumber, double balance, QString currency, QString accountType)
    : m_uId(userId), m_accountNumber(accountNumber), m_balance(balance), m_currency(currency), m_accountType(accountType) {}

int Account::getUId() const
{
    return m_uId;
}

int Account::getId() const
{
    return m_id;
}

QString Account::getAccountNumber()
{
    return m_accountNumber;
}

void Account::setAccountNumber(QString accountNumber)
{
    m_accountNumber = accountNumber;
}

double Account::getBalance() const
{
    return m_balance;
}

void Account::setBalance(double balance)
{
    if (m_balance == balance) return;
    m_balance = balance;
    emit balanceChanged();
}

QString Account::getCurrency() const
{
    return m_currency;
}

QString Account::getAccountType() const
{
    return m_accountType;
}
