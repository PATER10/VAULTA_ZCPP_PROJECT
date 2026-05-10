import QtQuick 6.10
import QtQuick.Controls.Basic 6.10
import QtQuick.Effects 6.10

Rectangle {
    id: menuRoot
    anchors.fill: parent
    color: "#f5f5f5"
    Item{
        width: 40
        height: 25
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 20

        Rectangle{
            id:flagContainer
            anchors.fill: parent
            color: "white"

            border.color: "#d0d0d0"
            border.width: 1
            radius: 3
            
            Image{
                id: flagImg
                anchors.fill: parent
                anchors.margins: 1
                source: appController.L.currentLanguage === "pl" ? "./images/en_flag.svg" : "./images/pl_flag.svg"
                fillMode: Image.PreserveAspectCrop

                smooth: true
                mipmap: true
            }
            
        }
        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if(appController.L.currentLanguage === "pl"){
                    appController.L.setLanguage("en")
                }else{
                   appController.L.setLanguage("pl")
                }
            }
            onPressed: flagContainer.opacity = 0.7
            onReleased: flagContainer.opacity = 1.0
        }
    }

    Column{
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 35
        width: 300
        Text{
            text: qsTr("WELCOME TO VAULTA") + appController.L.updateTr
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 24
            font.bold: true
            color: "#281C9D"
        }
        Text{
            text: qsTr("Choose an option") + appController.L.updateTr
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
                text: qsTr("ATM") + appController.L.updateTr
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
                text: qsTr("Vaulta app") + appController.L.updateTr
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
