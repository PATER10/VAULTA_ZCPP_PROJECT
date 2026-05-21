import QtQuick 6.10
import QtQuick.Controls.Basic 6.10

Item {
    id: transactionsViewRoot
    anchors.fill: parent

    Component.onCompleted: {
        appController.bankManager.updateUserTransactions(false)
    }
            
    property int contentPadding: 30

    Column {
        id: headerContainer
        width: parent.width
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: transactionsViewRoot.contentPadding
        spacing: 25

        Text {
            text: qsTr("Transaction History")
            font.pixelSize: 24
            font.bold: true
            color: "#281c9d"
        }
        
        Text {
            text: qsTr("Total transactions: ") + appController.auth.currentUser.transactions.length
            font.pixelSize: 14
            color: "#888"
        }
    }

    ListView {
        id: transactionList
                
        anchors.top: headerContainer.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: transactionsViewRoot.contentPadding
        anchors.topMargin: 15

        bottomMargin: 20
                
        clip: true
        spacing: 15
                
        model: appController.auth.currentUser.transactions

        delegate: Rectangle {
            width: parent.width - 80
            height: 90
            radius: 12
            color: "white"
            border.color: "#eeeeee"; border.width: 1

            Column {
                anchors.fill: parent

                Rectangle {
                    width: parent.width; height: 30; color: "transparent"
                    Text {
                        text: modelData.date
                        font.pixelSize: 11; font.bold: true; color: "#999999"
                        anchors.left: parent.left; anchors.leftMargin: 15
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                        
                Rectangle { width: parent.width - 30; height: 1; color: "#f0f0f0"; anchors.horizontalCenter: parent.horizontalCenter }

                Item {
                    id: transactionRow
                    width: parent.width; height: 59
                    property string activeCurrency: appController.auth.currentUser.account.currency

                    property bool isExchange: modelData.type === "PLN TO EUR" || modelData.type === "EUR TO PLN"

                    property bool isIncoming: {
                        if (modelData.type === "TRANSFER IN" || modelData.type === "DEPOSIT") return true

                        if (modelData.type === "PLN TO EUR" && activeCurrency === "EUR") return true
                        if (modelData.type === "EUR TO PLN" && activeCurrency === "PLN") return true

                        return false
                    }
                            
                    Rectangle {
                        id: iconBg
                        width: 36; height: 36; radius: 18
                        color: transactionRow.isIncoming ? "#e8f5e9" : "#ffebee"
                        anchors.left: parent.left; anchors.leftMargin: 15
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            text: transactionRow.isIncoming ? "+" : "-"
                            font.pixelSize: 20; font.bold: true
                            color: transactionRow.isIncoming ? "#2ecc71" : "#e74c3c"
                            anchors.centerIn: parent; anchors.verticalCenterOffset: -1
                        }
                    }

                    Column {
                        anchors.left: iconBg.right; anchors.leftMargin: 15
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 3
                        Text {
                            text: {
                                if (modelData.type === "TRANSFER OUT") return qsTr("Outgoing Transfer")
                                if (modelData.type === "TRANSFER IN") return qsTr("Incoming Transfer")
                                if (modelData.type === "WITHDRAWAL") return qsTr("ATM")
                                if (modelData.type === "DEPOSIT") return qsTr("ATM")
                                if (modelData.type === "PLN TO EUR") return qsTr("PLN → EUR")
                                if (modelData.type === "EUR TO PLN") return qsTr("EUR → PLN")
                                return qsTr("Transaction")
                            }
                            font.bold: true; font.pixelSize: 14; color: "black"
                        }
                        Text {
                            text: {
                                if (modelData.type === "TRANSFER OUT") {return qsTr("to: ")+ modelData.targetAccount}
                                if (modelData.type === "TRANSFER IN") {return qsTr("FROM: ")+ modelData.targetAccount}
                                if (modelData.type === "WITHDRAWAL") return qsTr("Cash Withdrawal")
                                if (modelData.type === "DEPOSIT") return qsTr("Cash Deposit")
                                if (modelData.type === "PLN TO EUR" || modelData.type === "EUR TO PLN") return qsTr("Currency exchange")
                                return qsTr("Transaction")
                            }
                            font.pixelSize: 11; color: "#999999"
                            width: 160; elide: Text.ElideRight
                        }
                    }
                    Column {
                        id: transactionCol
                        property string exchangeCurrency: {
                            if (!transactionRow.isExchange) return ""

                            if (modelData.type === "PLN TO EUR") {
                                return transactionRow.activeCurrency === "PLN" ? "EUR" : "PLN"
                            }

                            if (modelData.type === "EUR TO PLN") {
                                return transactionRow.activeCurrency === "EUR" ? "PLN" : "EUR"
                            }

                            return ""
                        }

                        property bool isExchangeAmountIncoming: {
                            if (!transactionRow.isExchange) return false

                            if (modelData.type === "PLN TO EUR") {
                                return transactionRow.activeCurrency === "PLN" ? true : false
                            }

                            if (modelData.type === "EUR TO PLN") {
                                return transactionRow.activeCurrency === "EUR" ? true : false
                            }

                            return false
                        }
                        anchors.right: parent.right; anchors.rightMargin: 15
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            text: Number(modelData.amount).toFixed(2) + " " + appController.auth.currentUser.account.currency
                            font.bold: true; font.pixelSize: 14
                            color: transactionRow.isIncoming ? "#2ecc71" : "#e74c3c"
                        }
                        Text{
                            visible: transactionRow.isExchange
                            text: (transactionCol.isExchangeAmountIncoming ? "+" : "-" )
                                + Number(modelData.exchangeAmount).toFixed(2) 
                                + " "
                                + transactionCol.exchangeCurrency
                            font.bold: true; font.pixelSize: 12
                            color: "#999999"
                        }
                    }
                }
            }
        }
                
        ScrollBar.vertical: ScrollBar { 
            active: true 
            width: 10
        }
    }
}