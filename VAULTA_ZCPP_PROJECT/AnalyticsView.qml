import QtQuick 6.10
import QtQuick.Controls.Basic 6.10

Item {
    id: analyticsRoot
    anchors.fill: parent

        property int contentPadding: 30
        property int minContentWidth: 680
        property int maxContentWidth: 1800
        property string selectedRange: qsTr("All Time")
        property string selectedType: qsTr("All")
        property string selectedSort: qsTr("Date")

        property string activeMetric: "sumExpense"
        property var chartPoints: []

        property var filteredAmounts: []
        property real maxExpense: 0
        property real minExpense: 0
        property real sumExpense: 0
        property real sumIncome: 0
        property real maxIncome: 0
        property real minIncome: 0

        property real maxWithdrawal: 0
        property real minWithdrawal: 0
        property real sumWithdrawal: 0

        property real maxDeposit: 0
        property real minDeposit: 0
        property real sumDeposit: 0

        property real maxTransfer: 0
        property real minTransfer: 0
        property real sumTransfers: 0

        property real maxExchange: 0
        property real minExchange: 0
        property real sumExchanges: 0

        property int statsVersion: 0

        property string chartTitle: qsTr("Spending Over Time")
        property int hoveredPointIndex: -1
        property real mouseXOnChart: 0
        property real mouseYOnChart: 0




        Component.onCompleted: {
            selectedRange = qsTr("All Time")
            selectedType = qsTr("All")

            appController.bankManager.updateUserTransactions(false)

            Qt.callLater(function() {
                calculateStats()
                generateChartData(activeMetric)
                chartCanvas.requestPaint()
            })
        }

        function pad2(value) {
            return String(value).padStart(2, "0")
        }

        function dayMonthLabel(date) {
            return pad2(date.getDate()) + "." + pad2(date.getMonth() + 1)
        }

        function monthLabel(date) {
            let months = [qsTr("Jan"), qsTr("Feb"), qsTr("Mar"), qsTr("Apr"), qsTr("May"), qsTr("Jun"),
                            qsTr("Jul"), qsTr("Aug"), qsTr("Sep"), qsTr("Oct"), qsTr("Nov"), qsTr("Dec")]

            return months[date.getMonth()]
        }

        function parseDate(dateText) {
            if (!dateText || dateText.length < 10) return new Date()

            let parts = dateText.split(" ")
            let dateParts = parts[0].split(".")
            let timeParts = parts.length > 1 ? parts[1].split(":") : ["0", "0"]

            return new Date(
                parseInt(dateParts[2]),
                parseInt(dateParts[1]) - 1,
                parseInt(dateParts[0]),
                parseInt(timeParts[0]),
                parseInt(timeParts[1])
            )
        }

        function isExpense(type) {
            return type === "TRANSFER OUT"
                || type === "WITHDRAWAL"
                || (type === "PLN TO EUR" && appController.auth.currentUser.account.currency === "PLN")
                || (type === "EUR TO PLN" && appController.auth.currentUser.account.currency === "EUR")
        }

        function isIncome(type) {
            return type === "TRANSFER IN"
                || type === "DEPOSIT"
                || (type === "PLN TO EUR" && appController.auth.currentUser.account.currency === "EUR")
                || (type === "EUR TO PLN" && appController.auth.currentUser.account.currency === "PLN")
        }

        function matchesRange(transactionDate) {
            let now = new Date()

            if (selectedRange === "All Time") return true

            if (selectedRange === "This Month") {
                return transactionDate.getMonth() === now.getMonth()
                    && transactionDate.getFullYear() === now.getFullYear()
            }

            if (selectedRange === "This Year") {
                return transactionDate.getFullYear() === now.getFullYear()
            }

            if (selectedRange === "Last 30 Days") {
                let diff = now.getTime() - transactionDate.getTime()
                return diff <= 30 * 24 * 60 * 60 * 1000
            }
            if(selectedRange === "Today"){
                return transactionDate.getDate() === now.getDate()
                    && transactionDate.getMonth() === now.getMonth()
                    && transactionDate.getFullYear() === now.getFullYear()
            }
            if(selectedRange === "Last 7 Days"){
                let diff = now.getTime() - transactionDate.getTime()
                return diff <=7*24*60*60*1000
            }
            return true
        }

        function matchesType(type) {
            if (selectedType === "All") return true
            if (selectedType === "Expenses") return isExpense(type)
            if (selectedType === "Income") return isIncome(type)
            if (selectedType === "Transfers") return type === "TRANSFER IN" || type === "TRANSFER OUT"
            if (selectedType === "Exchange") return type === "PLN TO EUR" || type === "EUR TO PLN"
            if (selectedType === "ATM") return type === "WITHDRAWAL" || type === "DEPOSIT"
            return true
        }

        function minValue(values) {
            if (values.length === 0) return 0
            values.sort(function(a, b) { return a - b })
            return values[0]
        }

        function maxValue(values) {
            if (values.length === 0) return 0
            values.sort(function(a, b) { return a - b })
            return values[values.length - 1]
        }


        function calculateStats() {
            maxExpense = 0
            minExpense = 0
            sumExpense = 0
            sumIncome = 0
            maxIncome = 0
            minIncome = 0

            maxWithdrawal = 0
            minWithdrawal = 0
            sumWithdrawal = 0

            maxDeposit = 0
            minDeposit = 0
            sumDeposit = 0

            maxTransfer = 0
            minTransfer = 0
            sumTransfers = 0

            maxExchange = 0
            minExchange = 0
            sumExchanges = 0

            let amounts = []
            let totalExpense = 0;
            let totalIncome = 0;

            let expenses = []
            let incomes = []
            let withdrawals = []
            let deposits = []
            let transfers = []
            let exchanges = []

            let totalWithdrawal = 0
            let totalDeposit = 0
            let totalTransfers = 0
            let totalExchanges = 0

            for (let i = 0; i < appController.auth.currentUser.transactions.length; i++) {
                let transaction = appController.auth.currentUser.transactions[i]
                let type = transaction.type
                let date = parseDate(transaction.date)

                if (!matchesRange(date)) continue
                if (!matchesType(type)) continue

                let amount = Math.abs(Number(transaction.amount))

                if (isExpense(type)) {
                    amounts.push(amount)
                    expenses.push(amount)
                    totalExpense += amount
                }

                if (isIncome(type)) {
                    incomes.push(amount)
                    totalIncome += amount
                }

                if (type === "WITHDRAWAL") {
                    withdrawals.push(amount)
                    totalWithdrawal += amount
                }

                if (type === "DEPOSIT") {
                    deposits.push(amount)
                    totalDeposit += amount
                }

                if (type === "TRANSFER OUT" || type === "TRANSFER IN") {
                    transfers.push(amount)
                    totalTransfers += amount
                }

                if (type === "PLN TO EUR" || type === "EUR TO PLN") {
                    exchanges.push(amount)
                    totalExchanges += amount
                }
            }

            filteredAmounts = amounts
            sumExpense = totalExpense
            sumIncome = totalIncome

            sumWithdrawal = totalWithdrawal
            sumDeposit = totalDeposit
            sumTransfers = totalTransfers
            sumExchanges = totalExchanges

            minExpense = minValue(expenses)
            maxExpense = maxValue(expenses)

            minIncome = minValue(incomes)
            maxIncome = maxValue(incomes)

            minWithdrawal = minValue(withdrawals)
            maxWithdrawal = maxValue(withdrawals)

            minDeposit = minValue(deposits)
            maxDeposit = maxValue(deposits)

            minTransfer = minValue(transfers)
            maxTransfer = maxValue(transfers)

            minExchange = minValue(exchanges)
            maxExchange = maxValue(exchanges)

            if (amounts.length === 0) {
                maxExpense = 0
                minExpense = 0
                statsVersion++
                return
            }

            amounts.sort(function(a, b) { return a - b })

            minExpense = amounts[0]
            maxExpense = amounts[amounts.length - 1]

            let sum = 0
            for (let j = 0; j < amounts.length; j++) sum += amounts[j]

            statsVersion++
        }

        function bucketKey(date) {
            if (selectedRange === "Last 7 Days"
                    || selectedRange === "Last 30 Days"
                    || selectedRange === "This Month"
                    || selectedRange === "Today") {
                return date.getFullYear() + "-"
                    + pad2(date.getMonth() + 1) + "-"
                    + pad2(date.getDate())
            }

            if (selectedRange === "This Year") {
                return date.getFullYear() + "-" + pad2(date.getMonth() + 1)
            }

            return String(date.getFullYear())
        }
        function bucketLabel(key) {
            if (selectedRange === "Last 7 Days"
                    || selectedRange === "Last 30 Days"
                    || selectedRange === "This Month"
                    || selectedRange === "Today") {
                let parts = key.split("-")
                return parts[2] + "." + parts[1]
            }

            if (selectedRange === "This Year") {
                let parts = key.split("-")
                let monthIndex = parseInt(parts[1]) - 1
                let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                                "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

                return months[monthIndex]
            }

            return key
        }

        function metricMatchesForChart(metricKey, type) {
            if (metricKey === "maxExpense"
                    || metricKey === "minExpense"
                    || metricKey === "sumExpense") {
                return isExpense(type)
            }

            if (metricKey === "maxIncome"
                    || metricKey === "minIncome"
                    || metricKey === "sumIncome") {
                return isIncome(type)
            }

            if (metricKey === "maxTransfer"
                    || metricKey === "minTransfer"
                    || metricKey === "sumTransfers") {
                return type === "TRANSFER OUT" || type === "TRANSFER IN"
            }

            if (metricKey === "maxExchange"
                    || metricKey === "minExchange"
                    || metricKey === "sumExchanges") {
                return type === "PLN TO EUR" || type === "EUR TO PLN"
            }

            if (metricKey === "maxWithdrawal"
                    || metricKey === "minWithdrawal"
                    || metricKey === "sumWithdrawal") {
                return type === "WITHDRAWAL"
            }

            if (metricKey === "maxDeposit"
                    || metricKey === "minDeposit"
                    || metricKey === "sumDeposit") {
                return type === "DEPOSIT"
            }

            return false
        }

        function isMaxMetric(metricKey) {
            return metricKey.indexOf("max") === 0
        }

        function isMinMetric(metricKey) {
            return metricKey.indexOf("min") === 0
        }

        function isSumMetric(metricKey) {
            return metricKey.indexOf("sum") === 0
        }

        function aggregateValueForBucket(metricKey, currentValue, amount) {
            if (isMaxMetric(metricKey)) {
                return currentValue === null ? amount : Math.max(currentValue, amount)
            }

            if (isMinMetric(metricKey)) {
                return currentValue === null ? amount : Math.min(currentValue, amount)
            }

            if (isSumMetric(metricKey)) {
                return (currentValue === null ? 0 : currentValue) + amount
            }

            return currentValue === null ? amount : currentValue
        }
        function createEmptyBuckets() {
            let buckets = {}
            let now = new Date()

            if (selectedRange === "Today") {
                let key = bucketKey(now)
                buckets[key] = { label: bucketLabel(key), value: null, count: 0 }
                return buckets
            }

            if (selectedRange === "Last 7 Days" || selectedRange === "Last 30 Days") {
                let days = selectedRange === "Last 7 Days" ? 7 : 30

                for (let i = days - 1; i >= 0; i--) {
                    let d = new Date(now)
                    d.setDate(now.getDate() - i)

                    let key = bucketKey(d)
                    buckets[key] = { label: bucketLabel(key), value: null, count: 0 }
                }

                return buckets
            }

            if (selectedRange === "This Month") {
                let year = now.getFullYear()
                let month = now.getMonth()
                let lastDay = new Date(year, month + 1, 0).getDate()

                for (let day = 1; day <= lastDay; day++) {
                    let d = new Date(year, month, day)
                    let key = bucketKey(d)
                    buckets[key] = { label: bucketLabel(key), value: null, count: 0 }
                }

                return buckets
            }

            if (selectedRange === "This Year") {
                let year = now.getFullYear()

                for (let monthIndex = 0; monthIndex < 12; monthIndex++) {
                    let d = new Date(year, monthIndex, 1)
                    let key = bucketKey(d)
                    buckets[key] = { label: bucketLabel(key), value: null, count: 0 }
                }

                return buckets
            }

            return {}
        }
        function generateChartData(metricKey) {
            let buckets = createEmptyBuckets()

            for (let i = 0; i < appController.auth.currentUser.transactions.length; i++) {
                let transaction = appController.auth.currentUser.transactions[i]
                let type = transaction.type
                let date = parseDate(transaction.date)

                if (!metricMatchesForChart(metricKey, type)) continue

                let key = bucketKey(date)
                let amount = Math.abs(Number(transaction.amount))

                if (!buckets[key]) {
                    buckets[key] = {
                        label: key,
                        value: null,
                        count: 0
                    }
                }

                buckets[key].value = aggregateValueForBucket(metricKey, buckets[key].value, amount)
                buckets[key].count += 1
            }

            let result = []

            for (let key in buckets) {
                result.push({
                    label: bucketLabel(key),
                    sortKey: key,
                    value: buckets[key].value === null ? 0 : buckets[key].value,
                    count: buckets[key].count
                })
            }

            result.sort(function(a, b) {
                return a.sortKey.localeCompare(b.sortKey)
            })

            chartPoints = result

            chartTitle = metricTitle(metricKey) + " " + rangeTitle()
        }
        function formatAxisValue(value, maxValue) {
            if (maxValue <= 10) {
                return value.toFixed(2)
            }

            if (maxValue <= 100) {
                return value.toFixed(1)
            }

            return Math.round(value).toString()
        }

        function rangeTitle() {
            if (selectedRange === "Today") return "Today"
            if (selectedRange === "Last 7 Days") return "Last 7 Days"
            if (selectedRange === "Last 30 Days") return "Last 30 Days"
            if (selectedRange === "This Month") return "This Month"
            if (selectedRange === "This Year") return "This Year"
            if (selectedRange === "All Time") return "By Year"

            return ""
        } 

        function metricTitle(metricKey) {
            if (metricKey === "maxExpense") return "Max Expense"
            if (metricKey === "minExpense") return "Min Expense"
            if (metricKey === "sumExpense") return "Expenses"

            if (metricKey === "maxIncome") return "Max Income"
            if (metricKey === "minIncome") return "Min Income"
            if (metricKey === "sumIncome") return "Incomes"

            if (metricKey === "maxTransfer") return "Max Transfer"
            if (metricKey === "minTransfer") return "Min Transfer"
            if (metricKey === "sumTransfers") return "Transfers"

            if (metricKey === "maxExchange") return "Max Exchange"
            if (metricKey === "minExchange") return "Min Exchange"
            if (metricKey === "sumExchanges") return "Exchanges"

            if (metricKey === "maxWithdrawal") return "Max Withdrawal"
            if (metricKey === "minWithdrawal") return "Min Withdrawal"
            if (metricKey === "sumWithdrawal") return "Withdrawals"

            if (metricKey === "maxDeposit") return "Max Deposit"
            if (metricKey === "minDeposit") return "Min Deposit"
            if (metricKey === "sumDeposit") return "Deposits"

            return "Analysis"
        }

        function statCardsModel() {
            if (selectedType === "ATM") {
                return [
                    {
                        key: "maxWithdrawal",
                        value: maxWithdrawal,
                        label: qsTr("Max Withdrawal"),
                        description: qsTr("Highest ATM withdrawal"),
                        color: "#e74c3c"
                    },
                    {
                        key: "minWithdrawal",
                        value: minWithdrawal,
                        label: qsTr("Min Withdrawal"),
                        description: qsTr("Lowest ATM withdrawal"),
                        color: "#e74c3c"
                    },
                    {
                        key: "sumWithdrawal",
                        value: sumWithdrawal,
                        label: qsTr("Withdrawals"),
                        description: qsTr("Total ATM withdrawals"),
                        color: "#e74c3c"
                    },
                    {
                        key: "maxDeposit",
                        value: maxDeposit,
                        label: qsTr("Max Deposit"),
                        description: qsTr("Highest ATM deposit"),
                        color: "#2ecc71"
                    },
                    {
                        key: "minDeposit",
                        value: minDeposit,
                        label: qsTr("Min Deposit"),
                        description: qsTr("Lowest ATM deposit"),
                        color: "#2ecc71"
                    },
                    {
                        key: "sumDeposit",
                        value: sumDeposit,
                        label: qsTr("Deposits"),
                        description: qsTr("Total ATM deposits"),
                        color: "#2ecc71"
                    }
                ]
            }
            if(selectedType === "Expenses"){
                return [
                    {
                        key: "maxExpense",
                        value: maxExpense,
                        label: qsTr("Max"),
                        description: qsTr("Highest Expense"),
                        color: "#e74c3c"
                    },
                    {
                        key: "minExpense",
                        value: minExpense,
                        label: qsTr("Min"),
                        description: qsTr("Lowest Expense"),
                        color: "#2ecc71"
                    },
                    {
                        key: "sumExpense",
                        value: sumExpense,
                        label: qsTr("Expenses"),
                        description: qsTr("Sum expense"),
                        color: "#281c9d"
                    }
                ]
            }
            if(selectedType === "Income"){
                return [
                    {
                        key: "maxIncome",
                        value: maxIncome,
                        label: qsTr("Max"),
                        description: qsTr("Highest Income"),
                        color: "#e74c3c"
                    },
                    {
                        key: "minIncome",
                        value: minIncome,
                        label: qsTr("Min"),
                        description: qsTr("Lowest Income"),
                        color: "#2ecc71"
                    },
                    {
                        key: "sumIncome",
                        value: sumIncome,
                        label: qsTr("Incomes"),
                        description: qsTr("Sum Incomes"),
                        color: "#281c9d"
                    }
                ]
            }
            if(selectedType === "Transfers"){
                return [
                    {
                        key: "maxTransfer",
                        value: maxTransfer,
                        label: qsTr("Max"),
                        description: qsTr("Highest Transfer"),
                        color: "#e74c3c"
                    },
                    {
                        key: "minTransfer",
                        value: minTransfer,
                        label: qsTr("Min"),
                        description: qsTr("Lowest Transfer"),
                        color: "#2ecc71"
                    },
                    {
                        key: "sumTransfers",
                        value: sumTransfers,
                        label: qsTr("Transfers"),
                        description: qsTr("Sum transfers"),
                        color: "#281c9d"
                    }
                ]
            }
            if(selectedType === "Exchange"){
                return [
                    {
                        key: "maxExchange",
                        value: maxExchange,
                        label: qsTr("Max"),
                        description: qsTr("Highest Exchange"),
                        color: "#e74c3c"
                    },
                    {
                        key: "minExchange",
                        value: minExchange,
                        label: qsTr("Min"),
                        description: qsTr("Lowest Exchange"),
                        color: "#2ecc71"
                    },
                    {
                        key: "sumExchanges",
                        value: sumExchanges,
                        label: qsTr("Exchanges"),
                        description: qsTr("Sum Exchanges"),
                        color: "#281c9d"
                    }
                ]
            }
            return [
                {
                    key: "maxExpense",
                    value: maxExpense,
                    label: qsTr("Max"),
                    description: qsTr("Highest Expense"),
                    color: "#e74c3c"
                },
                {
                    key: "minExpense",
                    value: minExpense,
                    label: qsTr("Min"),
                    description: qsTr("Lowest Expense"),
                    color: "#2ecc71"
                },
                {
                    key: "sumExpense",
                    value: sumExpense,
                    label: qsTr("Expenses"),
                    description: qsTr("Sum expenses"),
                    color: "#281c9d"
                },
                {
                    key: "sumIncome",
                    value: sumIncome,
                    label: qsTr("Incomes"),
                    description: qsTr("Sum income"),
                    color: "#281c9d"
                }
            ]
        }

        component FilterCombo: ComboBox {
            id: combo
            property int comboWidth: 100

            width: comboWidth
            height: 40

            background: Rectangle {
                color: "#f7f7f8"
                radius: 12
                border.color: "#d8d8d8"
                border.width: 1
            }

            contentItem: Text {
                text: combo.displayText
                color: "#281c9d"
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
                leftPadding: 20
            }

            delegate: ItemDelegate {
                width: combo.width
                height: 42

                contentItem: Text {
                    text: modelData
                    color: "black"
                    font.pixelSize: 14
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 14
                }

                background: Rectangle {
                    anchors.fill: parent
                    anchors.margins: 4
                    radius: 8
                    color: parent.hovered ? "#f0f0f0" : "white"
                }

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }
                onClicked: {
                    combo.currentIndex = index
                    combo.activated(index)
                    combo.popup.close()
                }
            }

            popup: Popup {
                y: combo.height + 4
                width: combo.width
                padding: 0
                implicitHeight: contentItem.implicitHeight

                background: Rectangle {
                    color: "white"
                    radius: 10
                    border.color: "#d0d0d0"
                    border.width: 1
                }

                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: combo.popup.visible ? combo.delegateModel : null
                    currentIndex: combo.highlightedIndex
                }
            }
        }

        component StatCard: Rectangle {
            property color accentColor: "#281c9d"
            property string valueText: ""
            property string labelText: ""
            property string descriptionText: ""

            width: Math.max(220, valueTextItem.implicitWidth + 56)
            height: 200
            radius: 14
            color: "white"
            border.color: "#dedede"
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 28
                spacing: 18

                Text {
                    id: valueTextItem
                    text: valueText
                    color: accentColor
                    font.pixelSize: 26
                    font.bold: true
                }

                Text {
                    text: labelText
                    color: "#687080"
                    font.pixelSize: 16
                    font.bold: true
                }

                Text {
                    text: descriptionText
                    color: "#4d586b"
                    font.pixelSize: 15
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }
        }
        ScrollView {
            id: analyticsScroll
            anchors.fill: parent
            clip: true

            ScrollBar.horizontal.policy: ScrollBar.AsNeeded
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            contentWidth: analyticsContent.width + analyticsRoot.contentPadding * 2
            contentHeight: Math.max(height, analyticsContent.y + analyticsContent.implicitHeight + analyticsRoot.contentPadding)

            Column {
                id: analyticsContent

                x: analyticsRoot.contentPadding
                y: 32
                width: Math.max(
                           analyticsRoot.minContentWidth,
                           Math.min(
                               analyticsRoot.maxContentWidth,
                               analyticsScroll.width - analyticsRoot.contentPadding * 2
                           )
                       )
                spacing: 28


                Text {
                    text: qsTr("Financial Analysis")
                    font.pixelSize: 32
                    font.bold: true
                    color: "#281c9d"
                }

                Rectangle {
                    width: parent.width
                    height: 124
                    radius: 16
                    color: "white"
                    border.color: "#dedede"
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 22
                        spacing: 18

                        Row {
                            spacing: 24

                            Column {
                                spacing: 8
                                Text { text: qsTr("Time Range"); color: "#4d586b"; font.bold: true; font.pixelSize: 15 }
                                FilterCombo {
                                    model: ["Today","Last 7 Days", "Last 30 Days", "This Month",  "This Year", "All Time"]
                                    comboWidth: 180
                                    currentIndex: 5
                                    onActivated: function(index) {
                                        analyticsRoot.selectedRange = model[index]
                                        analyticsRoot.calculateStats()

                                        if (analyticsRoot.activeMetric !== "") {
                                            analyticsRoot.generateChartData(analyticsRoot.activeMetric)
                                            chartCanvas.requestPaint()
                                        }
                                    }
                                }
                            }

                            Column {
                                spacing: 8
                                Text { text: qsTr("Transaction Type"); color: "#4d586b"; font.bold: true; font.pixelSize: 15 }
                                FilterCombo {
                                    model: ["All", "Expenses", "Income", "Transfers", "Exchange", "ATM"]
                                    comboWidth: 180
                                    currentIndex: 0
                                    onActivated: function(index) {
                                        analyticsRoot.selectedType = model[index]
                                        analyticsRoot.calculateStats()

                                        let cards = analyticsRoot.statCardsModel()
                                        if (cards.length > 0) {
                                            analyticsRoot.activeMetric = cards[0].key
                                            analyticsRoot.generateChartData(analyticsRoot.activeMetric)
                                            chartCanvas.requestPaint()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                ScrollView {
                width: parent.width
                height: 230
                clip: true

                ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                ScrollBar.horizontal.policy: ScrollBar.AsNeeded

                Row {
                    spacing: 24

                    Repeater {
                        model: {
                            analyticsRoot.statsVersion
                            return analyticsRoot.statCardsModel()
                        }
                        delegate: StatCard {
                            accentColor: modelData.color
                            valueText: Number(modelData.value).toFixed(2) + " " + appController.auth.currentUser.account.currency
                            labelText: modelData.label
                            descriptionText: modelData.description

                            border.color: analyticsRoot.activeMetric === modelData.key ? "#281c9d" : "#dedede"
                            border.width: analyticsRoot.activeMetric === modelData.key ? 2 : 1

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    analyticsRoot.activeMetric = modelData.key
                                    analyticsRoot.generateChartData(modelData.key)
                                    Qt.callLater(function() {
                                        chartCanvas.requestPaint()                                    
                                    })
                                }
                            }
                        }
                    }
                }
            }
            Rectangle {
                id: chartCard
                width: parent.width
                height: 280
                radius: 14
                color: "white"
                border.color: "#dedede"
                border.width: 1
                visible: analyticsRoot.chartPoints.length > 0

                Text {
                    id: chartTitleText
                    text: analyticsRoot.chartTitle
                    color: "#281c9d"
                    font.pixelSize: 18
                    font.bold: true
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.leftMargin: 20
                    anchors.topMargin: 18
                }

                Canvas {
                    id: chartCanvas
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: chartTitleText.bottom
                    anchors.bottom: parent.bottom
                    anchors.margins: 25
                    anchors.topMargin: 15

                    property real leftPad: 45
                    property real rightPad: 15
                    property real topPad: 15
                    property real bottomPad: 35

                    function pointX(index) {
                        let plotWidth = width - leftPad - rightPad

                        if (analyticsRoot.chartPoints.length <= 1) {
                            return leftPad + plotWidth / 2
                        }

                        return leftPad + index * (plotWidth / (analyticsRoot.chartPoints.length - 1))
                    }

                    function pointY(value, maxValue) {
                        let plotHeight = height - topPad - bottomPad
                        return topPad + plotHeight - (value / maxValue) * plotHeight
                    }

                    onPaint: {
                        let ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)

                        let points = analyticsRoot.chartPoints
                        if (points.length === 0) return

                        let maxValue = 1
                        for (let i = 0; i < points.length; i++) {
                            maxValue = Math.max(maxValue, points[i].value)
                        }

                        let plotWidth = width - leftPad - rightPad
                        let plotHeight = height - topPad - bottomPad

                        ctx.lineWidth = 1
                        ctx.strokeStyle = "#e5e5e5"
                        ctx.fillStyle = "#4d586b"
                        ctx.font = "11px sans-serif"

                        let gridSteps = maxValue <= 2 ? 2 : 4

                        for (let gy = 0; gy <= gridSteps; gy++) {
                            let y = topPad + plotHeight - (plotHeight / gridSteps) * gy
                            let labelValue = (maxValue / gridSteps) * gy

                            ctx.beginPath()
                            ctx.moveTo(leftPad, y)
                            ctx.lineTo(leftPad + plotWidth, y)
                            ctx.stroke()

                            ctx.fillText(analyticsRoot.formatAxisValue(labelValue, maxValue),4, y+4)
                        }

                        ctx.strokeStyle = "#281c9d"
                        ctx.lineWidth = 3
                        ctx.beginPath()

                        for (let p = 0; p < points.length; p++) {
                            let x = pointX(p)
                            let y = pointY(points[p].value, maxValue)

                            if (p === 0) ctx.moveTo(x, y)
                            else ctx.lineTo(x, y)
                        }

                        ctx.stroke()

                        for (let d = 0; d < points.length; d++) {
                            let dx = pointX(d)
                            let dy = pointY(points[d].value, maxValue)

                            ctx.fillStyle = "#281c9d"
                            ctx.beginPath()
                            ctx.arc(dx, dy, 5, 0, Math.PI * 2)
                            ctx.fill()

                            ctx.fillStyle = "#4d586b"
                            ctx.font = "11px sans-serif"
                            ctx.fillText(points[d].label, dx - 14, height - 8)
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true

                        onPositionChanged: function(mouse) {
                            analyticsRoot.mouseXOnChart = mouse.x
                            analyticsRoot.mouseYOnChart = mouse.y

                            let nearest = -1
                            let nearestDistance = 999999

                            for (let i = 0; i < analyticsRoot.chartPoints.length; i++) {
                                let dx = chartCanvas.pointX(i)
                                let dist = Math.abs(mouse.x - dx)

                                if (dist < nearestDistance) {
                                    nearestDistance = dist
                                    nearest = i
                                }
                            }

                            analyticsRoot.hoveredPointIndex = nearestDistance < 35 ? nearest : -1
                        }

                        onExited: analyticsRoot.hoveredPointIndex = -1
                    }
                }

                Rectangle {
                    visible: analyticsRoot.hoveredPointIndex >= 0
                    width: 170
                    height: 78
                    radius: 8
                    color: "white"
                    border.color: "#d0d0d0"
                    border.width: 1

                    x: Math.min(chartCard.width - width - 12, chartCanvas.x + analyticsRoot.mouseXOnChart + 12)
                    y: chartCanvas.y + Math.max(0, analyticsRoot.mouseYOnChart - height - 10)

                    Column {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 4

                        Text {
                            text: analyticsRoot.hoveredPointIndex >= 0
                                    ? analyticsRoot.chartPoints[analyticsRoot.hoveredPointIndex].label
                                    : ""
                            color: "#281c9d"
                            font.bold: true
                            font.pixelSize: 13
                        }

                        Text {
                            text: analyticsRoot.hoveredPointIndex >= 0
                                    ? Number(analyticsRoot.chartPoints[analyticsRoot.hoveredPointIndex].value).toFixed(2)
                                    + " " + appController.auth.currentUser.account.currency
                                    : ""
                            color: "#333"
                            font.pixelSize: 13
                        }

                        Text {
                            text: analyticsRoot.hoveredPointIndex >= 0
                                    ? qsTr("Transactions: ") + analyticsRoot.chartPoints[analyticsRoot.hoveredPointIndex].count
                                    : ""
                            color: "#777"
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }
    }
}
