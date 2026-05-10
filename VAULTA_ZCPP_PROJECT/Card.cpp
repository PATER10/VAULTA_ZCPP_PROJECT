#include "Card.h"
#include <random>
#include "AuthManager.h"

Card::Card(int accId, QString cardNumber, QString pin, QString expiryDate)
    : m_accId(accId), m_cardNumber(cardNumber), m_pin(pin), m_expiryDate(expiryDate)
{
}

int Card::getCardId() const
{
    return m_CardId;
}

int Card::getAccId() const
{
    return m_accId;
}

QString Card::getCardNumber() const
{
    return m_cardNumber;
}

void Card::setCardNumber(QString cardNumber)
{
    m_cardNumber = cardNumber;
}

QString Card::getPin() const
{
    return m_pin;
}

void Card::setPin(QString Pin)
{
    m_pin = Pin;
}

QString Card::getExpiryDate() const
{
    return m_expiryDate;
}

void Card::setExpiryDate(QString expiryDate)
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