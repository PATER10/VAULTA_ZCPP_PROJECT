import QtQuick 6.10
import QtQuick.Controls.Basic 6.10
import QtQuick.Window 6.10

Item {
    id: adminDashboardRoot
    anchors.fill: parent

    property var users: []
    property var selectedUser: null
    property string searchText: ""
    property string activeTab: "userManagement"

    Component.onCompleted: {
        refreshUsers()

        if (Window.window) {
            Window.window.visibility = Window.Maximized
        }
    }

    function refreshUsers() {
        users = appController.adminManager.getAllUsers()

        if (selectedUser) {
            let found = null
            for (let i = 0; i < users.length; i++) {
                if (users[i].id === selectedUser.id) {
                    found = users[i]
                    break
                }
            }
            selectedUser = found
        }
    }

    function filteredUsers() {
        let result = []
        let search = searchText.toLowerCase()

        for (let i = 0; i < users.length; i++) {
            let user = users[i]
            let fullName = (user.name + " " + user.surname).toLowerCase()

            if (search.length === 0 || fullName.indexOf(search) !== -1 || String(user.id).indexOf(search) !== -1) {
                result.push(user)
            }
        }

        return result
    }

    Row {
        anchors.fill: parent

        Rectangle{
            id: leftSidebar
            width: 200
            height: parent.height
            Rectangle { 
                width: 1; height: parent.height; 
                anchors.right: parent.right; color: "#e0e0e0" 
            }
            Column{
                width: parent.width
                spacing: 15
                topPadding: 30
                    Button{
                        id: userDetailsBtn
                        width: 60
                        height: width
                        anchors.horizontalCenter: parent.horizontalCenter
                        Behavior on width{ NumberAnimation { duration: 200 } }
                        Text{
                            text: appController.auth.currentUser.initials
                            color: "white"
                            font.pixelSize: 18
                            font.bold: true
                            anchors.centerIn: parent
                        }
                        background: Rectangle {
                            radius: width/2
                            color: "#281c9d"
                        }
                    }
                Column{
                    width: parent.width
                    spacing: 2

                    Text{
                        text: appController.auth.currentUser.name
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        font.bold: true
                        font.pixelSize: 16
                        color: "#333" 
                    }
                }
                Rectangle {
                    width: 100
                    height: 1
                    color: "#eeeeee"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Column {
                    width: parent.width
                    spacing: 0

                    Button {
                        id: userManagementBtn
                        width: parent.width
                        height: 45
                        flat: true
                        
                        Text { 
                            text: qsTr("User Management")
                            color: (adminDashboardRoot.activeTab === "userManagement" || userManagementBtn.hovered) ? "#281c9d" : "#555"  
                            font.bold: true; horizontalAlignment: Text.AlignHCenter 
                            font.pixelSize: 14
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        background: Rectangle { 
                            color: (adminDashboardRoot.activeTab === "userManagement" || userManagementBtn.hovered) ? "#f0f0f5" : "transparent"
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                            }
                            Rectangle {
                                width: 3
                                height: parent.height
                                color: "#281c9d"
                                visible: adminDashboardRoot.activeTab === "userManagement"
                            }
                        }
                        onClicked:{
                            adminDashboardRoot.activeTab = "userManagement"
                        }
                    }

                    Button {
                        id: logOutBtn 
                        width: parent.width
                        height: 40
                        flat: true
                        Text { 
                            text: qsTr("Log Out"); color: "#d40f12";
                            font.bold: true; horizontalAlignment: Text.AlignHCenter 
                            font.pixelSize: 14
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        background: Rectangle { color: logOutBtn.hovered ? "#ffebeb" : "transparent" 
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                        onClicked: {
                            if (Window.window) {
                                Window.window.visibility = Window.Windowed
                                Window.window.width = 560
                                Window.window.height = 500
                                Window.window.x = Screen.width / 2 - 280
                                Window.window.y = Screen.height / 2 - 250
                            }
                            appController.auth.logout();
                            stackView.pop(null);
                            stackView.push("LoginScreen.qml");
                        }
                    }
                }
            }   
        }
        ScrollView {
            id: adminContentScroll

            width: parent.width - leftSidebar.width
            height: parent.height
            clip: true

            ScrollBar.horizontal.policy: ScrollBar.AsNeeded
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            contentWidth: Math.max(width, 980)
            contentHeight: Math.max(height, 760)

            Loader {
                id: adminContentLoader

                width: adminContentScroll.contentWidth
                height: adminContentScroll.contentHeight

                source: {
                    if (adminDashboardRoot.activeTab === "userManagement")
                        return "UserManagementView.qml"

                    return ""
                }

                onLoaded: {
                    if (item) {
                        item.adminRoot = adminDashboardRoot
                    }
                }
            }
        }
    }
}