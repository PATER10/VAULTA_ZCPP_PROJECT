import QtQuick 6.10
import QtQuick.Controls.Basic 6.10

Rectangle {
    id: atmRoot
    anchors.fill: parent
    color: "#f5f5f5"

    Button {
                id: backBtn
                width: 50
                height: 50
                Text{
                    text: "❮"
                    color: backBtn.hovered ? "#848587" : "#282929"
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
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
                    atmRoot.StackView.view.pop()
                    atmSignInErr.visible = false
                }
    }

        Column {
            anchors.centerIn: parent
            spacing: 20
            width: 300
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter 

            Text {
                text: "Welcome to ATM"
                color: "#281C9D"
                font.bold: true
                font.pixelSize: 24
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "Hello there, Enter your card number and PIN"
                font.bold: true
                font.pixelSize: 16
                color: "#343434"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            TextField {
                id: userCardNumberInput
                placeholderText: "Card Number"
                palette.placeholderText: "gray"
                palette.text: "black"
                height: 40
                width: parent.width
                font.pixelSize: 16
                leftPadding: 15 
                rightPadding: 15
                validator: IntValidator {bottom: 0;} 
                background: Rectangle {
                    radius: 12
                    border.color: parent.activeFocus ? "#281C9D" : "#848587"
                    color: parent.activeFocus ? "#FFFFFF" : "#f5f5f5"
                    border.width: parent.activeFocus ? 2 : 1

                    Behavior on color { ColorAnimation { duration: 200 } }
                    Behavior on border.color { ColorAnimation { duration: 200 } }
                    Behavior on border.width { NumberAnimation { duration: 200 } }
                }
            }

            TextField {
                id: pinInput
                placeholderText: "PIN (4 digits)"
                palette.placeholderText: "gray"
                palette.text: "black"
                height: 40
                width: parent.width
                echoMode: TextInput.Password
                font.pixelSize: 16
                leftPadding: 15 
                rightPadding: 15
                background: Rectangle {
                    radius: 12
                    border.color: parent.activeFocus ? "#281C9D" : "#848587"
                    color: parent.activeFocus ? "#FFFFFF" : "#f5f5f5"
                    border.width: parent.activeFocus ? 2 : 1

                    Behavior on color { ColorAnimation { duration: 200 } }
                    Behavior on border.color { ColorAnimation { duration: 200 } }
                    Behavior on border.width { NumberAnimation { duration: 200 } }
                }
            }
            Text{
                id: atmSignInErr
                text: "Invalid Credit Card Number or PIN"
                font.bold: true
                visible: false
                font.pixelSize: 14
                color: "#d40f12"
            }

            Button {
                id: atmSignInBtn
                width: atmSignInBtn.hovered ? parent.width+10 : parent.width
                height: 40
                anchors.horizontalCenter: parent.horizontalCenter
                Behavior on width{ NumberAnimation { duration: 200 } }
                
                background: Rectangle {
                    radius: 12
                    color: atmSignInBtn.hovered ? "#3A2DCD" : "#281c9d" 
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }
                Text { text: "CONFIRM"; color: "white"; font.pixelSize: 14; anchors.centerIn: parent; font.bold: true }

                onClicked: {
                    var cardNumber = userCardNumberInput.text
                    var pin = pinInput.text

                    if (appController.atm.loginWithCard(cardNumber, pin)) {  
                        atmRoot.StackView.view.push("AtmSelectionScreen.qml")
                        userCardNumberInput.text = ""
                        pinInput.text = ""
                        atmSignInErr.visible = false
                    } else {
                        atmSignInErr.visible = true
                        pinInput.text = ""
                    }
                }
            }
        }
}