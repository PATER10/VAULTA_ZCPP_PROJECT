import QtQuick 6.10
import QtQuick.Controls.Basic 6.10

Item {
    id: transactionsViewRoot
    anchors.fill: parent
    
    property var allTransactions: []
    property string accountCurrency: "PLN"
            
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
            text: qsTr("Total transactions: ") + transactionsViewRoot.allTransactions.length
            font.pixelSize: 14
            color: "#888"
        }
    }

    ListView {
        id: historyList
        anchors.top: headerContainer.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: transactionsViewRoot.contentPadding
        anchors.topMargin: 20
        
        bottomMargin: 20
        clip: true
        spacing: 15
        
        model: transactionsViewRoot.allTransactions

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
                        color: (modelData.type === "IN") ? "#e8f5e9" : "#ffebee"
                        anchors.left: parent.left; anchors.leftMargin: 15
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            text: (modelData.type === "IN") ? "+" : "-"
                            font.pixelSize: 20; font.bold: true
                            color: (modelData.type === "IN") ? "#2ecc71" : "#e74c3c"
                            anchors.centerIn: parent; anchors.verticalCenterOffset: -1
                        }
                    }

                    Column {
                        anchors.left: iconBg.right; anchors.leftMargin: 15
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 3
                        Text {
                            text: modelData.title
                            font.bold: true; font.pixelSize: 14; color: "black"
                        }
                        Text {
                            text: modelData.description
                            font.pixelSize: 11; color: "#999999"
                            width: 160; elide: Text.ElideRight
                        }
                    }

                    Text {
                        text: modelData.amount + " " + transactionsViewRoot.accountCurrency
                        font.bold: true; font.pixelSize: 14
                        color: (modelData.type === "IN") ? "#2ecc71" : "#e74c3c"
                        anchors.right: parent.right; anchors.rightMargin: 15
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
        
        ScrollBar.vertical: ScrollBar { active: true; width: 10 }
    }
}