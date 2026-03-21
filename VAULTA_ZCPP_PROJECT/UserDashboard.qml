import QtQuick 6.10
import QtQuick.Controls.Basic 6.10

Rectangle {
    width: 200
    height: 100
    
    Button{
        id: infoBtn
        anchors.fill: parent
        text: hovered ? "Logout" : "Logged in"
        background: Rectangle{
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
            }
            color: infoBtn.hovered ? "darkred" : "green";

            Behavior on color {
                ColorAnimation { duration: 200 }
            }   
        }  
        onClicked: {
            appController.auth.logout();
            stackView.pop(null);
            stackView.push("LoginScreen.qml");
        }    
    }   
}
