#pragma once
#include <string>

using namespace std;

class Card
{
private:
	int m_CardId, m_accId;
	string m_cardNumber, m_pin, m_expiryDate;

public:
	int getCardId() const;
	int getAccId() const;
	string getCardNumber() const;
	void setCardNumber(string cardNumber);
	string getPin() const;
	void setPin(string Pin);
	string getExpiryDate() const;
	void setExpiryDate(string expiryDate);
	static string generateCardNumber();
};

