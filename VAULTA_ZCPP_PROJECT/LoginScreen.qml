import QtQuick 6.10
import QtQuick.Controls.Basic 6.10

Rectangle {
    id: loginScreenRoot
    anchors.fill: parent
    color: "#f5f5f5"
    Button{
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
            loginScreenRoot.StackView.view.pop()
            signInErr.visible = false
        }
    }
    Column{
        anchors.centerIn: parent
        spacing: 20
        width: 300
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter 

        Text {
            text: qsTr("Welcome Back")
            color: "#281C9D"
            font.bold: true
            font.pixelSize: 24
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Text {
            text: qsTr("Hello there, sign in to continue")
            font.bold: true
            font.pixelSize: 16
            color: "#343434"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        TextField {
            id: userIdInput
            placeholderText: qsTr("User ID")
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

                Behavior on color { 
                    ColorAnimation { duration: 200 } 
                }
                Behavior on border.color { 
                    ColorAnimation { duration: 200 } 
                }
                Behavior on border.width { 
                    NumberAnimation { duration: 200 } 
                }
            }    
        }
        TextField {
            id: passwordInput
            placeholderText: qsTr("Password")
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
            id: signInErr
            text: qsTr("Invalid User ID or password")
            font.bold: true
            visible: false
            font.pixelSize: 14
            color: "#d40f12"
        }
        Button {
            id: signInBtn
            width: signInBtn.hovered ? parent.width+10 : parent.width
            height: 40
            anchors.horizontalCenter: parent.horizontalCenter
            Behavior on width{ NumberAnimation { duration: 200 } }
                
            background: Rectangle {
                radius: 12
                color: signInBtn.hovered ? "#3A2DCD" : "#281c9d" 
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }
            Text { text: qsTr("SIGN IN"); color: "white"; font.pixelSize: 14; anchors.centerIn: parent; font.bold: true }
            onClicked: {
                var uid = parseInt(userIdInput.text);
                if(isNaN(uid)) uid = 0;

                var result = appController.auth.loginUser(uid, passwordInput.text);
      
                if(result.success === true) {   
                        
                    if (result.role === "admin") {
                        stackView.push("AdminDashboard.qml")
                    } else {
                        stackView.push("UserDashboard.qml")
                    }

                    userIdInput.text = ""
                    passwordInput.text = ""
                } else {
                    signInErr.text = result.message || qsTr("Invalid login or password")
                    signInErr.visible = true
                    userIdInput.text = ""
                    passwordInput.text = ""
                } 
            }
        }
        Row{
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10
            Text {
                text: qsTr("Don't have an account?")
                font.bold: true
                font.pixelSize: 14
                color: "#343434"
            }
            Button{
                id: signUpBtn
                width: 50
                height: 20
                background: Rectangle {
                    color: "transparent"
                    MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    }
                }

                Text{ text:qsTr("Sign up"); font.pixelSize: 14; font.bold: true; color: "#281c9d"}

                onClicked: {
                    loginScreenRoot.StackView.view.push("SignUpScreen.qml")
                    signInErr.visible = false
                }
            }
        }
    }
}
