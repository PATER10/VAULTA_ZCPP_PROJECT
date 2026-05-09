import QtQuick 6.10
import QtQuick.Controls.Basic 6.10

Item {
    id: userDetailsViewRoot
    anchors.fill: parent
    
    property int contentPadding: 30

    component DetailRow : Column {
        property string labelText: ""
        property string valueText: ""
        
        width: parent.width
        spacing: 5
        
        Row {
            width: parent.width
            
            Text {
                text: labelText
                font.pixelSize: 14
                color: "#666666"
                font.bold: true
                width: parent.width * 0.4
                anchors.verticalCenter: parent.verticalCenter
            }
            
            TextInput {
                id: valueInput
                text: valueText
                width: parent.width * 0.6
                
                font.pixelSize: 16
                font.bold: true
                color: "#281c9d"
                
                readOnly: true
                selectByMouse: true
                selectionColor: "#ccccff"
                
                horizontalAlignment: Text.AlignRight
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.IBeamCursor
                    acceptedButtons: Qt.RightButton
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.RightButton) contextMenu.popup()
                    }
                }
                
                Menu {
                    id: contextMenu
                    MenuItem {
                        text: qsTr("Copy")
                        onTriggered: {
                            valueInput.selectAll()
                            valueInput.copy()
                            valueInput.deselect()
                        }
                    }
                }
            }
        }
        Rectangle {
            width: parent.width
            height: 1
            color: "#e0e0e0"
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Column {
        width: parent.width
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: userDetailsViewRoot.contentPadding
        spacing: 30

        Text {
            text: qsTr("User Details")
            font.pixelSize: 24
            font.bold: true
            color: "#281c9d"
        }
        
        Column {
            width: parent.width
            spacing: 25
            
            DetailRow {
                labelText: qsTr("User ID (Login)")
                valueText: appController.auth.currentUser.userId.toString()
            }
            
            DetailRow {
                labelText: qsTr("Name and surname")
                valueText: appController.auth.currentUser.name + " " +appController.auth.currentUser.surname
            }
            
            DetailRow {
                labelText: qsTr("Account Number")
                valueText: appController.auth.currentUser.account.accountNumber
            }
            
            DetailRow {
                labelText: qsTr("Card Number")
                valueText: appController.auth.currentUser.card.cardNumber
            }
        }
        
        Text {
            text: qsTr("You can copy values by selecting them.")
            font.pixelSize: 12
            color: "#999"
            anchors.horizontalCenter: parent.horizontalCenter
            topPadding: 20
        }
    }
}