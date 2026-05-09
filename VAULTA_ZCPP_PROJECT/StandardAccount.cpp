#include "StandardAccount.h"
#include <iomanip>
#include <sstream>

StandardAccount::StandardAccount(int userId, string accountNumber, double balance, string currency, string accountType) 
	: Account(userId,accountNumber, balance, "PLN", "Standard")
{}

//generate account number
string StandardAccount::generateAccountNumber(int id)
{
	ostringstream oss;
	oss << "PL" << setw(8) << setfill('0') << id;
	return oss.str();
}
