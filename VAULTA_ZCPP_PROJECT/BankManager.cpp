#include "BankManager.h"
#include "CurrencyAccount.h"
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

	QString sqlQuery = "SELECT type,account_number,amount,target_account,timestamp "
		"FROM transaction WHERE account_number = :accNum ";
	
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
    insertQuery.prepare("INSERT INTO transaction (type, account_number, amount, timestamp) "
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

bool BankManager::transferFunds(QString targetAccNum, double amount)
{
    User* user = m_auth->currentUser();
    if (!user || !user->getAccount() || amount <= 0) return false;
    QString myAccNum = user->getAccount()->getAccountNumber();
    if (myAccNum == targetAccNum) return false;
    double myBalance = user->getAccount()->getBalance();

    if (myBalance < amount) return false;

    QSqlDatabase db = QSqlDatabase::database();
    if (!db.transaction()) return false;

    QSqlQuery query(db);

    query.prepare("SELECT balance FROM account WHERE account_number = :target");
    query.bindValue(":target", targetAccNum);

    if (!query.exec() || !query.next()) {
        qDebug() << "Receiver doesn't exist!!!";
        db.rollback();
        return false;
    }
    double targetBalance = query.value(0).toDouble();

    double myNewBalance = myBalance - amount;
    QString updateMe = QString("UPDATE account SET balance = %1 WHERE account_number = '%2'")
        .arg(myNewBalance).arg(myAccNum);

    double targetNewBalance = targetBalance + amount;
    QString updateTarget = QString("UPDATE account SET balance = %1 WHERE account_number = '%2'")
        .arg(targetNewBalance).arg(targetAccNum);

    QString saveTransferOut = QString("INSERT INTO transaction (type, account_number, amount, target_account, timestamp) "
        "VALUES ('TRANSFER OUT', '%1', %2, '%3', CURRENT_TIMESTAMP)")
        .arg(myAccNum).arg(amount).arg(targetAccNum);

    QString saveTransferIn = QString("INSERT INTO transaction (type, account_number, amount, target_account, timestamp) "
        "VALUES ('TRANSFER IN', '%1', %2, '%3', CURRENT_TIMESTAMP)")
        .arg(targetAccNum).arg(amount).arg(myAccNum);

    if (query.exec(updateMe) && query.exec(updateTarget) && query.exec(saveTransferOut) && query.exec(saveTransferIn)) {
        if (db.commit()) {
            user->getAccount()->setBalance(myNewBalance);
            updateUserTransactions(true);
            return true;
        }
    }
    db.rollback();
    return false;
}

Q_INVOKABLE bool BankManager::addCurrencyAccount(QString currency)
{
    User* user = m_auth->currentUser();
    if (!user) return false;

    currency = currency.trimmed().toUpper();

    if (currency.isEmpty() || currency == "PLN") return false;

    for (QVariant item : user->getAccounts()) {
        Account* account = item.value<Account*>();
        if (account && account->getCurrency() == currency) {
            return false; // użytkownik już ma takie konto
        }
    }

    QString accountNumber = QString::fromStdString(
        CurrencyAccount::generateAccountNumber(user->getUserId(), currency.toStdString())
    );

    QSqlDatabase db = QSqlDatabase::database();
    QSqlQuery query(db);

    query.prepare(
        "INSERT INTO account (user_id, account_number, balance, currency, account_type) "
        "VALUES (:uid, :accNo, :balance, :currency, :type) "
        "RETURNING id"
    );

    query.bindValue(":uid", user->getUserId());
    query.bindValue(":accNo", accountNumber);
    query.bindValue(":balance", 0.00);
    query.bindValue(":currency", currency);
    query.bindValue(":type", "Currency Account");

    if (!query.exec() || !query.next()) {
        qDebug() << "ADD ACCOUNT ERROR:" << query.lastError().text();
        return false;
    }

    Account* account = new CurrencyAccount(
        user->getUserId(),
        accountNumber,
        0.00,
        currency,
        currency + " Account"
    );

    user->addAccount(account);
    user->setActiveAccount(account);
    updateUserTransactions(true);

    return true;
}

bool BankManager::exchangeEuro(QString direction, double amountEuro)
{
    static constexpr double EUR_BUY_RATE = 4.40;   // PLN -> EUR
    static constexpr double EUR_SELL_RATE = 4.10;  // EUR -> PLN

    User* user = m_auth->currentUser();
    if (!user || amountEuro <= 0) return false;

    Account* plnAccount = nullptr;
    Account* eurAccount = nullptr;

    for (const QVariant& item : user->getAccounts()) {
        Account* account = qvariant_cast<Account*>(item);
        if (!account) continue;

        if (account->getCurrency() == "PLN") {
            plnAccount = account;
        }
        else if (account->getCurrency() == "EUR") {
            eurAccount = account;
        }
    }

    if (!plnAccount || !eurAccount) return false;

    direction = direction.trimmed().toUpper();

    bool plnToEur = direction == "PLN_TO_EUR";
    bool eurToPln = direction == "EUR_TO_PLN";

    if (!plnToEur && !eurToPln) return false;

    double rate = plnToEur ? EUR_BUY_RATE : EUR_SELL_RATE;
    double plnAmount = amountEuro * rate;

    if (plnToEur && plnAccount->getBalance() < plnAmount) return false;
    if (eurToPln && eurAccount->getBalance() < amountEuro) return false;

    QString plnAccountNumber = plnAccount->getAccountNumber();
    QString eurAccountNumber = eurAccount->getAccountNumber();

    QSqlDatabase db = QSqlDatabase::database();
    if (!db.transaction()) return false;

    QSqlQuery updatePln(db);
    QSqlQuery updateEur(db);
    QSqlQuery insertPlnTransaction(db);
    QSqlQuery insertEurTransaction(db);

    if (plnToEur) {
        updatePln.prepare(
            "UPDATE account SET balance = balance - :amount "
            "WHERE account_number = :accountNumber"
        );
        updatePln.bindValue(":amount", plnAmount);
        updatePln.bindValue(":accountNumber", plnAccountNumber);

        updateEur.prepare(
            "UPDATE account SET balance = balance + :amount "
            "WHERE account_number = :accountNumber"
        );
        updateEur.bindValue(":amount", amountEuro);
        updateEur.bindValue(":accountNumber", eurAccountNumber);

        insertPlnTransaction.prepare(
            "INSERT INTO transaction "
            "(type, account_number, amount, target_account, exchange_amount,exchange_rate timestamp) "
            "VALUES "
            "('PLN TO EUR', :accountNumber, :amount, :targetAccount, :exchangeAmount,:exchangeRate CURRENT_TIMESTAMP)"
        );
        insertPlnTransaction.bindValue(":accountNumber", plnAccountNumber);
        insertPlnTransaction.bindValue(":amount", plnAmount);
        insertPlnTransaction.bindValue(":targetAccount", eurAccountNumber);
        insertPlnTransaction.bindValue(":exchangeAmount", amountEuro);
        insertPlnTransaction.bindValue(":exchangeRate", EUR_SELL_RATE);

        insertEurTransaction.prepare(
            "INSERT INTO transaction "
            "(type, account_number, amount, target_account, exchange_amount,exchange_rate, timestamp) "
            "VALUES "
            "('PLN TO EUR', :accountNumber, :amount, :targetAccount, :exchangeAmount,:exchangeRate, CURRENT_TIMESTAMP)"
        );
        insertEurTransaction.bindValue(":accountNumber", eurAccountNumber);
        insertEurTransaction.bindValue(":amount", amountEuro);
        insertEurTransaction.bindValue(":targetAccount", plnAccountNumber);
        insertEurTransaction.bindValue(":exchangeAmount", plnAmount);
        insertEurTransaction.bindValue(":exchangeRate", EUR_SELL_RATE);
    }
    else {
        updateEur.prepare(
            "UPDATE account SET balance = balance - :amount "
            "WHERE account_number = :accountNumber"
        );
        updateEur.bindValue(":amount", amountEuro);
        updateEur.bindValue(":accountNumber", eurAccountNumber);

        updatePln.prepare(
            "UPDATE account SET balance = balance + :amount "
            "WHERE account_number = :accountNumber"
        );
        updatePln.bindValue(":amount", plnAmount);
        updatePln.bindValue(":accountNumber", plnAccountNumber);

        insertEurTransaction.prepare(
            "INSERT INTO transaction "
            "(type, account_number, amount, target_account, exchange_amount, exchange_rate timestamp) "
            "VALUES "
            "('EUR TO PLN', :accountNumber, :amount, :targetAccount, :exchangeAmount,exchangeRate, CURRENT_TIMESTAMP)"
        );
        insertEurTransaction.bindValue(":accountNumber", eurAccountNumber);
        insertEurTransaction.bindValue(":amount", amountEuro);
        insertEurTransaction.bindValue(":targetAccount", plnAccountNumber);
        insertEurTransaction.bindValue(":exchangeAmount", plnAmount);
        insertEurTransaction.bindValue(":exchangeRate", EUR_BUY_RATE);

        insertPlnTransaction.prepare(
            "INSERT INTO transaction "
            "(type, account_number, amount, target_account, exchange_amount,exchange_rate, timestamp) "
            "VALUES "
            "('EUR TO PLN', :accountNumber, :amount, :targetAccount, :exchangeAmount,:exchangeRate, CURRENT_TIMESTAMP)"
        );
        insertPlnTransaction.bindValue(":accountNumber", plnAccountNumber);
        insertPlnTransaction.bindValue(":amount", plnAmount);
        insertPlnTransaction.bindValue(":targetAccount", eurAccountNumber);
        insertPlnTransaction.bindValue(":exchangeAmount", amountEuro);
        insertPlnTransaction.bindValue(":exchangeRate", EUR_BUY_RATE);
    }

    if (!updatePln.exec() ||
        !updateEur.exec() ||
        !insertPlnTransaction.exec() ||
        !insertEurTransaction.exec()) {

        qDebug() << "EXCHANGE ERROR:"
            << updatePln.lastError().text()
            << updateEur.lastError().text()
            << insertPlnTransaction.lastError().text()
            << insertEurTransaction.lastError().text();

        db.rollback();
        return false;
    }

    if (!db.commit()) {
        qDebug() << "EXCHANGE COMMIT ERROR:" << db.lastError().text();
        db.rollback();
        return false;
    }

    if (plnToEur) {
        plnAccount->setBalance(plnAccount->getBalance() - plnAmount);
        eurAccount->setBalance(eurAccount->getBalance() + amountEuro);
    }
    else {
        eurAccount->setBalance(eurAccount->getBalance() - amountEuro);
        plnAccount->setBalance(plnAccount->getBalance() + plnAmount);
    }

    updateUserTransactions(true);
    return true;
}



