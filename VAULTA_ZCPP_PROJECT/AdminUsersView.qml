pragma ComponentBehavior: Bound

import QtQuick 6.10
import QtQuick.Controls.Basic 6.10

Rectangle {
    id: adminUsersRoot

    property var adminRoot
    property var selectedUser: adminRoot ? adminRoot.selectedUser : null
    signal userSelected(var user)

    width: 320
    height: parent.height - 60
    radius: 14
    color: "white"
    border.color: "#dedede"
    border.width: 1

    Column {
        anchors.fill: parent
        spacing: 0

        Column {
            width: parent.width
            padding: 24
            spacing: 16

            Text {
                text: qsTr("Users")
                color: "#281c9d"
                font.pixelSize: 20
                font.bold: true
            }

            TextField {
                id: searchInput
                width: parent.width - 48
                height: 45
                placeholderText: qsTr("Search users...")
                color: "black"
                leftPadding: 14

                onTextChanged: {
                    adminUsersRoot.adminRoot.searchText = text
                }

                background: Rectangle {
                    radius: 10
                    color: "#f7f7f8"
                    border.color: parent.activeFocus ? "#281c9d" : "#d8d8d8"
                    border.width: parent.activeFocus ? 2 : 1
                }
            }
        }

        ListView {
            id: usersList
            width: parent.width
            height: parent.height - 135
            clip: true
            model: adminUsersRoot.adminRoot ? adminUsersRoot.adminRoot.filteredUsers() : []

            delegate: Rectangle {
                required property var modelData

                width: usersList.width
                height: 78
                color: adminUsersRoot.selectedUser && adminUsersRoot.selectedUser.id === modelData.id
                        ? "#f0f0ff"
                        : "white"

                border.color: "#eeeeee"
                border.width: 1


                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        adminUsersRoot.userSelected(modelData)
                    }
                }

                Row {
                    anchors.fill: parent
                    anchors.margins: 16

                    Column {
                        width: parent.width - 95
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4

                        Text {
                            text: modelData.name + " " + modelData.surname
                            color: "#111827"
                            font.bold: true
                            font.pixelSize: 14
                        }

                        Text {
                            text: "ID: " + modelData.id
                            color: "#6b7280"
                            font.pixelSize: 12
                        }
                    }

                    Row {
                        spacing: 7
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: modelData.is_active ? "#2ecc71" : "#9ca3af"
                        }

                        Text {
                            text: modelData.is_active ? qsTr("Active") : qsTr("Inactive")
                            color: modelData.is_active ? "#2ecc71" : "#6b7280"
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }
    }
}