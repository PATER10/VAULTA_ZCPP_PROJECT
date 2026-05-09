#include "StandardAccount.h"
#include <iomanip>
#include <sstream>
#include <QString>

StandardAccount::StandardAccount(int userId, QString accountNumber, double balance, QString currency="PLN", QString accountType="Standard")
	: Account(userId,accountNumber, balance, "PLN", "Standard")
{}

//generate account number
string StandardAccount::generateAccountNumber(int id)
{
	ostringstream oss;
	oss << "PL" << setw(8) << setfill('0') << id;
	return oss.str();
}
