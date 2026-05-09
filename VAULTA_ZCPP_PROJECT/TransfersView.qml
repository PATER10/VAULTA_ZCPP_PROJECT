import QtQuick 6.10
import QtQuick.Controls.Basic 6.10

Item {
    id: transfersViewRoot
    anchors.fill: parent
    
    signal transferSuccessful(string newBalance)

    property int contentPadding: 30

    Column {
        id: headerContainer
        width: parent.width
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: transfersViewRoot.contentPadding
        spacing: 25

        Text {
            text: qsTr("Make a Transfer")
            font.pixelSize: 24
            font.bold: true
            color: "#281c9d"
        }
  
        Column {
            spacing: 5
            Row{
                Text { 
                    text: qsTr("Available Funds: ")
                    color: "#343434"
                    font.pixelSize: 14
                    font.bold: true
                }
                Text {
                    text: Number(appController.auth.currentUser.account.balance).toFixed(2) + " " + appController.auth.currentUser.account.currency
                    color: "#281c9d"
                    font.pixelSize: 14
                    font.bold: true
                }
            }
        }

        Column {
            width: parent.width
            spacing: 15

            TextField {
                id: targetAccountInput
                placeholderText: qsTr("Target Account Number")
                palette.placeholderText: "gray"
                palette.text: "black"
                width: parent.width
                height: 45
                font.pixelSize: 16
                leftPadding: 15
                
                background: Rectangle {
                    radius: 12
                    border.color: parent.activeFocus ? "#281C9D" : "#e0e0e0"
                    border.width: parent.activeFocus ? 2 : 1
                    color: "white"
                    Behavior on color { ColorAnimation { duration: 200 } }
                    Behavior on border.color { ColorAnimation { duration: 200 } }
                    Behavior on border.width { NumberAnimation { duration: 200 } }
                }
            }

            TextField {
                id: amountInput
                placeholderText: qsTr("Amount")
                palette.placeholderText: "gray"
                palette.text: "black"
                width: parent.width
                height: 45
                font.pixelSize: 16
                leftPadding: 15
                
                validator: DoubleValidator { bottom: 0.01; decimals: 2 }
                inputMethodHints: Qt.ImhFormattedNumbersOnly

                background: Rectangle {
                    radius: 12
                    border.color: parent.activeFocus ? "#281C9D" : "#e0e0e0"
                    border.width: parent.activeFocus ? 2 : 1
                    color: "white"
                    Behavior on color { ColorAnimation { duration: 200 } }
                    Behavior on border.color { ColorAnimation { duration: 200 } }
                    Behavior on border.width { NumberAnimation { duration: 200 } }
                }
            }
            
            Text {
                id: errorMsg
                visible: false
                text: "Error message"
                color: "#d40f12"
                font.pixelSize: 14
            }

            Button {
                id: sendBtn
                width: sendBtn.hovered ? parent.width+10 : parent.width
                height: 45
                Behavior on width{ NumberAnimation { duration: 200 } }

                contentItem: Text { 
                    text: qsTr("SEND MONEY")
                    color: "white"
                    font.bold: true
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                background: Rectangle {
                    radius: 12
                    color: sendBtn.hovered ? "#3A2DCD" : "#281c9d"
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                onClicked: {
                    errorMsg.visible = false
                    
                    var result = bankSystem.makeTransfer(transfersViewRoot.accountNumber, targetAccountInput.text, amountInput.text)

                    if (result.success === true) {
                        transfersViewRoot.transferSuccessful(result.newBalance)
                        successPopup.open()
                        
                        targetAccountInput.text = ""
                        amountInput.text = ""
                    } else {
                        errorMsg.text = result.message
                        errorMsg.visible = true
                    }
                }
            }
        }
    }

    Popup {
        id: successPopup
        anchors.centerIn: parent
        width: 300
        height: 200
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: "white"
            radius: 16
            border.color: "#281C9D"
            border.width: 2
        }

        Column {
            anchors.centerIn: parent
            spacing: 20

            Text {
                text: qsTr("Success!")
                color: "#281C9D"
                font.bold: true
                font.pixelSize: 24
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: qsTr("Funds have been transferred.")
                color: "#555"
                font.pixelSize: 16
            }
            Button {
                id: okBtn;
                width: okBtn.hovered ? 110 : 100
                height: 35
                anchors.horizontalCenter: parent.horizontalCenter
                Behavior on width{ NumberAnimation { duration: 200 } }
                background: Rectangle { 
                    radius: 8 
                    color: okBtn.hovered ? "#3A2DCD" : "#281c9d"
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }
                Text { text: "OK"; color: "white"; font.bold: true; anchors.centerIn: parent; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter;  }
                onClicked: successPopup.close()
            }
        }
    }
}