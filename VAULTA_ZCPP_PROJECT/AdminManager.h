#pragma once

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QString>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>

class AdminManager : public QObject
{
    Q_OBJECT

public:
    explicit AdminManager(QObject* parent = nullptr);

    Q_INVOKABLE QVariantList getAllUsers();
    Q_INVOKABLE bool updateUserProfile(int userId, QString newName, QString newSurname);
    Q_INVOKABLE bool toggleUserActive(int userId, bool isActive);
    Q_INVOKABLE bool deleteUser(int userId);
    Q_INVOKABLE bool resetUserPassword(int userId, QString newPassword);
};