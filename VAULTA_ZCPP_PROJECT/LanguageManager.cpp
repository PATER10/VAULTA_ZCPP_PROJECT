#include "LanguageManager.h"
#include <QGuiApplication.h>
#include <QSettings>

LanguageManager::LanguageManager(QObject* parent)
{
	m_currentLang = "en";
}

QString LanguageManager::updateTr() const
{
	return "";
}

QString LanguageManager::currentLanguage() const
{
	return m_currentLang;
}

Q_INVOKABLE void LanguageManager::setLanguage(const QString& lang)
{
	if (m_currentLang == lang) return;

	qApp->removeTranslator(&m_translator);

	if (lang == "pl") {
		if (m_translator.load("./Translations/vaulta_" + lang + ".qm")) {
			qApp->installTranslator(&m_translator);
			m_currentLang = "pl";
		}
	}
	else {
		m_currentLang = "en";
	}
	QSettings settings;
	settings.setValue("language", m_currentLang);
	settings.sync();

	emit languageChanged();
}

void LanguageManager::loadSavedLanguage()
{
	QSettings settings("PATER10", "VaultaApp");
	QString savedLang = settings.value("language", "en").toString();

	setLanguage(savedLang);
}
