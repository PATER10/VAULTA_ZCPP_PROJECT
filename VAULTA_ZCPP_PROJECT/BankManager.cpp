#include "BankManager.h"
#include <QDate>
#include <QDebug>

BankManager::BankManager(QObject* parent)
{

}

Q_INVOKABLE QVariantMap BankManager::getAccountData()
{
	QVariantMap result;
	result["success"] = false;

	QSqlDatabase db = QSqlDatabase::database();
	QSqlQuery query;

	int currentId = m_auth->currentUserId();

	query.prepare("SELECT a.account_number, a.balance, a.currency, a.account_type, c.card_number " 
		"FROM accounts a LEFT JOIN cards c ON a.id=c.account_id WHERE a.user_id = :uId");
	query.bindValue(":uId", currentId);

	if (!query.exec() || !query.next()) {
		qDebug() << query.lastError();
		return result;
	}

	result["success"] = true;
	result["accNumber"] = query.value(0).toString();
	result["balance"] = query.value(1).toString();
	result["currency"] = query.value(2).toString();
	result["accType"] = query.value(3).toString();
	result["cardNumber"] = query.value(4).toString();

	return result;
}

Q_INVOKABLE QVariantList BankManager::getLatestTransactions()
{
	QVariantList list;

	QSqlDatabase db = QSqlDatabase::database();
	QSqlQuery query;

	int currentUserId = m_auth->currentUserId();

	query.prepare("SELECT title, amount, date, type,  "
		"FROM transactions WHERE sender_id = :id OR receiver_id = :id "
		"ORDER BY date DESC LIMIT 5");
	query.bindValue(":id", currentUserId);

	if (!query.exec()) {
		while (query.next()) {
			QVariantMap map;
			map["title"] = query.value(0).toString();
			map["amount"] = query.value(1).toDouble();
			map["date"] = query.value(2).toDate().toString("dd.MM.yyyy");
			map["type"] = query.value(3).toString();
			list.append(map);
		}
	}

	return list;
}



