#pragma once
#include "Account.h"
#include <string>

class StandardAccount :
    public Account
{
public:
    StandardAccount(int userId, string accountNumber, double balance, string currency, string accountType);
    static string generateAccountNumber(int id);
};

