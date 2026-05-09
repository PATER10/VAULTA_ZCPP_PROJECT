#pragma once
#include "Account.h"
class CurrencyAccount :
    public Account
{
    CurrencyAccount(int userId, string accountNumber, double balance, string currency, string accountType);
    string generateAccountNumber(int id, string Currency);
};

