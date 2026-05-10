#pragma once
#include <string>
#include <QObject>
#include <QVariant>
#include <QVariantList>
#include "Account.h"
#include "Card.h"
#include "Transaction.h"

using namespace std;

class User : public QObject
{
	Q_OBJECT
	Q_PROPERTY(int userId READ getUserId CONSTANT)
	Q_PROPERTY(QString name READ getUserName NOTIFY userDataChanged)
	Q_PROPERTY(QString surname READ getUserSurname NOTIFY userDataChanged)
	Q_PROPERTY(QString initials READ getInitials NOTIFY userDataChanged)
	Q_PROPERTY(Account* account READ getAccount NOTIFY accountChanged)
	Q_PROPERTY(Card* card READ getCard NOTIFY cardChanged)
	Q_PROPERTY(QVariantList transactions READ getTransactions NOTIFY transactionsChanged)
private:
	int m_id;
	QString m_name, m_surname, m_role, m_password;
	Account* m_account = nullptr;
	Card* m_card = nullptr;
	QVariantList m_transactions;

public:
	explicit User(QObject *parent = nullptr) : QObject(parent) {}

	User(int userId, QString userName, QString userSurname, QString role, QString password, QObject *parent = nullptr)
		: QObject(parent), m_id(userId), m_name(userName), m_surname(userSurname), m_role(role), m_password(password) {}

	int getUserId() const;
	QString getUserName() const;
	void setUserName(QString name);
	QString getUserSurname() const;
	void setUserSurname(QString surname);
	QString getRole() const;
	void setRole(QString role);
	QString getPassword() const;
	void setPassword(QString password);
	QString getInitials() const;
	Account* getAccount() const;
	void setAccount(Account* account);
	Card* getCard() const;
	void setCard(Card* card);
	QVariantList getTransactions() const;
	void setTransactions(const QVariantList& transactions) {
		m_transactions = transactions;
		emit transactionsChanged();
	}

signals:
	void userDataChanged();
	void accountChanged();
	void cardChanged();
	void transactionsChanged();
};

