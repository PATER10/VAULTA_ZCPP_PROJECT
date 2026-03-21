import QtQuick 6.10
import QtQuick.Controls.Basic 6.10

Rectangle {
    id: userDashboardRoot
    anchors.fill: parent
    property string userName: ""
    property string userSurname: ""

    property string accountBalance: "0.00"
    property string accountNumber: "----"
    property string accountCurrency: "PLN"
    property string cardNumber: "----"

    Column{
    width: 140
        Text{
            text: "Hello there, " + userDashboardRoot.userName +" "+ userDashboardRoot.userSurname
            font.bold: true
            font.pixelSize: 14
            color: "#343434"
        }
        
        Text{
            text: "Account Balance: " + userDashboardRoot.accountBalance + " " + userDashboardRoot.accountCurrency
            font.bold: true
            font.pixelSize: 14
            color: "#343434"
        }
        Text{
            text: "Account Number: " + userDashboardRoot.accountNumber
            font.bold: true
            font.pixelSize: 14
            color: "#343434"
        }
        Text{
            text: "Card Number: " + userDashboardRoot.cardNumber
            font.bold: true
            font.pixelSize: 14
            color: "#343434"
        }
        
        Button{
            id: info
            width: 200
            height: 100
            text: "Logged in" 
            background: Rectangle{
                color: "green"; 
            }     
        }
         Button {
            id: logoutBtn
            width: logoutBtn.hovered ? parent.width+10 : parent.width
            height: 40
            anchors.horizontalCenter: parent.horizontalCenter
            Behavior on width{ NumberAnimation { duration: 200 } }
                
            background: Rectangle {
                radius: 12
                color: logoutBtn.hovered ? "#3A2DCD" : "#281c9d" 
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }
            Text { text:"Logout" ; color: "white"; font.pixelSize: 14; anchors.centerIn: parent; font.bold: true }
            onClicked: {
                appController.auth.logout();
                stackView.pop(null);
                stackView.push("LoginScreen.qml");
            } 
        }
    }   
}
