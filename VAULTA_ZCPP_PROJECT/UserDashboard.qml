import QtQuick 6.10
import QtQuick.Controls.Basic 6.10

Rectangle {
    id: userDashboardRoot
    anchors.fill: parent
    color: "#f5f5f5"

    property string activeTab: "home"
    
    Component.onCompleted: {
        if (Window.window) {
            Window.window.width = 800
            Window.window.height = 500
            Window.window.x = Screen.width / 2 - 350
            Window.window.y = Screen.height / 2 - 280
        }
    }
    Row{
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
                        width: userDetailsBtn.hovered ? 62 : 60
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
                            color: userDetailsBtn.hovered ? "#3A2DCD" : "#281c9d"
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                        onClicked: {
                            userDashboardRoot.activeTab = "userDetails"
                        }
                    }
                Column{
                    width: parent.width
                    spacing: 2

                    Text{
                        text: appController.auth.currentUser.name + " " + appController.auth.currentUser.surname
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
                        id: homeBtn
                        width: parent.width
                        height: 45
                        flat: true
                        
                        Text { 
                            text: qsTr("Home")
                            color: (userDashboardRoot.activeTab === "home" || homeBtn.hovered) ? "#281c9d" : "#555"  
                            font.bold: true; horizontalAlignment: Text.AlignHCenter 
                            font.pixelSize: 14
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        background: Rectangle { 
                            color: (userDashboardRoot.activeTab === "home" || homeBtn.hovered) ? "#f0f0f5" : "transparent"
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                            }
                            Rectangle {
                                width: 3
                                height: parent.height
                                color: "#281c9d"
                                visible: userDashboardRoot.activeTab === "home"
                            }
                        }
                        onClicked:{
                            userDashboardRoot.activeTab = "home"
                        }
                    }

                    Button {
                        id: accBtn
                        width: parent.width
                        height: 45
                        flat: true
                        leftPadding: 30
                        Text { 
                            text: qsTr("Accounts") 
                            color: (userDashboardRoot.activeTab === "accounts" || accBtn.hovered) ? "#281c9d" : "#555" 
                            font.bold: true; horizontalAlignment: Text.AlignHCenter 
                            font.pixelSize: 14
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        background: Rectangle { 
                            color: (userDashboardRoot.activeTab === "accounts" || accBtn.hovered) ? "#f0f0f5" : "transparent" 
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                            }
                            Rectangle {
                                width: 3
                                height: parent.height
                                color: "#281c9d"
                                visible: userDashboardRoot.activeTab === "accounts"
                            }
                        }
                        onClicked:{
                            userDashboardRoot.activeTab = "accounts"
                        }
                    }
                    
                    Button {
                        id: transfersBtn 
                        width: parent.width
                        height: 45
                        flat: true
                        leftPadding: 30
                        Text { 
                            text: qsTr("Transfers") 
                            color: (userDashboardRoot.activeTab === "transfers" || transfersBtn.hovered) ? "#281c9d" : "#555" 
                            font.bold: true; horizontalAlignment: Text.AlignHCenter 
                            font.pixelSize: 14
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        background: Rectangle {
                            color: (userDashboardRoot.activeTab === "transfers" || transfersBtn.hovered) ? "#f0f0f5" : "transparent"
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                            }
                            Rectangle {
                                width: 3
                                height: parent.height
                                color: "#281c9d"
                                visible: userDashboardRoot.activeTab === "transfers"
                            }
                        }
                        onClicked:{
                            userDashboardRoot.activeTab = "transfers"
                        }
                    }
                    Button {
                        id: transactionsBtn 
                        width: parent.width
                        height: 45
                        flat: true
                        leftPadding: 30
                        Text { 
                            text: qsTr("Transactions") 
                            color: (userDashboardRoot.activeTab === "transactions" || transactionsBtn.hovered) ? "#281c9d" : "#555" 
                            font.bold: true; horizontalAlignment: Text.AlignHCenter 
                            font.pixelSize: 14
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        background: Rectangle {
                            color: (userDashboardRoot.activeTab === "transactions" || transactionsBtn.hovered) ? "#f0f0f5" : "transparent"
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                            }
                            Rectangle {
                                width: 3
                                height: parent.height
                                color: "#281c9d"
                                visible: userDashboardRoot.activeTab === "transactions"
                            }
                        }
                        onClicked:{
                            userDashboardRoot.activeTab = "transactions"
                        }
                    }
                    Button {
                        id: analyticsBtn
                        width: parent.width
                        height: 45
                        flat: true
                        leftPadding: 30
                        Text { 
                            text: qsTr("Analytics") 
                            color: (userDashboardRoot.activeTab === "analytics" || analyticsBtn.hovered) ? "#281c9d" : "#555" 
                            font.bold: true; horizontalAlignment: Text.AlignHCenter 
                            font.pixelSize: 14
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        background: Rectangle { 
                            color: (userDashboardRoot.activeTab === "analytics" || analyticsBtn.hovered) ? "#f0f0f5" : "transparent" 
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                            }
                            Rectangle {
                                width: 3
                                height: parent.height
                                color: "#281c9d"
                                visible: userDashboardRoot.activeTab === "analytics"
                            }
                        }
                        onClicked:{
                            userDashboardRoot.activeTab = "analytics"
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
        Rectangle {
            id: mainField
            width: parent.width - 200
            height: parent.height
            color: "transparent"
            Loader{
                id: contentLoader
                anchors.fill: parent

                source: {
                    if (userDashboardRoot.activeTab === "home") return "HomeView.qml"
                    if (userDashboardRoot.activeTab === "transactions") return "TransactionsView.qml"
                    if (userDashboardRoot.activeTab === "accounts") return "AccountsView.qml"
                    if (userDashboardRoot.activeTab === "transfers") return "TransfersView.qml"
                    if (userDashboardRoot.activeTab === "userDetails") return "UserDetailsView.qml"
                    if (userDashboardRoot.activeTab === "analytics") return "AnalyticsView.qml"
                    return ""
                }
            }
        }
    }
}
