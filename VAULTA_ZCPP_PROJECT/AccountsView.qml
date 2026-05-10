import QtQuick 6.10
import QtQuick.Controls.Basic 6.10

Item{
    id: accountViewRoot
    anchors.fill: parent
             
    property int contentPadding: 30

    Column {
        id: headerContainer
        width: parent.width
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: accountViewRoot.contentPadding
        spacing: 25

        Text {
            text: qsTr("My accounts")
            font.pixelSize: 24
            font.bold: true
            color: "#281c9d"
        }

        Rectangle {
            width: 300
            height: 140
            radius: 16
            color: "white"
                    
            border.color: "#e0e0e0"
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 10

                Row {
                    width: parent.width
                            
                    Column {
                        width: parent.width - 50
                        Text { text: qsTr("Main Account"); font.bold: true; font.pixelSize: 14; color: "black" }
                        Text { text: qsTr("Standard"); font.pixelSize: 12; color: "#888" }
                    }

                    Rectangle {
                        width: 40
                        height: 40
                        radius: 20
                        color: "#f0f0f5"
                        Text { text: appController.auth.currentUser.account.currency; anchors.centerIn: parent; font.bold: true; color: "#281c9d"; font.pixelSize: 10 }
                    }
                }

                Text {
                    text: Number(appController.auth.currentUser.account.balance).toFixed(2) + " " + appController.auth.currentUser.account.currency
                    font.pixelSize: 20
                    font.bold: true
                    color: "#281c9d"
                }
                        
                Text {
                    text: appController.auth.currentUser.account.accountNumber
                    font.pixelSize: 14
                    color: "#888"
                }
            }
        }
    }
    Button {
        id: addAccountBtn
        width: addAccountBtn.hovered ? 42 : 40
        height: addAccountBtn.hovered ? 42 : 40
        
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 40 
        
        layer.enabled: true
        
        background: Rectangle {
            radius: width / 2
            color: addAccountBtn.hovered ? "#3A2DCD" : "#281c9d"
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
            }
        }

        Text {
            text: "+"
            font.pixelSize: 36
            color: "white"
            anchors.centerIn: parent
            anchors.verticalCenter: verticalCenter
            anchors.horizontalCenter: horizontalCenter
            bottomPadding: 5
            anchors.verticalCenterOffset: -2
        }

        onClicked: {
            console.log("Add currency account clicked (Coming soon)")
        }
        
        ToolTip.visible: hovered
        ToolTip.text: qsTr("Add new account (Coming Soon)")
    }
}