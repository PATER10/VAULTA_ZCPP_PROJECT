import QtQuick 6.10
import QtQuick.Window 6.10
import QtQuick.Controls 6.10


Window {
    id: appRoot
    visible: true
    width: 560
    height: 500
    title: "VAULTA_ZCPP_PROJECT"

    StackView{
        id: stackView
        anchors.fill: parent
        initialItem: "MainMenu.qml"
    }
    
}
