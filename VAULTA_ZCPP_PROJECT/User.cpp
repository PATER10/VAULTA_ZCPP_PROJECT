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
	return m_activeAccount;
}

QVariantList User::getAccounts() const
{
	QVariantList list;
	for (Account* account : m_accounts) {
		list.append(QVariant::fromValue(account));
	}
	return list;
}

void User::addAccount(Account* account)
{
	if (!account) return;

	m_accounts.append(account);

	if (!m_activeAccount) {
		m_activeAccount = account;
		emit accountChanged();
	}
	emit accountsChanged();
}

Q_INVOKABLE void User::setActiveAccount(Account* account)
{
	if (!account || m_activeAccount == account) return;
	m_activeAccount = account;
	emit accountChanged();
}

Q_INVOKABLE void User::setActiveAccountByNumber(QString accountNumber)
{
	for (Account* account : m_accounts) {
		if (account->getAccountNumber() == accountNumber) {
			setActiveAccount(account);
			return;
		}
	}
}

bool User::hasCurrencyAccounts() const
{
	for (Account* account : m_accounts) {
		if (account && account->getCurrency() != "PLN") {
			return true;
		}
	}
	return false;
}

Account* User::getAccountByCurrency(QString currency) const
{
	for (Account* account : m_accounts) {
		if (account && account->getCurrency() == currency) {
			return account;
		}
	}
	return nullptr;
}

void User::setAccount(Account* account)
{
	addAccount(account);
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
