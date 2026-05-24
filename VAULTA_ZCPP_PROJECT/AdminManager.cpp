#include "AdminManager.h"
#include <QSqlDatabase>
#include <bcrypt.h>

AdminManager::AdminManager(QObject* parent)
    : QObject(parent)
{
}

QVariantList AdminManager::getAllUsers()
{
    QVariantList users;

    QSqlQuery query;
    query.prepare(
        "SELECT id, name, surname, is_active "
        "FROM \"user\" "
        "WHERE role != 'admin' "
        "ORDER BY id ASC"
    );

    if (!query.exec()) {
        qDebug() << "GET USERS ERROR:" << query.lastError().text();
        return users;
    }

    while (query.next()) {
        QVariantMap user;
        user["id"] = query.value(0).toInt();
        user["name"] = query.value(1).toString();
        user["surname"] = query.value(2).toString();
        user["is_active"] = query.value(3).toBool();
        users.append(user);
    }

    return users;
}

bool AdminManager::updateUserProfile(int userId, QString newName, QString newSurname)
{
    newName = newName.trimmed();
    newSurname = newSurname.trimmed();

    if (userId <= 0 || newName.isEmpty() || newSurname.isEmpty()) {
        return false;
    }

    QSqlQuery query;
    query.prepare(
        "UPDATE \"user\" "
        "SET name = :name, surname = :surname "
        "WHERE id = :id"
    );

    query.bindValue(":name", newName);
    query.bindValue(":surname", newSurname);
    query.bindValue(":id", userId);

    if (!query.exec()) {
        qDebug() << "UPDATE USER ERROR:" << query.lastError().text();
        return false;
    }

    return query.numRowsAffected() > 0;
}

bool AdminManager::toggleUserActive(int userId, bool isActive)
{
    if (userId <= 0) return false;

    QSqlQuery query;
    query.prepare(
        "UPDATE \"user\" "
        "SET is_active = :active "
        "WHERE id = :id"
    );

    query.bindValue(":active", isActive);
    query.bindValue(":id", userId);

    if (!query.exec()) {
        qDebug() << "TOGGLE USER ACTIVE ERROR:" << query.lastError().text();
        return false;
    }

    return query.numRowsAffected() > 0;
}

bool AdminManager::deleteUser(int userId)
{
    if (userId <= 0) return false;

    QSqlDatabase db = QSqlDatabase::database();
    if (!db.transaction()) return false;

    QSqlQuery deleteTransactions(db);
    deleteTransactions.prepare(
        "DELETE FROM transaction "
        "WHERE account_number IN (SELECT account_number FROM account WHERE user_id = :uid) "
        "OR target_account IN (SELECT account_number FROM account WHERE user_id = :uid)"
    );
    deleteTransactions.bindValue(":uid", userId);

    QSqlQuery deleteCards(db);
    deleteCards.prepare(
        "DELETE FROM card "
        "WHERE account_id IN (SELECT id FROM account WHERE user_id = :uid)"
    );
    deleteCards.bindValue(":uid", userId);

    QSqlQuery deleteAccounts(db);
    deleteAccounts.prepare("DELETE FROM account WHERE user_id = :uid");
    deleteAccounts.bindValue(":uid", userId);

    QSqlQuery deleteUserQuery(db);
    deleteUserQuery.prepare("DELETE FROM \"user\" WHERE id = :uid AND role != 'admin'");
    deleteUserQuery.bindValue(":uid", userId);

    if (!deleteTransactions.exec() ||
        !deleteCards.exec() ||
        !deleteAccounts.exec() ||
        !deleteUserQuery.exec()) {

        qDebug() << "DELETE USER ERROR:"
            << deleteTransactions.lastError().text()
            << deleteCards.lastError().text()
            << deleteAccounts.lastError().text()
            << deleteUserQuery.lastError().text();

        db.rollback();
        return false;
    }

    if (!db.commit()) {
        qDebug() << "DELETE USER COMMIT ERROR:" << db.lastError().text();
        db.rollback();
        return false;
    }

    return deleteUserQuery.numRowsAffected() > 0;
}

bool AdminManager::resetUserPassword(int userId, QString newPassword)
{
    if (userId <= 0 || newPassword.length() < 5) {
        return false;
    }

    std::string hashedPassword = bcrypt::generateHash(newPassword.toStdString(), 5);

    QSqlQuery query;
    query.prepare(
        "UPDATE \"user\" "
        "SET password = :password "
        "WHERE id = :id"
    );

    query.bindValue(":password", QString::fromStdString(hashedPassword));
    query.bindValue(":id", userId);

    if (!query.exec()) {
        qDebug() << "RESET PASSWORD ERROR:" << query.lastError().text();
        return false;
    }

    return query.numRowsAffected() > 0;
}
