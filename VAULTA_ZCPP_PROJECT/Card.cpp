#include "Card.h"
#include <random>

int Card::getCardId() const
{
    return m_CardId;
}

int Card::getAccId() const
{
    return m_accId;
}

string Card::getCardNumber() const
{
    return m_cardNumber;
}

void Card::setCardNumber(string cardNumber)
{
    m_cardNumber = cardNumber;
}

string Card::getPin() const
{
    return m_pin;
}

void Card::setPin(string Pin)
{
    m_pin = Pin;
}

string Card::getExpiryDate() const
{
    return m_expiryDate;
}

void Card::setExpiryDate(string expiryDate)
{
    m_expiryDate = expiryDate;
}
string Card::generateCardNumber() {
    random_device rd;
    mt19937 gen(rd());
    uniform_int_distribution<long long> dis(10000000LL, 99999999LL);
    long long number = dis(gen);
    return to_string(number);
}