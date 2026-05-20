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
            addAccountPopup.open()
        }
        
        ToolTip.visible: hovered
        ToolTip.text: qsTr("Add new account")
    }
    Popup {
        id: addAccountPopup
        anchors.centerIn: parent
        width: 280
        height: 170
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: "white"
            radius: 14
            border.color: "#281c9d"
            border.width: 2
        }

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            Text {
                text: qsTr("Choose account")
                font.pixelSize: 18
                font.bold: true
                color: "#281c9d"
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
            }

            Button {
                width: parent.width
                height: 45

                contentItem: Text {
                    text: qsTr("Euro Account")
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 10
                    color: parent.hovered ? "#3A2DCD" : "#281c9d"
                }

                onClicked: {
                    if (appController.bankManager.addCurrencyAccount("EUR")) {
                        addAccountPopup.close()
                    } else {
                        console.log("Could not add EUR account")
                    }
                }
            }
        }
    }
}