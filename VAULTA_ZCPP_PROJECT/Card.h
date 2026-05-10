#pragma once
#include <string>
#include <QObject>

using namespace std;

class Card : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QString cardNumber READ getCardNumber CONSTANT)
	Q_PROPERTY(QString expiryDate READ getExpiryDate NOTIFY expiryChanged())
	Q_PROPERTY(QString pin READ getPin NOTIFY pinChanged())

private:
	int m_CardId, m_accId;
	QString m_cardNumber, m_pin, m_expiryDate;

public:
	explicit Card(QObject* parent = nullptr) : QObject(parent) {}
	Card(int accId, QString cardNumber, QString pin, QString expiryDate);
	int getCardId() const;
	int getAccId() const;
	QString getCardNumber() const;
	void setCardNumber(QString cardNumber);
	QString getPin() const;
	void setPin(QString Pin);
	QString getExpiryDate() const;
	void setExpiryDate(QString expiryDate);
	static string generateCardNumber();
signals:
	void expiryChanged();
	void pinChanged();
};

