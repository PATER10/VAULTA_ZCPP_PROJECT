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

	QString sqlQuery = "SELECT type,account_number,amount,target_account,timestamp, exchange_amount "
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
            t->setExchangeAmount(query.value(5).toDouble());
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
    static constexpr double EUR_BUY_RATE = 4.40;   // PLN -> EUR
    static constexpr double EUR_SELL_RATE = 4.10;  // EUR -> PLN

    User* user = m_auth->currentUser();
    if (!user || !user->getAccount() || amount <= 0) return false;
    Account* sourceAccount = user->getAccount();

    QString sourceAccNum = sourceAccount->getAccountNumber();
    QString sourceCurrency = sourceAccount->getCurrency();

    targetAccNum = targetAccNum.trimmed();

    if (sourceAccNum == targetAccNum) return false;
    double myBalance = user->getAccount()->getBalance();

    if (myBalance < amount) return false;

    QSqlDatabase db = QSqlDatabase::database();
    if (!db.transaction()) return false;

    QSqlQuery query(db);

    query.prepare("SELECT balance, currency FROM account WHERE account_number = :target");
    query.bindValue(":target", targetAccNum);

    if (!query.exec() || !query.next()) {
        qDebug() << "Receiver doesn't exist!!!";
        db.rollback();
        return false;
    }
    double targetBalance = query.value(0).toDouble();
    QString targetCurrency = query.value(1).toString();

    double sourceAmount = amount;
    double targetAmount = amount;
    double exchangeAmount = 0.00;
    QString transferOutType = "TRANSFER OUT";
    QString transferInType = "TRANSFER IN";

    if (sourceCurrency != targetCurrency) {
        if (sourceCurrency == "PLN" && targetCurrency == "EUR") {
            targetAmount = sourceAmount / EUR_BUY_RATE;
            exchangeAmount = targetAmount;
        }
        else if (sourceCurrency == "EUR" && targetCurrency == "PLN") {
            targetAmount = sourceAmount * EUR_SELL_RATE;
            exchangeAmount = targetAmount;
        }
        else {
            db.rollback();
            return false;
        }
    }

    double sourceNewBalance = sourceAccount->getBalance() - sourceAmount;
    double targetNewBalance = targetBalance + targetAmount;



    QSqlQuery updateSource(db);
    updateSource.prepare(
        "UPDATE account SET balance = :balance "
        "WHERE account_number = :accountNumber"
    );
    updateSource.bindValue(":balance", sourceNewBalance);
    updateSource.bindValue(":accountNumber", sourceAccNum);

    QSqlQuery updateTarget(db);
    updateTarget.prepare(
        "UPDATE account SET balance = :balance "
        "WHERE account_number = :accountNumber"
    );
    updateTarget.bindValue(":balance", targetNewBalance);
    updateTarget.bindValue(":accountNumber", targetAccNum);

    QSqlQuery insertOut(db);
    insertOut.prepare(
        "INSERT INTO transaction "
        "(type, account_number, amount, target_account, exchange_amount, timestamp) "
        "VALUES "
        "(:type, :accountNumber, :amount, :targetAccount, :exchangeAmount, CURRENT_TIMESTAMP)"
    );
    insertOut.bindValue(":type", transferOutType);
    insertOut.bindValue(":accountNumber", sourceAccNum);
    insertOut.bindValue(":amount", sourceAmount);
    insertOut.bindValue(":targetAccount", targetAccNum);
    insertOut.bindValue(":exchangeAmount", exchangeAmount);

    QSqlQuery insertIn(db);
    insertIn.prepare(
        "INSERT INTO transaction "
        "(type, account_number, amount, target_account, exchange_amount, timestamp) "
        "VALUES "
        "(:type, :accountNumber, :amount, :targetAccount, :exchangeAmount, CURRENT_TIMESTAMP)"
    );
    insertIn.bindValue(":type", transferInType);
    insertIn.bindValue(":accountNumber", targetAccNum);
    insertIn.bindValue(":amount", targetAmount);
    insertIn.bindValue(":targetAccount", sourceAccNum);
    insertIn.bindValue(":exchangeAmount", sourceAmount);

    if (!updateSource.exec() ||
        !updateTarget.exec() ||
        !insertOut.exec() ||
        !insertIn.exec()) {

        qDebug() << "TRANSFER ERROR:"
            << updateSource.lastError().text()
            << updateTarget.lastError().text()
            << insertOut.lastError().text()
            << insertIn.lastError().text();

        db.rollback();
        return false;
    }

    if (!db.commit()) {
        qDebug() << "TRANSFER COMMIT ERROR:" << db.lastError().text();
        db.rollback();
        return false;
    }

    sourceAccount->setBalance(sourceNewBalance);

    for (const QVariant& item : user->getAccounts()) {
        Account* account = qvariant_cast<Account*>(item);
        if (account && account->getAccountNumber() == targetAccNum) {
            account->setBalance(targetNewBalance);
            break;
        }
    }

    updateUserTransactions(true);
    return true;
}

