import QtQuick 6.10
import QtQuick.Controls.Basic 6.10

Rectangle {
    id: atmSelectionRoot
    anchors.fill: parent
    color: "#f5f5f5"

    Button {
        id: backBtn
        width: 50
        height: 50
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 20
        
        Text {
            text: "❮"
            color: backBtn.hovered ? "#848587" : "#282929"
            anchors.centerIn: parent
            font.pixelSize: 18
            font.bold: true
        }
        background: Rectangle {
            radius: 25
            color: "#f5f5f5"
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
            } 
        }
        onClicked: {
            atmSelectionRoot.StackView.view.pop()
        }
    }

    Column {
        id: headerCol
        anchors.top: parent.top
        anchors.topMargin: 80
        width: parent.width
        spacing: 10

        Text {
            text: "Hello " + appController.atm.userName + " " + appController.atm.userSurname
            font.bold: true
            font.pixelSize: 28
            color: "#281C9D"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: "Select an operation"
            font.pixelSize: 18
            color: "#555"
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 30
        width: 320
        topPadding: 30

        Button {
            id: withdrawBtn
            width: withdrawBtn.hovered ? parent.width : parent.width -10
            height: 50
            anchors.horizontalCenter: parent.horizontalCenter
            
            Text {
                text: "Withdraw Cash"
                font.bold: true
                font.pixelSize: 18
                color: "white"
                anchors.centerIn: parent
            }

            background: Rectangle {
                radius: 16
                color: withdrawBtn.hovered ? "#3A2DCD" : "#281c9d"
                layer.enabled: true
            }
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: {
                    atmSelectionRoot.StackView.view.push("WithdrawScreen.qml")
                }
            }
        }

        Button {
            id: depositBtn
            width: depositBtn.hovered ? parent.width : parent.width -10
            height: 50
            anchors.horizontalCenter: parent.horizontalCenter
            
            Text {
                text: "Deposit Cash"
                font.bold: true
                font.pixelSize: 18
                color: "#281c9d"
                anchors.centerIn: parent
            }

            background: Rectangle {
                radius: 16
                color: depositBtn.hovered ? "#f0f0f5" : "white"
                border.color: "#281c9d"
                border.width: 2
            }
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: {
                    atmSelectionRoot.StackView.view.push("DepositScreen.qml")
                }
            }
        }
    }
}