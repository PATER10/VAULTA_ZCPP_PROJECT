#include "DatabaseManager.h"
#include "envReader.cpp"

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
    Env::load(".env");

    m_db.setHostName(qgetenv("DB_HOST"));
    m_db.setDatabaseName("VAULTA");
    m_db.setUserName(qgetenv("DB_USER"));
    m_db.setPassword(qgetenv("DB_PASS"));
    int port = qgetenv("DB_PORT").toInt();
    m_db.setPort(port > 0 ? port : 5432);

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
