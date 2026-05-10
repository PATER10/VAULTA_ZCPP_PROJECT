#pragma once
#include <QObject>
#include<QTranslator>

class LanguageManager : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QString updateTr READ updateTr NOTIFY languageChanged)
	Q_PROPERTY(QString currentLanguage READ currentLanguage NOTIFY languageChanged)

public:
	explicit LanguageManager(QObject *parent = nullptr);
	QString updateTr() const;
	QString currentLanguage() const;
	
	Q_INVOKABLE void setLanguage(const QString& lang);
	void loadSavedLanguage();

signals:
	void languageChanged();

private:
	QTranslator m_translator;
	QString m_currentLang;
};