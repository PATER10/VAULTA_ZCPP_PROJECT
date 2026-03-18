#include "DatabaseManager.h"

DatabaseManager::DatabaseManager(QObject* parent) : QObject(parent)
{
    //prepare PostgreSQL driver
    m_db = QSqlDatabase::addDatabase("QPSQL");
}

DatabaseManager::~DatabaseManager()
{
    if (m_db.isOpen()) {
        m_db.close();
    }
}

bool DatabaseManager::connectToDatabase()
{
    m_db.setHostName("localhost");
    m_db.setDatabaseName("VAULTA");
    m_db.setUserName("postgres");
    m_db.setPassword("student");
    m_db.setPort(5432);

    if (!m_db.open()) {
        qDebug() << "ERROR: No connection with Database!!!" << m_db.lastError().text();
        return false;
    }

    qDebug() << "SUCCESS: Connected with PostgreSQL Database.";
}

bool DatabaseManager::isOpen() const
{
    return m_db.isOpen();
}
