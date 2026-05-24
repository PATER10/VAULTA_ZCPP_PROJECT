import QtQuick 6.10
import QtQuick.Controls.Basic 6.10


Row {
    id: userManagementRoot

    property var adminRoot

    width: parent.width
    height: parent.height
    spacing: 24
    padding: 30

    AdminUsersView {
        adminRoot: userManagementRoot.adminRoot

        onUserSelected: function(user) {
            userManagementRoot.adminRoot.selectedUser = user
            firstNameInput.text = user.name
            lastNameInput.text = user.surname
            newPasswordInput.text = ""
            messageText.text = ""
        }
    }

    Rectangle {
        width: parent.width - 430
        height: parent.height - 60
        radius: 14
        color: "white"
        border.color: "#dedede"
        border.width: 1

        Column {
            anchors.fill: parent
            anchors.margins: 32
            spacing: 24

            Text {
                text: qsTr("Edit User Profile")
                color: "#281c9d"
                font.pixelSize: 20
                font.bold: true
            }

            Text {
                visible: !userManagementRoot.adminRoot.selectedUser
                text: qsTr("Select a user from the list.")
                color: "#777"
                font.pixelSize: 16
            }

            Column {
                visible: userManagementRoot.adminRoot.selectedUser
                width: parent.width
                spacing: 26

                Row {
                    width: parent.width
                    spacing: 16

                    Column {
                        width: (parent.width - 16) / 2
                        spacing: 8

                        Text { text: qsTr("First Name"); color: "#374151"; font.bold: true; font.pixelSize: 13 }

                        TextField {
                            id: firstNameInput
                            width: parent.width
                            height: 45
                            color: "black"

                            background: Rectangle {
                                radius: 10
                                color: "#f7f7f8"
                                border.color: parent.activeFocus ? "#281c9d" : "#d8d8d8"
                                border.width: parent.activeFocus ? 2 : 1
                            }
                        }
                    }

                    Column {
                        width: (parent.width - 16) / 2
                        spacing: 8

                        Text { text: qsTr("Last Name"); color: "#374151"; font.bold: true; font.pixelSize: 13 }

                        TextField {
                            id: lastNameInput
                            width: parent.width
                            height: 45
                            color: "black"

                            background: Rectangle {
                                radius: 10
                                color: "#f7f7f8"
                                border.color: parent.activeFocus ? "#281c9d" : "#d8d8d8"
                                border.width: parent.activeFocus ? 2 : 1
                            }
                        }
                    }
                }

                Button {
                    id: saveEditBtn
                    width: saveEditBtn.hovered ? 153 : 150
                    height: 45

                    contentItem: Text {
                        text: qsTr("Save Changes")
                        font.pixelSize: 12
                        color: "white"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 10
                        color: parent.hovered ? "#3A2DCD" : "#281c9d"
                        MouseArea{
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor;

                        }
                    }

                    

                    onClicked: {
                        if (appController.adminManager.updateUserProfile(userManagementRoot.adminRoot.selectedUser.id, firstNameInput.text, lastNameInput.text)) {
                            messageText.color = "#2ecc71"
                            messageText.text = qsTr("Profile updated.")
                            userManagementRoot.adminRoot.refreshUsers()
                        } else {
                            messageText.color = "#d40f12"
                            messageText.text = qsTr("Could not update profile.")
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#e5e5e5" }

                Text {
                    text: qsTr("Security")
                    color: "#281c9d"
                    font.pixelSize: 18
                    font.bold: true
                }

                Column {
                    width: parent.width
                    spacing: 8

                    Text { text: qsTr("New Password"); color: "#374151"; font.bold: true; font.pixelSize: 13 }

                    TextField {
                        id: newPasswordInput
                        width: parent.width
                        height: 45
                        echoMode: TextInput.Password
                        placeholderText: qsTr("Enter new password")
                        color: "black"

                        background: Rectangle {
                            radius: 10
                            color: "#f7f7f8"
                            border.color: parent.activeFocus ? "#281c9d" : "#d8d8d8"
                            border.width: parent.activeFocus ? 2 : 1
                        }
                    }
                }

                Button {
                    id: forcePassBtn
                    width: forcePassBtn.hovered ? 213 : 210
                    height: 45

                    contentItem: Text {
                        text: qsTr("Force Password Reset")
                        color: "#281c9d"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 10
                        color: forcePassBtn.hovered ? "#f0f0f5" : "white"
                        border.width: 2
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

                    onClicked: {
                        if (appController.adminManager.resetUserPassword(userManagementRoot.adminRoot.selectedUser.id, newPasswordInput.text)) {
                            messageText.color = "#2ecc71"
                            messageText.text = qsTr("Password reset.")
                            newPasswordInput.text = ""
                        } else {
                            messageText.color = "#d40f12"
                            messageText.text = qsTr("Could not reset password.")
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#e5e5e5" }

                Text {
                    text: qsTr("Account Status")
                    color: "#281c9d"
                    font.pixelSize: 18
                    font.bold: true
                }

                Row {
                    width: parent.width
                    spacing: 16

                    Button {
                        id: statusBtn
                        width: statusBtn.hovered ? 193 : 190
                        height: 45

                        contentItem: Text {
                            text: userManagementRoot.adminRoot.selectedUser && userManagementRoot.adminRoot.selectedUser.is_active
                                    ? qsTr("Deactivate")
                                    : qsTr("Activate")
                            color: "white"
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 10
                            color: statusBtn.hovered ? "#3A2DCD" : "#281c9d"
                        }

                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }

                        onClicked: {
                            let newStatus = !userManagementRoot.adminRoot.selectedUser.is_active

                            if (appController.adminManager.toggleUserActive(userManagementRoot.adminRoot.selectedUser.id, newStatus)) {
                                messageText.color = "#2ecc71"
                                messageText.text = newStatus ? qsTr("User activated.") : qsTr("User deactivated.")
                                userManagementRoot.adminRoot.selectedUser.is_active = newStatus
                                userManagementRoot.adminRoot.refreshUsers()
                            } else {
                                messageText.color = "#d40f12"
                                messageText.text = qsTr("Could not change status.")
                            }
                        }
                    }

                    Button {
                        id: deleteUserBtn
                        width: deleteUserBtn.hovered ? 173 : 170
                        height: 45

                        contentItem: Text {
                            text: qsTr("Delete User")
                            color: "white"
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 10
                            color: parent.hovered ? "#b91c1c" : "#d40f12"
                        }

                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }

                        onClicked: confirmDeletePopup.open()
                    }
                }

                Text {
                    id: messageText
                    text: ""
                    font.pixelSize: 13
                    font.bold: true
                }
            }
        }
    }
    Popup {
        id: confirmDeletePopup
        anchors.centerIn: parent
        width: 320
        height: 170
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: "white"
            radius: 14
            border.color: "#d40f12"
            border.width: 2
        }

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 18

            Text {
                text: qsTr("Delete selected user?")
                color: "#d40f12"
                font.bold: true
                font.pixelSize: 18
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }

            Row {
                spacing: 12
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    id: cancelBtn
                    width: 120
                    height: 40
                    contentItem: Text {
                        text: qsTr("Cancel")
                        color: "white"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        radius: 10
                        color: cancelBtn.hovered ? "#3A2DCD" : "#281c9d"
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    } 
                    onClicked: confirmDeletePopup.close()
                }

                Button {
                    id: delBtn
                    width: 120
                    height: 40

                    contentItem: Text {
                        text: qsTr("Delete")
                        color: "white"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 10
                        color: delBtn.hovered ? "#b91c1c" : "#d40f12"
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }    

                    onClicked: {
                        if (userManagementRoot.adminRoot.selectedUser && appController.adminManager.deleteUser(userManagementRoot.adminRoot.selectedUser.id)) {
                            confirmDeletePopup.close()
                            userManagementRoot.adminRoot.selectedUser = null
                            userManagementRoot.adminRoot.refreshUsers()
                        }
                    }
                }
            }
        }
    }
}
