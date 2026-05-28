import QtQuick 6.10
import QtQuick.Controls.Basic 6.10

Rectangle {
    id: withdrawRoot
    anchors.fill: parent
    color: "#f5f5f5"

    Button {
        id: backBtn
        width: 50 
        height: 50
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 20
        Text { text: "❮"; color: "#282929"; anchors.centerIn: parent; font.pixelSize: 18; font.bold: true }
        background: Rectangle { 
            radius: 25 
            color: "#f5f5f5" 
            MouseArea { anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor 
                onClicked: withdrawRoot.StackView.view.pop() 
            }
        }
        onClicked: {
            withdrawRoot.StackView.view.pop()
        }
    }

    Column {
        anchors.centerIn: parent
        width: 320
        spacing: 25

        Text {
            text: qsTr("Withdraw Cash")
            font.bold: true; font.pixelSize: 24; color: "#281C9D"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Row{
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            Text { 
                text: qsTr("Available Funds: ")
                color: "#343434"
                font.pixelSize: 14
                font.bold: true
            }
            Text {
                text: appController.atm.currentBalance.toFixed(2) + "PLN"
                color: "#281c9d"
                font.pixelSize: 14
                font.bold: true
            }
        }

        Column {
            width: parent.width; spacing: 10
            
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
        }

        Text {
            id: errorMsg
            visible: false
            text: qsTr("Error")
            color: "#d40f12"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Button {
            id: confirmBtn
            anchors.horizontalCenter: parent.horizontalCenter
            width: confirmBtn.hovered ? parent.width : parent.width - 10
            height: 45
            Behavior on width{ NumberAnimation { duration: 200 } }
            background: Rectangle {
                radius: 12
                color: confirmBtn.hovered ? "#3A2DCD" : "#281c9d"
                MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: confirmBtn.clicked() }
            }
            contentItem: Text { text: qsTr("WITHDRAW"); color: "white"; font.bold: true; font.pixelSize: 16; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }

            onClicked: {
                errorMsg.visible = false
                let amount = parseFloat(amountInput.text)
                
                if (isNaN(amount) || amount <= 0) {
                    errorMsg.text = qsTr("Enter a valid amount")
                    errorMsg.visible = true
                    return
                }
                if (appController.atm.withdraw(amount)) {
                    successPopup.open()
                    amountInput.text = ""
                } else {
                    errorMsg.text = qsTr("Insufficient funds or transaction error.")
                    errorMsg.visible = true
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
                text: qsTr("Please, take your cash")
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
                Text { text: qsTr("DONE"); color: "white"; font.bold: true; anchors.centerIn: parent; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter;  }
                onClicked: {
                    withdrawRoot.StackView.view.pop();
                      
                    
                }
            }
        }
    }
}