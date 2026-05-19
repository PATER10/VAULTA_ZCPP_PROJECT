#pragma once
#include "Account.h"
class CurrencyAccount :
    public Account
{
public:
    CurrencyAccount(int userId, QString accountNumber, double balance, QString currency, QString accountType);
    static string generateAccountNumber(int id, string Currency);
};