bool BankManager::addCurrencyAccount(QString currency)
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
            "(type, account_number, amount, target_account, exchange_amount, timestamp) "
            "VALUES "
            "('PLN TO EUR', :accountNumber, :amount, :targetAccount, :exchangeAmount, CURRENT_TIMESTAMP)"
        );
        insertPlnTransaction.bindValue(":accountNumber", plnAccountNumber);
        insertPlnTransaction.bindValue(":amount", plnAmount);
        insertPlnTransaction.bindValue(":targetAccount", eurAccountNumber);
        insertPlnTransaction.bindValue(":exchangeAmount", amountEuro);

        insertEurTransaction.prepare(
            "INSERT INTO transaction "
            "(type, account_number, amount, target_account, exchange_amount, timestamp) "
            "VALUES "
            "('PLN TO EUR', :accountNumber, :amount, :targetAccount, :exchangeAmount, CURRENT_TIMESTAMP)"
        );
        insertEurTransaction.bindValue(":accountNumber", eurAccountNumber);
        insertEurTransaction.bindValue(":amount", amountEuro);
        insertEurTransaction.bindValue(":targetAccount", plnAccountNumber);
        insertEurTransaction.bindValue(":exchangeAmount", plnAmount);
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
            "(type, account_number, amount, target_account, exchange_amount, timestamp) "
            "VALUES "
            "('EUR TO PLN', :accountNumber, :amount, :targetAccount, :exchangeAmount, CURRENT_TIMESTAMP)"
        );
        insertEurTransaction.bindValue(":accountNumber", eurAccountNumber);
        insertEurTransaction.bindValue(":amount", amountEuro);
        insertEurTransaction.bindValue(":targetAccount", plnAccountNumber);
        insertEurTransaction.bindValue(":exchangeAmount", plnAmount);

        insertPlnTransaction.prepare(
            "INSERT INTO transaction "
            "(type, account_number, amount, target_account, exchange_amount, timestamp) "
            "VALUES "
            "('EUR TO PLN', :accountNumber, :amount, :targetAccount, :exchangeAmount, CURRENT_TIMESTAMP)"
        );
        insertPlnTransaction.bindValue(":accountNumber", plnAccountNumber);
        insertPlnTransaction.bindValue(":amount", plnAmount);
        insertPlnTransaction.bindValue(":targetAccount", eurAccountNumber);
        insertPlnTransaction.bindValue(":exchangeAmount", amountEuro);
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

