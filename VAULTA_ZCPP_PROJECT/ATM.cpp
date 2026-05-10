#include "ATM.h"

ATM::ATM(BankManager* bm, AuthManager* am, QObject* parent)
    : QObject(parent), m_bankManager(bm), m_authManager(am) {
}

bool ATM::loginWithCard(QString cardNumber, QString pin) {
    bool success = m_authManager->loginCard(cardNumber, pin);

    if (success) {
        m_loggedIn = true;
        m_activeCardNumber = cardNumber;
        m_activeBalance = m_authManager->currentUser()->getAccount()->getBalance();

        emit sessionChanged();
        emit balanceUpdated(); 
    }
    return success;
}

bool ATM::deposit(double amount) {
    if (amount <= 0) return false;
    bool dbSuccess = m_bankManager->processTransaction("DEPOSIT", amount);

    if (dbSuccess) {
        m_activeBalance += amount;
        emit balanceUpdated();
        return true;
    }
    return false;
}

bool ATM::withdraw(double amount) {
    if (amount <= 0) return false;
    bool dbSuccess = m_bankManager->processTransaction("WITHDRAWAL", amount);

    if (dbSuccess) {
        m_activeBalance -= amount;
        emit balanceUpdated();
        return true;
    }
    return false;
}

double ATM::currentBalance() const
{
    return m_activeBalance;
}
bool ATM::isLoggedIn() const{
    return m_loggedIn;
}

QString ATM::userName() const
{
    return m_authManager->currentUser()->getUserName();
}

QString ATM::userSurname() const
{
    return m_authManager->currentUser()->getUserSurname();
}
