#include "User.h"

int User::getUserId() const
{
	return m_id;
}

QString User::getUserName() const
{
	return m_name;
}

void User::setUserName(QString name)
{
	m_name = name;
	emit userDataChanged();
}

QString User::getUserSurname() const
{
	return m_surname;
}

void User::setUserSurname(QString surname)
{
	m_surname = surname;
	emit userDataChanged();
}

QString User::getRole() const
{
	return m_role;
}

void User::setRole(QString role)
{
	m_role = role;
	emit userDataChanged();
}

QString User::getPassword() const
{
	return m_password;
}

void User::setPassword(QString password)
{
	m_password = password;
}

QString User::getInitials() const
{
	return m_name.left(1) + m_surname.left(1);
}

Account* User::getAccount() const
{
	return m_account;
}

void User::setAccount(Account* account)
{
	m_account = account;
	emit accountChanged();
}

Card* User::getCard() const
{
	return m_card;
}

void User::setCard(Card* card)
{
	m_card = card;
	emit cardChanged();
}

QVariantList User::getTransactions() const
{
	return m_transactions;
}
