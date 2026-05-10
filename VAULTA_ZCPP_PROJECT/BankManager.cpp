#include "BankManager.h"
#include <QDate>
#include <QTimeZone>
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
            QDateTime timeFromDb = query.value(4).toDateTime();
            timeFromDb.setTimeZone(QTimeZone::utc());
            t->setTimestamp(timeFromDb.toLocalTime().toString("dd.MM.yyyy HH:mm"));
			list.append(QVariant::fromValue(t));
		}
		user->setTransactions(list);
	}
	else {
		qDebug() << "SQL QUERY ERROR: " << query.lastError().text();
	}
}

bool BankManager::processTransaction(QString type, double amount)
{
    User* user = m_auth->currentUser();
    if (!user || !user->getAccount()) return false;

    QString accNum = user->getAccount()->getAccountNumber();
    double currentBalance = user->getAccount()->getBalance();
    double newBalance = currentBalance;

    if (type == "DEPOSIT" || type == "TRANSFER IN") {
        newBalance += amount;
    }
    else if (type == "WITHDRAWAL" || type == "TRANSFER OUT") {
        if (currentBalance < amount) return false;
        newBalance -= amount;
    }
    else {
        return false;
    }

    QSqlDatabase db = QSqlDatabase::database();
    db.transaction();

    QSqlQuery updateQuery(db);

    QString updateSql = QString("UPDATE account SET balance = :nBalance WHERE account_number = :accNum");
    updateQuery.prepare(updateSql);
    updateQuery.bindValue(":nBalance", newBalance);
    updateQuery.bindValue(":accNum", accNum);

    QSqlQuery insertQuery(db);
    insertQuery.prepare("INSERT INTO transaction (type, accountnumber, amount, timestamp) "
        "VALUES (:type, :accNum, :amount, CURRENT_TIMESTAMP)");
    insertQuery.bindValue(":type", type);
    insertQuery.bindValue(":accNum", accNum);
    insertQuery.bindValue(":amount", amount);

    if (updateQuery.exec() && insertQuery.exec()) {
        db.commit();

        user->getAccount()->setBalance(newBalance);
        updateUserTransactions(true);
        return true;
    }
    else {
        db.rollback();
        qDebug() << "ERROR PROCESING TRANSACTION:" << updateQuery.lastError().text();
        qDebug() << "ERROR INSERT DATA" << insertQuery.lastError().text();
        return false;
    }
}



