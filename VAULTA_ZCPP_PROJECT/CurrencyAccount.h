#pragma once
#include "Account.h"
class CurrencyAccount :
    public Account
{
    CurrencyAccount(int userId, QString accountNumber, double balance, QString currency, QString accountType);
    string generateAccountNumber(int id, string Currency);
};

