import QtQuick 6.10
import QtQuick.Controls.Basic 6.10

Item{
    id: homeViewRoot
    anchors.fill: parent
        
    property int contentPadding: 30

    Component.onCompleted: {
        appController.bankManager.updateUserTransactions(true)
    }

    Column {
        id: headerContainer
        width: parent.width
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: homeViewRoot.contentPadding
        spacing: 25

        Text {
            text: qsTr("Dashboard")
            font.pixelSize: 24
            font.bold: true
            color: "#281c9d"
        }
        ListView{
            id: accountsList
            width: parent.width
            height: 150
            orientation: ListView.Horizontal
            spacing: 15
            clip: true

            model: appController.auth.currentUser.accounts

            delegate: Rectangle{
                width:300
                height: 140
                radius: 16
                color: "white"

                border.color: modelData.accountNumber === appController.auth.currentUser.account.accountNumber
                    ? "#281c9d" : "#e0e0e0"
                border.width: modelData.accountNumber === appController.auth.currentUser.account.accountNumber
                    ? 2 : 1

                MouseArea{
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        appController.auth.currentUser.setActiveAccountByNumber(modelData.accountNumber)
                        appController.bankManager.updateUserTransactions(true)
                    }
                }
                Column{
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 10

                    Row{
                        width: parent.width
                        Column {
                            width: parent.width - 50
                            Text {
                                text: modelData.currency === "PLN" ? qsTr("Main Account") : qsTr("Currency Account")
                                font.bold: true
                                font.pixelSize: 14
                                color: "black"
                            }

                            Text {
                                text: modelData.accountType
                                font.pixelSize: 12
                                color: "#888"
                            }
                        }
                        Rectangle {
                            width: 40
                            height: 40
                            radius: 20
                            color: "#f0f0f5"

                            Text {
                                text: modelData.currency
                                anchors.centerIn: parent
                                font.bold: true
                                color: "#281c9d"
                                font.pixelSize: 10
                            }
                        }
                    }
                    Text {
                        text: Number(modelData.balance).toFixed(2) + " " + modelData.currency
                        font.pixelSize: 20
                        font.bold: true
                        color: "#281c9d"
                    }

                    Text {
                        text: modelData.accountNumber
                        font.pixelSize: 14
                        color: "#888"
                    }
                }
            }
        }

        Text {
            text: qsTr("Recent Transactions")
            font.pixelSize: 18
            font.bold: true
            color: "#333"
        }
    }

        ListView {
        id: transactionList
                
        anchors.top: headerContainer.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: homeViewRoot.contentPadding
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
                    width: parent.width; height: 59
                            
                    Rectangle {
                        id: iconBg
                        width: 36; height: 36; radius: 18
                        color: (modelData.type === "TRANSFER IN" || modelData.type === "DEPOSIT") ? "#e8f5e9" : "#ffebee"
                        anchors.left: parent.left; anchors.leftMargin: 15
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            text: (modelData.type === "TRANSFER IN" || modelData.type === "DEPOSIT") ? "+" : "-"
                            font.pixelSize: 20; font.bold: true
                            color: (modelData.type === "TRANSFER IN" || modelData.type === "DEPOSIT") ? "#2ecc71" : "#e74c3c"
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
                                return qsTr("Transaction")
                            }
                            font.pixelSize: 11; color: "#999999"
                            width: 160; elide: Text.ElideRight
                        }
                    }

                    Text {
                        text: Number(modelData.amount).toFixed(2) + " " + appController.auth.currentUser.account.currency
                        font.bold: true; font.pixelSize: 14
                        color: (modelData.type === "TRANSFER IN"  || modelData.type === "DEPOSIT") ? "#2ecc71" : "#e74c3c"
                        anchors.right: parent.right; anchors.rightMargin: 15
                        anchors.verticalCenter: parent.verticalCenter
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