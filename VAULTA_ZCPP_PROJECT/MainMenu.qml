import QtQuick 6.10
import QtQuick.Controls.Basic 6.10

Rectangle {
    id: menuRoot
    anchors.fill: parent
    color: "#f5f5f5"

    Column{
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 35
        width: 300
        Text{
            text: "WELCOME TO VAULTA"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 24
            font.bold: true
            color: "#281C9D"
        }
        Text{
            text: "Choose an option"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 16
            color: "#343434"
            font.bold: true
        }
        Button{
            id: atmButton
            width: atmButton.hovered ? 250 : 240
            height: 40
            anchors.horizontalCenter: parent.horizontalCenter
            Behavior on width{ 
                NumberAnimation { duration: 200 } 
            }
            Text{
                text: "ATM"
                color: "white"
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                font.pixelSize: 18
                font.bold: true
            }
            onClicked: {
                menuRoot.StackView.view.push("ATM.qml")
            }
            background: Rectangle {
                radius: 8
                color: atmButton.hovered ? "#3A2DCD" : "#281c9d" 
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
        Button{
            id: vaultaButton
            width: vaultaButton.hovered ? 250 : 240
            height: 40
            anchors.horizontalCenter: parent.horizontalCenter
            Behavior on width { 
                NumberAnimation { duration: 200 } 
            }
            Text{
                text: "Vaulta app"
                color: "white"
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                font.pixelSize: 18
                font.bold: true
            }
            onClicked: {
                menuRoot.StackView.view.push("LoginScreen.qml")
            }
            background: Rectangle {
                radius: 8
                color: vaultaButton.hovered ? "#3A2DCD" : "#281c9d" 
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }
}
