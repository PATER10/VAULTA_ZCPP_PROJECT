import QtQuick 6.10
import QtQuick.Controls.Basic 6.10

Rectangle {
    id: signUpScreenRoot
    anchors.fill: parent
    color: "#f5f5f5"

    property string newUserId: ""
    property string newAccountNumber: ""
    property string newCardNumber: ""

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
            signUpScreenRoot.StackView.view.pop()
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 20
        width: 300
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter 

        Text {
            text: qsTr("Welcome to VAULTA")
            color: "#281C9D"
            font.bold: true
            font.pixelSize: 24
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Text {
            text: qsTr("Hello there, create New account")
            font.bold: true
            font.pixelSize: 16
            color: "#343434"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        TextField {
            id: userName
            placeholderText: qsTr("Name")
            palette.placeholderText: "gray"
            palette.text: "black"
            height: 40
            width: parent.width
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
        TextField {
            id: userSurname
            placeholderText: qsTr("Surname")
            palette.placeholderText: "gray"
            palette.text: "black"
            height: 40
            width: parent.width
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

        TextField {
            id: pinInput
            placeholderText: qsTr("PIN (4 digits)")
            palette.placeholderText: "gray"
            palette.text: "black"
            height: 40
            width: parent.width
            echoMode: TextInput.Password
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
        Text{
            id: signUpErr
            text: qsTr("Invalid Data! Please check your details.")
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
            Text { text: qsTr("SIGN UP"); color: "white"; font.pixelSize: 14; anchors.centerIn: parent; font.bold: true }

            onClicked: {
                // @disable-check unqualified-access
                var result = backend.auth.registerUser(userName.text,userSurname.text, passwordInput.text, pinInput.text);
                    
                if(result.success == true) {
                    console.log("Konto użytkownika zostało utworzone!");
                        
                    signUpScreenRoot.newUserId = result.userId
                    signUpScreenRoot.newAccountNumber = result.accountNumber
                    signUpScreenRoot.newCardNumber = result.cardNumber

                    successPopup.open()

                } else {
                    console.log("Błąd rejestracji");
                    signUpErr.visible = true
                }
            
            }
        }
        Row{
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10
            Text {
                text: qsTr("Have an account?")
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

                Text{ text:qsTr("Sign in"); font.pixelSize: 14; font.bold: true; color: "#281c9d"}

                onClicked: {
                    signUpScreenRoot.StackView.view.pop()
                }
            }
        }
    }
    Popup {
        id: successPopup
        anchors.centerIn: parent
        width: 400
        height: 460
        modal: true
        focus: true
        closePolicy: Popup.NoAutoClose

        background: Rectangle {
            color: "white"
            radius: 12
            border.color: "#281C9D"
            border.width: 2
        }
        
        Column {
            anchors.centerIn: parent
            spacing: 15
            width: 320

            Text {
                text: qsTr("SUCCESS!")
                font.bold: true
                font.pixelSize: 26
                color: "#281C9D"
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            Text {
                text: qsTr("Your account has been created.")
                font.pixelSize: 18
                font.bold: true
                color: "#666666"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle { height: 1; width: parent.width; color: "#cccccc" }

            Column {
                spacing: 5
                width: parent.width
                
                Text { text: qsTr("Your User ID (Login):"); font.pixelSize: 12; color: "#343434" }
                TextInput { 
                    id: userIdText
                    text: signUpScreenRoot.newUserId
                    font.pixelSize: 22
                    color: "black"
                    font.bold: true
                    width: parent.width
                    
                    readOnly: true            
                    selectByMouse: true       
                    selectionColor: "#ccccff"
                    activeFocusOnPress: true
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.IBeamCursor 
                        acceptedButtons: Qt.RightButton 
                        
                        onClicked: userIdMenu.popup()
                    }
                    Menu {
                        id: userIdMenu
                        MenuItem {
                            text: "Copy"
                            onTriggered: {
                                userIdText.selectAll()
                                userIdText.copy()
                                userIdText.deselect() 
                            }
                        }
                    }
                }
                
                Text { text: qsTr("Account Number:"); color: "#343434"; font.pixelSize: 12; topPadding: 10 }
                TextInput { 
                    id: userIdText2
                    text: signUpScreenRoot.newAccountNumber
                    font.pixelSize: 22
                    color: "black"
                    font.bold: true
                    width: parent.width
                    
                    readOnly: true            
                    selectByMouse: true       
                    selectionColor: "#ccccff"
                    activeFocusOnPress: true
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.IBeamCursor 
                        acceptedButtons: Qt.RightButton 
                        
                        onClicked: userIdMenu2.popup()
                    }
                    Menu {
                        id: userIdMenu2
                        MenuItem {
                            text: "Copy"
                            onTriggered: {
                                userIdText2.selectAll()
                                userIdText2.copy()
                                userIdText2.deselect() 
                            }
                        }
                    }
                }

                Text { text: qsTr("Card Number:"); color: "#343434"; font.pixelSize: 12; topPadding: 10 }
                TextInput { 
                    id: userIdText3
                    text: signUpScreenRoot.newCardNumber
                    font.pixelSize: 22
                    color: "black"
                    font.bold: true
                    width: parent.width
                    
                    readOnly: true            
                    selectByMouse: true       
                    selectionColor: "#ccccff"
                    activeFocusOnPress: true
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.IBeamCursor 
                        acceptedButtons: Qt.RightButton 
                        
                        onClicked: userIdMenu3.popup()
                    }
                    Menu {
                        id: userIdMenu3
                        MenuItem {
                            text: qsTr("Copy")
                            onTriggered: {
                                userIdText3.selectAll()
                                userIdText3.copy()
                                userIdText3.deselect() 
                            }
                        }
                    }
                }
                
            }

                Text { text: qsTr("Please keep your details for future logins!"); color: "#d40f12"; font.pixelSize: 16; topPadding: 5}

                Button {
                    id: signUpInfoBtn
                    width: signUpInfoBtn.hovered ? parent.width+10 : parent.width
                    height: 40
                    topPadding: 5
                    anchors.horizontalCenter: parent.horizontalCenter
                    Behavior on width { NumberAnimation { duration: 200 } }

                    Text{
                        text: qsTr("CONFIRM")
                        color: "white"
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        font.pixelSize: 18
                        font.bold: true
                    }
                    onClicked: {
                        successPopup.close()
                        userName.text = ""
                        userSurname.text = ""
                        passwordInput.text = ""
                        pinInput.text = ""
                        signUpScreenRoot.StackView.view.pop()
                    }
                    background: Rectangle {
                        radius: 8
                        color: signUpInfoBtn.hovered ? "#3A2DCD" : "#281c9d" 
                        MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }
    }
}