bool BankManager::exchangeBetweenAccounts(QString fromAccountNumber, QString toAccountNumber, double fromAmount)
{
    static constexpr double EUR_BUY_RATE = 4.40;   // PLN -> EUR
    static constexpr double EUR_SELL_RATE = 4.10;  // EUR -> PLN

    User* user = m_auth->currentUser();
    if (!user || fromAmount <= 0) return false;

    fromAccountNumber = fromAccountNumber.trimmed();
    toAccountNumber = toAccountNumber.trimmed();

    if (fromAccountNumber.isEmpty() || toAccountNumber.isEmpty()) return false;
    if (fromAccountNumber == toAccountNumber) return false;

    QSqlDatabase db = QSqlDatabase::database();
    if (!db.transaction()) return false;

    QSqlQuery fromQuery(db);
    fromQuery.prepare(
        "SELECT balance, currency, user_id FROM account "
        "WHERE account_number = :accountNumber"
    );
    fromQuery.bindValue(":accountNumber", fromAccountNumber);

    if (!fromQuery.exec() || !fromQuery.next()) {
        qDebug() << "SOURCE ACCOUNT ERROR:" << fromQuery.lastError().text();
        db.rollback();
        return false;
    }

    double fromBalance = fromQuery.value(0).toDouble();
    QString fromCurrency = fromQuery.value(1).toString();
    int fromUserId = fromQuery.value(2).toInt();

    QSqlQuery toQuery(db);
    toQuery.prepare(
        "SELECT balance, currency, user_id FROM account "
        "WHERE account_number = :accountNumber"
    );
    toQuery.bindValue(":accountNumber", toAccountNumber);

    if (!toQuery.exec() || !toQuery.next()) {
        qDebug() << "TARGET ACCOUNT ERROR:" << toQuery.lastError().text();
        db.rollback();
        return false;
    }

    double toBalance = toQuery.value(0).toDouble();
    QString toCurrency = toQuery.value(1).toString();
    int toUserId = toQuery.value(2).toInt();

    if (fromUserId != user->getUserId() || toUserId != user->getUserId()) {
        db.rollback();
        return false;
    }

    if (fromCurrency == toCurrency) {
        db.rollback();
        return false;
    }

    if (fromBalance < fromAmount) {
        db.rollback();
        return false;
    }

    double toAmount = 0.0;
    QString transactionType;

    if (fromCurrency == "PLN" && toCurrency == "EUR") {
        toAmount = fromAmount / EUR_BUY_RATE;
        transactionType = "PLN TO EUR";
    }
    else if (fromCurrency == "EUR" && toCurrency == "PLN") {
        toAmount = fromAmount * EUR_SELL_RATE;
        transactionType = "EUR TO PLN";
    }
    else {
        db.rollback();
        return false;
    }

    double fromNewBalance = fromBalance - fromAmount;
    double toNewBalance = toBalance + toAmount;

    QSqlQuery updateFrom(db);
    updateFrom.prepare(
        "UPDATE account SET balance = :balance "
        "WHERE account_number = :accountNumber"
    );
    updateFrom.bindValue(":balance", fromNewBalance);
    updateFrom.bindValue(":accountNumber", fromAccountNumber);

    QSqlQuery updateTo(db);
    updateTo.prepare(
        "UPDATE account SET balance = :balance "
        "WHERE account_number = :accountNumber"
    );
    updateTo.bindValue(":balance", toNewBalance);
    updateTo.bindValue(":accountNumber", toAccountNumber);

    QSqlQuery insertFromTransaction(db);
    insertFromTransaction.prepare(
        "INSERT INTO transaction "
        "(type, account_number, amount, target_account, exchange_amount, timestamp) "
        "VALUES "
        "(:type, :accountNumber, :amount, :targetAccount, :exchangeAmount, CURRENT_TIMESTAMP)"
    );
    insertFromTransaction.bindValue(":type", transactionType);
    insertFromTransaction.bindValue(":accountNumber", fromAccountNumber);
    insertFromTransaction.bindValue(":amount", fromAmount);
    insertFromTransaction.bindValue(":targetAccount", toAccountNumber);
    insertFromTransaction.bindValue(":exchangeAmount", toAmount);

    QSqlQuery insertToTransaction(db);
    insertToTransaction.prepare(
        "INSERT INTO transaction "
        "(type, account_number, amount, target_account, exchange_amount, timestamp) "
        "VALUES "
        "(:type, :accountNumber, :amount, :targetAccount, :exchangeAmount, CURRENT_TIMESTAMP)"
    );
    insertToTransaction.bindValue(":type", transactionType);
    insertToTransaction.bindValue(":accountNumber", toAccountNumber);
    insertToTransaction.bindValue(":amount", toAmount);
    insertToTransaction.bindValue(":targetAccount", fromAccountNumber);
    insertToTransaction.bindValue(":exchangeAmount", fromAmount);

    if (!updateFrom.exec() ||
        !updateTo.exec() ||
        !insertFromTransaction.exec() ||
        !insertToTransaction.exec()) {

        qDebug() << "EXCHANGE BETWEEN ACCOUNTS ERROR:"
            << updateFrom.lastError().text()
            << updateTo.lastError().text()
            << insertFromTransaction.lastError().text()
            << insertToTransaction.lastError().text();

        db.rollback();
        return false;
    }

    if (!db.commit()) {
        qDebug() << "EXCHANGE BETWEEN ACCOUNTS COMMIT ERROR:" << db.lastError().text();
        db.rollback();
        return false;
    }

    for (const QVariant& item : user->getAccounts()) {
        Account* account = qvariant_cast<Account*>(item);
        if (!account) continue;

        if (account->getAccountNumber() == fromAccountNumber) {
            account->setBalance(fromNewBalance);
        }
        else if (account->getAccountNumber() == toAccountNumber) {
            account->setBalance(toNewBalance);
        }
    }

    updateUserTransactions(true);
    return true;
}



