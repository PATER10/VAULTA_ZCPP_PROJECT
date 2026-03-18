#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QSqlDatabase>
#include <QDebug>
#include <QSqlError>
#include <QQmlContext>
#include "DatabaseManager.h"
#include "AppController.h"

int main(int argc, char *argv[])
{
    
#if defined(Q_OS_WIN) && QT_VERSION_CHECK(5, 6, 0) <= QT_VERSION && QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);

    DatabaseManager dbManager;
    if (!dbManager.connectToDatabase()) {
        qDebug() << "CRITICAL ERROR: No connection with PostgreSQL!!!";
    }

    AppController appController;

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("backend", &appController);
    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/vaulta_zcpp_project/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;
    return app.exec();
}
