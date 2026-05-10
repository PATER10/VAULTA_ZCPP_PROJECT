// ATM.h
#pragma once
#include <QObject>
#include <QString>
#include "BankManager.h"
#include "AuthManager.h"

class ATM : public QObject {
    Q_OBJECT
    Q_PROPERTY(double currentBalance READ currentBalance NOTIFY balanceUpdated)
    Q_PROPERTY(bool isLoggedIn READ isLoggedIn NOTIFY sessionChanged)
    Q_PROPERTY(QString userName READ userName NOTIFY sessionChanged)
    Q_PROPERTY(QString userSurname READ userSurname NOTIFY sessionChanged)
public:
    explicit ATM(BankManager* bm, AuthManager* am, QObject* parent = nullptr);

    Q_INVOKABLE bool loginWithCard(QString cardNumber, QString pin);

    Q_INVOKABLE bool deposit(double amount);
    Q_INVOKABLE bool withdraw(double amount);
    double currentBalance() const;
    bool isLoggedIn() const;
    QString userName() const;
    QString userSurname() const;


private:
    BankManager* m_bankManager;
    AuthManager* m_authManager;
    bool m_loggedIn;
    double m_activeBalance;
    QString m_activeCardNumber;
signals:
    void balanceUpdated();
    void sessionChanged();
};