#include "CurrencyAccount.h"
#include <iomanip>
#include <sstream>

CurrencyAccount::CurrencyAccount(int userId, QString accountNumber, double balance, QString currency, QString accountType)
	:Account(userId, accountNumber, balance, currency, "Currency") {}

string CurrencyAccount::generateAccountNumber(int id, string Currency) {
	ostringstream oss;
	oss << Currency << setw(8) << setfill('0') << id;
	return oss.str();
}