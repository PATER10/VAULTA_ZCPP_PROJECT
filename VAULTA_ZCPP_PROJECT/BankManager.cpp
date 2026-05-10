#include "BankManager.h"
#include <QDate>
#include <QDebug>

BankManager::BankManager(QObject* parent)
{

}

void BankManager::updateUserTransactions(bool limitToFive)
{
	User* user = m_auth->currentUser();
	if (!user || !user->getAccount()) return;

	QSqlDatabase db = QSqlDatabase::database();
	QSqlQuery query;

	int currentUserId = m_auth->currentUserId();

	QString sqlQuery = "SELECT type,accountnumber,amount,targetaccount,timestamp "
		"FROM transaction WHERE accountnumber = :accNum ";
	
	if (limitToFive) {
		sqlQuery += "ORDER BY timestamp DESC LIMIT 5";
	}
	else {
		sqlQuery += "ORDER BY timestamp DESC";
	}

	query.prepare(sqlQuery);
	query.bindValue(":accNum", user->getAccount()->getAccountNumber());

	if (query.exec()) {
		QVariantList list;
		while (query.next()) {
			Transaction* t = new Transaction(user);
			t->setType(query.value(0).toString());
			t->setAccountNumber(query.value(1).toString());
			t->setAmount(query.value(2).toDouble());
			t->setTargetAccount(query.value(3).toString());
			t->setTimestamp(query.value(4).toDateTime().toString("dd.MM.yyyy HH:mm"));
			list.append(QVariant::fromValue(t));
		}
		user->setTransactions(list);
	}
	else {
		qDebug() << "SQL QUERY ERROR: " << query.lastError().text();
	}
}



