#pragma once
#include <QObject>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QDebug>

class DatabaseManager : public QObject {
	Q_OBJECT
public:
	explicit DatabaseManager(QObject* parent = nullptr);
	~DatabaseManager();

	//Connection initializer
	bool connectToDatabase();

	//Connection checker
	bool isOpen() const;

private:
	QSqlDatabase m_db;
};


