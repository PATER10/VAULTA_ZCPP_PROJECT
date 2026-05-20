import QtQuick 6.10
import QtQuick.Controls.Basic 6.10

Item{
    
    id: accountViewRoot
    anchors.fill: parent
             
    property int contentPadding: 30
    property real eurBuyRate: 4.40
    property real eurSellRate: 4.10
    property var fromAccount: appController.auth.currentUser.account
    property var toAccount: null

    Component.onCompleted: {
        if (appController.auth.currentUser.accounts.length > 0) {
            fromAccount = appController.auth.currentUser.accounts[0]
        }

        if (appController.auth.currentUser.accounts.length > 1) {
            toAccount = appController.auth.currentUser.accounts[1]
        }
    }

    function updateExchangeOutput() {
        let amount = parseFloat(exchangeAmountInput.text)

        if (!fromAccount || !toAccount || isNaN(amount) || amount <= 0) {
            exchangeAmountOutput.text = ""
            return
        }

        if (fromAccount.accountNumber === toAccount.accountNumber) {
            exchangeAmountOutput.text = ""
            return
        }

        if (fromAccount.currency === toAccount.currency) {
            exchangeAmountOutput.text = ""
            return
        }

        if (fromAccount.currency === "PLN" && toAccount.currency === "EUR") {
            exchangeAmountOutput.text = (amount / eurBuyRate).toFixed(2)
            return
        }

        if (fromAccount.currency === "EUR" && toAccount.currency === "PLN") {
            exchangeAmountOutput.text = (amount * eurSellRate).toFixed(2)
            return
        }

        exchangeAmountOutput.text = ""
    }
    function ensureDifferentAccounts(changedSide) {
        if (!fromAccount || !toAccount) return

        if (fromAccount.accountNumber !== toAccount.accountNumber) return

        for (let i = 0; i < appController.auth.currentUser.accounts.length; i++) {
            let account = appController.auth.currentUser.accounts[i]

            if (changedSide === "from") {
                toAccount = account
                toAccountSelect.currentIndex = i
            } else {
                fromAccount = account
                fromAccountSelect.currentIndex = i
            }
        }
        updateExchangeOutput()
    }
    

    Column {
        id: headerContainer
        width: parent.width
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: accountViewRoot.contentPadding
        spacing: 25

        Text {
            text: qsTr("My accounts")
            font.pixelSize: 24
            font.bold: true
            color: "#281c9d"
        }

            ListView{
            id: accountsList
            width: parent.width
            height: 150
            orientation: ListView.Horizontal
            spacing: 15
            clip: true

            model: appController.auth.currentUser.accounts

            delegate: Rectangle{
                width:300
                height: 140
                radius: 16
                color: "white"

                border.color: modelData.accountNumber === appController.auth.currentUser.account.accountNumber
                    ? "#281c9d" : "#e0e0e0"
                border.width: modelData.accountNumber === appController.auth.currentUser.account.accountNumber
                    ? 2 : 1

                MouseArea{
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        appController.auth.currentUser.setActiveAccountByNumber(modelData.accountNumber)
                        appController.bankManager.updateUserTransactions(true)
                    }
                }
                Column{
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 10

                    Row{
                        width: parent.width
                        Column {
                            width: parent.width - 50
                            Text {
                                text: modelData.currency === "PLN" ? qsTr("Main Account") : qsTr("Currency Account")
                                font.bold: true
                                font.pixelSize: 14
                                color: "black"
                            }

                            Text {
                                text: modelData.accountType
                                font.pixelSize: 12
                                color: "#888"
                            }
                        }
                        Rectangle {
                            width: 40
                            height: 40
                            radius: 20
                            color: "#f0f0f5"

                            Text {
                                text: modelData.currency
                                anchors.centerIn: parent
                                font.bold: true
                                color: "#281c9d"
                                font.pixelSize: 10
                            }
                        }
                    }
                    Text {
                        text: Number(modelData.balance).toFixed(2) + " " + modelData.currency
                        font.pixelSize: 20
                        font.bold: true
                        color: "#281c9d"
                    }

                    Text {
                        text: modelData.accountNumber
                        font.pixelSize: 14
                        color: "#888"
                    }
                }
            }
        }
    
        Column {
            width: parent.width
            spacing: 12
            visible: appController.auth.currentUser.hasCurrencyAccounts

            Text {
                text: qsTr("Currency exchange")
                font.pixelSize: 24
                font.bold: true
                color: "#281c9d"
            }

            Text {
                text: qsTr("EUR buy: 4.40 PLN  |  EUR sell: 4.10 PLN")
                font.pixelSize: 13
                color: "#888"
            }
            Column{
                id: exchangeBox
                width: parent.width
                spacing: 15
                Row{
                    width: parent.width
                    spacing: 15 
                    ComboBox {
                        id: fromAccountSelect
                        width: parent.width * 0.12
                        height: 45
                        palette.text: "white"
                        background: Rectangle {
                            radius: 12
                            border.color: parent.activeFocus ? "#281C9D" : "#e0e0e0"
                            border.width: parent.activeFocus ? 2 : 1
                            color: "white"
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on border.color { ColorAnimation { duration: 200 } }
                            Behavior on border.width { NumberAnimation { duration: 200 } }
                        }


                        model: appController.auth.currentUser.accounts
                        textRole: "currency"

                        currentIndex: 0

                        delegate: ItemDelegate {
                            width: fromAccountSelect.width
                            text: modelData.currency 
                        
                            contentItem: Text{
                                    text: modelData.currency
                                    color: "black"
                            }
                            background: Rectangle {
                                color: parent.hovered ? "#f3f3f3" : "white"
                            }
                            HoverHandler {
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                        contentItem: Text {
                            text: fromAccount ? fromAccount.currency : ""
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 10
                            color: "black"
                        }

                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }

                        onActivated: {
                            accountViewRoot.fromAccount = appController.auth.currentUser.accounts[index]
                            accountViewRoot.ensureDifferentAccounts("from")
                        }
                    }
                    TextField {
                        id: exchangeAmountInput
                        placeholderText: qsTr("Enter amount to exchange")
                        palette.placeholderText: "gray"
                        palette.text: "black"
                        width: parent.width * 0.31
                        height: 45
                        font.pixelSize: 14
                        leftPadding: 15
                        validator: DoubleValidator { bottom: 0.01; decimals: 2 }
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                
                        background: Rectangle {
                            radius: 12
                            border.color: parent.activeFocus ? "#281C9D" : "#e0e0e0"
                            border.width: parent.activeFocus ? 2 : 1
                            color: "white"
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on border.color { ColorAnimation { duration: 200 } }
                            Behavior on border.width { NumberAnimation { duration: 200 } }
                        }
                        onTextChanged: accountViewRoot.updateExchangeOutput()
                    }
                    
                    Text {
                        text: "→"
                        font.pixelSize: 24
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    ComboBox {
                        id: toAccountSelect
                        width: parent.width * 0.12
                        height: 45
                        palette.text: "white"
                        background: Rectangle {
                            radius: 12
                            border.color: parent.activeFocus ? "#281C9D" : "#e0e0e0"
                            border.width: parent.activeFocus ? 2 : 1
                            color: "white"
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on border.color { ColorAnimation { duration: 200 } }
                            Behavior on border.width { NumberAnimation { duration: 200 } }
                        }

                        model: appController.auth.currentUser.accounts
                        textRole: "currency"

                        currentIndex: appController.auth.currentUser.accounts.length > 1 ? 1 : 0

                        delegate: ItemDelegate {
                            width: toAccountSelect.width
                            contentItem: Text{
                                text: modelData.currency
                                color: "black"
                            }
                             

                            background: Rectangle {
                                color: parent.hovered ? "#f3f3f3" : "white"
                            }
                            HoverHandler {
                                cursorShape: Qt.PointingHandCursor
                            }

                        }
                       
                        contentItem: Text {
                            text: toAccount ? toAccount.currency : ""
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 10
                            color: "black"
                        }

                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }

                        onActivated: {
                            accountViewRoot.toAccount = appController.auth.currentUser.accounts[index]
                            accountViewRoot.ensureDifferentAccounts("to")
                        }
                    }
                    TextField {
                        id: exchangeAmountOutput
                        placeholderText: qsTr("Exchange amount")
                        palette.placeholderText: "gray"
                        palette.text: "black"
                        width: parent.width * 0.31
                        height: 45
                        font.pixelSize: 14
                        leftPadding: 15
                        validator: DoubleValidator { bottom: 0.01; decimals: 2 }
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                
                        background: Rectangle {
                            radius: 12
                            border.color: parent.activeFocus ? "#281C9D" : "#e0e0e0"
                            border.width: parent.activeFocus ? 2 : 1
                            color: "white"
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on border.color { ColorAnimation { duration: 200 } }
                            Behavior on border.width { NumberAnimation { duration: 200 } }
                        } 
                        readOnly: true
                    }
                    
                }
                Button {
                    id: confirmExchangeBtn
                    height: 45
                    width: confirmExchangeBtn.hovered ? (parent.width / 5) + 5 : parent.width / 5
                    Behavior on width{ NumberAnimation { duration: 200 } }
                    contentItem: Text {
                        text: qsTr("Confirm")
                        color: "white"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 12
                        color: confirmExchangeBtn.hovered ? "#3A2DCD" : "#281c9d"
                        MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        }
                    }

                    onClicked: {
                        let amount = parseFloat(exchangeAmountInput.text)

                        if (!fromAccount || !toAccount || fromAccount.accountNumber === toAccount.accountNumber) {
                            return
                        }

                        if (amount > 0 && appController.bankManager.exchangeBetweenAccounts(fromAccount.accountNumber, toAccount.accountNumber, amount)) {
                            exchangeAmountInput.text = ""
                            exchangeAmountOutput.text = ""
                            appController.bankManager.updateUserTransactions(true)
                        }
                    }
                }
            } 
        }
    }
    Button {
        id: addAccountBtn
        width: addAccountBtn.hovered ? 42 : 40
        height: addAccountBtn.hovered ? 42 : 40
        
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 40 
        
        layer.enabled: true
        
        background: Rectangle {
            radius: width / 2
            color: addAccountBtn.hovered ? "#3A2DCD" : "#281c9d"
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
            }
        }

        Text {
            text: "+"
            font.pixelSize: 36
            color: "white"
            anchors.centerIn: parent
            anchors.verticalCenter: verticalCenter
            anchors.horizontalCenter: horizontalCenter
            bottomPadding: 5
            anchors.verticalCenterOffset: -2
        }

        onClicked: {
            addAccountPopup.open()
        }
        
        ToolTip.visible: hovered
        ToolTip.text: qsTr("Add new account")
    }
    Popup {
        id: addAccountPopup
        anchors.centerIn: parent
        width: 280
        height: 170
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: "white"
            radius: 14
            border.color: "#281c9d"
            border.width: 2
        }

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            Text {
                text: qsTr("Choose account")
                font.pixelSize: 18
                font.bold: true
                color: "#281c9d"
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
            }

            Button {
                width: parent.width
                height: 45

                contentItem: Text {
                    text: qsTr("Euro Account")
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 10
                    color: parent.hovered ? "#3A2DCD" : "#281c9d"
                }

                onClicked: {
                    
                    if (appController.bankManager.addCurrencyAccount("EUR")) {
                        addAccountPopup.close()

                        if (appController.auth.currentUser.accounts.length > 0) {
                            accountViewRoot.fromAccount = appController.auth.currentUser.accounts[0]
                            fromAccountSelect.currentIndex = 0
                        }

                        if (appController.auth.currentUser.accounts.length > 1) {
                            accountViewRoot.toAccount = appController.auth.currentUser.accounts[1]
                            toAccountSelect.currentIndex = 1
                        }

                        accountViewRoot.updateExchangeOutput()
                    } else {
                        console.log("Could not add EUR account")
                    }
                }
            }
        }
    }
}