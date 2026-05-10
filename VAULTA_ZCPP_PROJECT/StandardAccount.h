#pragma once
#include "Account.h"
#include <string>

class StandardAccount :
    public Account
{
public:
    StandardAccount(int userId, QString accountNumber, double balance, QString currency, QString accountType);
    static string generateAccountNumber(int id);
};

