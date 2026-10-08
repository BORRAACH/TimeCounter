import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCore

ApplicationWindow {
    id: window

    width: 1000
    height: 640
    visible: true
    title: "Time Counter"
    color: Theme.colours.background || "#11140e"

    // Legacy checkbox state, only read once to migrate to hours.
    Settings {
        id: checkedStates

        category: "checkedStates"
    }

    Settings {
        id: hoursStore

        category: "hours"
    }

    // Start (Sunday) of the week the current hours belong to, as YYYY-MM-DD.
    Settings {
        id: weekStore

        category: "week"
    }

    Settings {
        id: goalsStore

        category: "goals"
    }

    Settings {
        id: uiStore

        category: "ui"
    }

    ListModel {
        id: subjectsModel

        ListElement {
            name: "Fisica"
            time: 15
        }

        ListElement {
            name: "Matematica"
            time: 15
        }

        ListElement {
            name: "Quimica"
            time: 15
        }

        ListElement {
            name: "Portugues"
            time: 6
        }

        ListElement {
            name: "Computação"
            time: 6
        }

    }

    // Sums the old 1h/2h checkboxes into a plain hour count per subject.
    function migrateCheckboxes() {
        if (hoursStore.value("migrated", "false") === "true" || hoursStore.value("migrated", false) === true)
            return;

        for (let s = 0; s < subjectsModel.count; s++) {
            const subject = subjectsModel.get(s);
            let hours = 0;
            for (let i = 0; i < subject.time % 2; i++) {
                if (checkedStates.value(subject.name + "_1h_" + i, "false").toString() === "true")
                    hours += 1;
            }
            for (let i = 0; i < Math.floor(subject.time / 2); i++) {
                if (checkedStates.value(subject.name + "_2h_" + i, "false").toString() === "true")
                    hours += 2;
            }
            hoursStore.setValue(subject.name, hours);
        }
        hoursStore.setValue("migrated", true);
        hoursStore.sync();
    }

    // Table column widths (px, for the 24-26px table font). Full subject names
    // are used while they fit; otherwise the abbreviated set takes over.
    readonly property var fullHeaders: ["Semana", "Total", "Física", "Matemática", "Química", "Português", "Computação", "%"]
    readonly property var compactHeaders: ["Sem.", "Total", "Fís.", "Mat.", "Quí.", "Port.", "Comp.", "%"]
    readonly property var fullColumns: [100, 68, 78, 150, 104, 134, 160, 96]
    readonly property var compactColumns: [64, 68, 52, 58, 56, 66, 80, 92]

    function columnsWidth(columns) {
        // 8px column spacing plus the row's 12px side padding
        return columns.reduce((a, b) => a + b, 0) + 8 * (columns.length - 1) + 24;
    }

    readonly property bool compactTable: scroll.availableWidth < columnsWidth(fullColumns) + 48

    // Once abbreviated and still too wide, shrink the whole table (font,
    // columns and padding) in proportion, down to half size; below that the
    // ScrollView scrolls horizontally instead.
    readonly property real tableScale: compactTable ? Math.max(0.5, Math.min(1, (scroll.availableWidth - 48) / columnsWidth(compactColumns))) : 1

    function ts(px) {
        return Math.max(1, Math.round(px * tableScale));
    }

    readonly property var tableHeaders: compactTable ? compactHeaders : fullHeaders
    readonly property var tableColumns: (compactTable ? compactColumns : fullColumns).map(w => w * tableScale)
    readonly property real tableWidth: columnsWidth(compactTable ? compactColumns : fullColumns) * tableScale

    // Hours studied per subject, kept in sync with hoursStore.
    property var hours: ({})
    readonly property int totalDone: {
        let sum = 0;
        for (let s = 0; s < subjectsModel.count; s++)
            sum += hours[subjectsModel.get(s).name] ?? 0;
        return sum;
    }
    // Goals: per-subject hours, plus an optional fixed total (-1 = follow the sum).
    property var goals: ({})
    property int totalGoalOverride: -1
    readonly property int sumGoals: {
        let sum = 0;
        for (let s = 0; s < subjectsModel.count; s++)
            sum += goals[subjectsModel.get(s).name] ?? subjectsModel.get(s).time;
        return sum;
    }
    readonly property int totalGoal: totalGoalOverride >= 0 ? totalGoalOverride : sumGoals

    function goalOf(name, fallback) {
        return goals[name] ?? fallback;
    }

    function loadGoals() {
        const loaded = {};
        for (let s = 0; s < subjectsModel.count; s++) {
            const subject = subjectsModel.get(s);
            loaded[subject.name] = Math.max(0, Number(goalsStore.value(subject.name, subject.time)));
        }
        goals = loaded;
        totalGoalOverride = Number(goalsStore.value("total", -1));
    }

    function setGoal(name, value) {
        const next = Object.assign({}, goals);
        next[name] = value;
        goals = next;
        goalsStore.setValue(name, value);
        goalsStore.sync();
    }

    function setTotalGoal(value) {
        totalGoalOverride = value;
        goalsStore.setValue("total", value);
        goalsStore.sync();
    }

    function loadHours() {
        const loaded = {};
        for (let s = 0; s < subjectsModel.count; s++) {
            const subject = subjectsModel.get(s);
            loaded[subject.name] = Math.max(0, Number(hoursStore.value(subject.name, 0)));
        }
        hours = loaded;
    }

    // Hours studied per day of the current week: { "YYYY-MM-DD": hours }.
    property var dailyHours: ({})
    property string todayKey: ""

    function parseDate(key) {
        const p = key.split("-");
        return new Date(Number(p[0]), Number(p[1]) - 1, Number(p[2]));
    }

    // Chart views, selectable from the chips above the chart.
    readonly property var chartModes: [
        { chip: "Dias", title: "Horas por dia (semana atual)", minScale: 4 },
        { chip: "Semanas", title: "Porcentagem por semana", minScale: 100 },
        { chip: "Meses", title: "Horas por mês", minScale: 10 },
        { chip: "Matérias", title: "Horas por matéria (semana atual)", minScale: 4 }
    ]
    property int chartMode: 0
    // 0 = Clock (counters), 1 = Statistics (chart + table)
    property int page: 0

    function setPage(index) {
        page = index;
        uiStore.setValue("page", index);
        uiStore.sync();
    }

    function daysOfCurrentWeek() {
        const names = ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"];
        const start = sundayOf(parseDate(todayKey));
        const items = [];
        for (let i = 0; i < 7; i++) {
            const key = isoDate(new Date(start.getFullYear(), start.getMonth(), start.getDate() + i));
            const h = dailyHours[key] ?? 0;
            items.push({ label: names[i], value: h, text: h + "h", highlight: key === todayKey, dim: key > todayKey });
        }
        return items;
    }

    // Percentage of the goal in the (up to) 12 most recent registered weeks, oldest first.
    function registeredWeeks() {
        const recent = Weeks.records.slice(0, 12).reverse();
        return recent.map(r => ({ label: r.week + "ª", value: r.percentage, text: Math.round(r.percentage) + "%", highlight: false, dim: false }));
    }

    // Hours per month for the last 6 months. Weeks typed in by hand have no
    // date, so they are not counted here.
    function monthlyHours() {
        const names = ["jan", "fev", "mar", "abr", "mai", "jun", "jul", "ago", "set", "out", "nov", "dez"];
        const totals = {};
        const add = (date, h) => {
            const k = date.getFullYear() + "-" + date.getMonth();
            totals[k] = (totals[k] ?? 0) + h;
        };
        for (const r of Weeks.records) {
            if (!r.weekStart)
                continue;
            const start = parseDate(r.weekStart);
            if (r.days && r.days.length === 7) {
                for (let i = 0; i < 7; i++)
                    add(new Date(start.getFullYear(), start.getMonth(), start.getDate() + i), r.days[i]);
            } else {
                add(start, r.totalHours);
            }
        }
        for (const key in dailyHours)
            add(parseDate(key), dailyHours[key]);

        const now = parseDate(todayKey);
        const items = [];
        for (let k = 5; k >= 0; k--) {
            const d = new Date(now.getFullYear(), now.getMonth() - k, 1);
            const h = totals[d.getFullYear() + "-" + d.getMonth()] ?? 0;
            items.push({ label: names[d.getMonth()], value: h, text: h + "h", highlight: k === 0, dim: false });
        }
        return items;
    }

    function hoursBySubject() {
        const short = { "Fisica": "Fís", "Matematica": "Mat", "Quimica": "Quí", "Portugues": "Port", "Computação": "Comp" };
        const items = [];
        for (let s = 0; s < subjectsModel.count; s++) {
            const name = subjectsModel.get(s).name;
            const h = hours[name] ?? 0;
            items.push({ label: short[name] ?? name, value: h, text: h + "h", highlight: false, dim: false });
        }
        return items;
    }

    readonly property var chartItems: {
        if (todayKey === "")
            return [];
        switch (chartMode) {
        case 1: return registeredWeeks();
        case 2: return monthlyHours();
        case 3: return hoursBySubject();
        default: return daysOfCurrentWeek();
        }
    }
    readonly property real chartMax: Math.max(chartModes[chartMode].minScale, ...chartItems.map(d => d.value))

    function loadDaily() {
        try {
            dailyHours = JSON.parse(weekStore.value("days", "{}").toString());
        } catch (e) {
            dailyHours = {};
        }
    }

    function saveDaily(map) {
        dailyHours = map;
        weekStore.setValue("days", JSON.stringify(map));
        weekStore.sync();
    }

    // `log` false = don't count the change as studying (used by the weekly reset).
    function setHours(name, value, log = true) {
        const old = hours[name] ?? 0;
        const next = Object.assign({}, hours);
        next[name] = value;
        hours = next;
        hoursStore.setValue(name, value);
        hoursStore.sync();

        if (log && value !== old) {
            const key = isoDate(new Date());
            const days = Object.assign({}, dailyHours);
            days[key] = Math.max(0, (days[key] ?? 0) + (value - old));
            saveDaily(days);
        }
    }

    function isoDate(d) {
        const pad = n => (n < 10 ? "0" : "") + n;
        return d.getFullYear() + "-" + pad(d.getMonth() + 1) + "-" + pad(d.getDate());
    }

    // Weeks run Sunday to Saturday.
    function sundayOf(d) {
        return new Date(d.getFullYear(), d.getMonth(), d.getDate() - d.getDay());
    }

    // On the Saturday -> Sunday rollover (or on start-up after one happened
    // while the app was closed) archive the finished week and start over.
    function checkWeek() {
        todayKey = isoDate(new Date());
        const current = isoDate(sundayOf(new Date()));
        const stored = weekStore.value("start", "").toString();

        if (stored === "") {
            weekStore.setValue("start", current);
            weekStore.sync();
            return;
        }
        if (stored >= current)
            return;

        const parts = stored.split("-");
        const saturday = new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]) + 6);
        const subjects = {};
        for (let s = 0; s < subjectsModel.count; s++) {
            const name = subjectsModel.get(s).name;
            subjects[name] = hours[name] ?? 0;
        }
        const startDate = parseDate(stored);
        const days = [];
        for (let i = 0; i < 7; i++)
            days.push(dailyHours[isoDate(new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate() + i))] ?? 0);
        Weeks.archive(stored, isoDate(saturday), subjects, totalGoal, days);

        for (let s = 0; s < subjectsModel.count; s++)
            setHours(subjectsModel.get(s).name, 0, false);
        saveDaily({});
        weekStore.setValue("start", current);
        weekStore.sync();
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: window.checkWeek()
    }

    // Hours typed into the "add previous week" form, per subject.
    property int manualWeek: 1
    property var manualHours: ({})
    readonly property int manualTotal: Object.values(manualHours).reduce((a, b) => a + b, 0)

    function setManualHours(name, value) {
        const next = Object.assign({}, manualHours);
        next[name] = value;
        manualHours = next;
    }

    Component.onCompleted: {
        migrateCheckboxes();
        loadHours();
        loadGoals();
        loadDaily();
        const savedMode = Number(uiStore.value("chartMode", 0));
        chartMode = savedMode >= 0 && savedMode < chartModes.length ? savedMode : 0;
        page = Number(uiStore.value("page", 0)) === 1 ? 1 : 0;
        checkWeek();
    }

    ScrollView {
        id: scroll

        anchors.fill: parent
        contentWidth: window.page === 1 ? Math.max(availableWidth, window.tableWidth + 48) : availableWidth

        ColumnLayout {
            id: content

            readonly property int cardWidth: 200
            readonly property int gap: 12
            readonly property int columns: Math.max(1, Math.min(subjectsModel.count, Math.floor((width - 16 + gap) / (cardWidth + gap))))

            width: parent.width
            height: Math.max(implicitHeight, scroll.availableHeight)
            spacing: 12

            // Keep clear of the corner buttons
            Item {
                Layout.preferredHeight: 48
            }

            // ---- Clock page ----
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                visible: window.page === 0
                spacing: 12

            // Total study time: free-standing ring, three times the size of a card's ring
            CircularProgress {
                id: totalRing

                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 16
                Layout.bottomMargin: 8
                Layout.preferredWidth: 420
                Layout.preferredHeight: 420

                strokeWidth: 30
                spacing: 18
                value: window.totalGoal > 0 ? window.totalDone / window.totalGoal : 0

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 0

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: window.totalDone + "h"
                        font.pixelSize: 78
                        font.bold: true
                        color: totalRing.fgColour
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: "de " + window.totalGoal + "h"
                        font.pixelSize: 30
                        color: Theme.colours.onSurfaceVariant || palette.text
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 4
                        text: "Total de estudo"
                        font.pixelSize: 22
                        font.bold: true
                        color: Theme.colours.onSurface || "white"
                    }
                }
            }

            // Subject cards, rows centred (including a shorter last row)
            Repeater {
                model: Math.ceil(subjectsModel.count / content.columns)

                delegate: Row {
                    id: cardRow

                    required property int index

                    Layout.alignment: Qt.AlignHCenter
                    spacing: content.gap

                    Repeater {
                        model: Math.min(content.columns, subjectsModel.count - cardRow.index * content.columns)

                        delegate: SubjectCard {
                            id: card

                            required property int index
                            readonly property var subjectData: subjectsModel.get(cardRow.index * content.columns + index)

                            width: content.cardWidth
                            subject: subjectData.name
                            total: window.goalOf(subjectData.name, subjectData.time)
                            done: window.hours[subjectData.name] ?? 0

                            onChangeRequested: value => window.setHours(subjectData.name, value)
                        }
                    }
                }
            }


            }

            // ---- Statistics page ----
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                visible: window.page === 1
                spacing: 12

            // Chart with selectable view (days / weeks / months / subjects)
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 16
                Layout.preferredWidth: Math.min(600, Math.max(320, scroll.availableWidth - 32))
                Layout.preferredHeight: chartLayout.implicitHeight + 48
                color: Theme.colours.surfaceContainer || "#1d201a"
                radius: 28

            ColumnLayout {
                id: chartLayout

                anchors.fill: parent
                anchors.margins: 24
                spacing: 8

                // Header: title on the left, view dropdown in the top-right corner
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Label {
                        Layout.fillWidth: true
                        text: window.chartModes[window.chartMode].title
                        font.pixelSize: 22
                        font.bold: true
                        elide: Text.ElideRight
                        color: Theme.colours.onSurface || "white"
                    }

                    Button {
                        id: modeButton

                        readonly property bool round: pressed || modeMenu.opened

                        Layout.alignment: Qt.AlignTop
                        implicitHeight: 40
                        leftPadding: 16
                        rightPadding: 8
                        onClicked: modeMenu.opened ? modeMenu.close() : modeMenu.open()

                        contentItem: RowLayout {
                            spacing: 4

                            Label {
                                text: window.chartModes[window.chartMode].chip
                                font.pixelSize: 14
                                color: Theme.colours.onSecondaryContainer || "white"
                            }

                            Label {
                                text: "expand_more"
                                font.family: "Material Symbols Rounded"
                                font.pixelSize: 20
                                renderType: Text.NativeRendering
                                rotation: modeMenu.opened ? 180 : 0
                                color: Theme.colours.onSecondaryContainer || "white"

                                Behavior on rotation {
                                    NumberAnimation { duration: 200 }
                                }
                            }
                        }

                        background: Rectangle {
                            radius: modeButton.round ? height / 2 : 16
                            color: Theme.colours.secondaryContainer || "#3f4a3c"

                            Behavior on radius {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.BezierSpline
                                    easing.bezierCurve: [0.34, 0.8, 0.34, 1, 1, 1]
                                }
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: Theme.colours.onSecondaryContainer || "white"
                                opacity: modeButton.pressed ? 0.1 : modeButton.hovered ? 0.08 : 0
                            }
                        }

                        Popup {
                            id: modeMenu

                            x: modeButton.width - width
                            y: modeButton.height + 4
                            padding: 4
                            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

                            enter: Transition {
                                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 150 }
                            }

                            exit: Transition {
                                NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 100 }
                            }

                            background: Rectangle {
                                color: Theme.colours.surfaceContainerHigh || "#272b24"
                                radius: 16
                            }

                            contentItem: Column {
                                spacing: 2

                                Repeater {
                                    model: window.chartModes

                                    delegate: ItemDelegate {
                                        id: option

                                        required property int index
                                        required property var modelData
                                        readonly property bool selected: window.chartMode === index

                                        width: 180
                                        implicitHeight: 40
                                        onClicked: {
                                            window.chartMode = index;
                                            uiStore.setValue("chartMode", index);
                                            uiStore.sync();
                                            modeMenu.close();
                                        }

                                        contentItem: RowLayout {
                                            spacing: 8

                                            Label {
                                                Layout.fillWidth: true
                                                text: option.modelData.chip
                                                font.pixelSize: 14
                                                color: Theme.colours.onSurface || "white"
                                            }

                                            Label {
                                                visible: option.selected
                                                text: "check"
                                                font.family: "Material Symbols Rounded"
                                                font.pixelSize: 20
                                                renderType: Text.NativeRendering
                                                color: Theme.colours.primary || "#add28e"
                                            }
                                        }

                                        background: Rectangle {
                                            radius: 12
                                            color: option.selected ? (Theme.colours.secondaryContainer || "#3f4a3c") : "transparent"

                                            Rectangle {
                                                anchors.fill: parent
                                                radius: parent.radius
                                                color: Theme.colours.onSurface || "white"
                                                opacity: option.pressed ? 0.1 : option.hovered ? 0.08 : 0
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    spacing: 8

                    Repeater {
                        model: window.chartItems

                        delegate: ColumnLayout {
                            id: barColumn

                            required property var modelData

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.preferredWidth: 1
                            spacing: 4

                            Label {
                                Layout.alignment: Qt.AlignHCenter
                                text: barColumn.modelData.text
                                font.pixelSize: 14
                                font.bold: true
                                opacity: barColumn.modelData.value > 0 ? 1 : 0
                                color: Theme.colours.onSurface || "white"
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: Math.min(48, parent.width * 0.7)
                                    height: barColumn.modelData.value > 0 ? Math.max(8, parent.height * Math.min(1, barColumn.modelData.value / window.chartMax)) : 4
                                    topLeftRadius: 10
                                    topRightRadius: 10
                                    bottomLeftRadius: 2
                                    bottomRightRadius: 2
                                    color: barColumn.modelData.value > 0
                                        ? (barColumn.modelData.highlight ? (Theme.colours.primary || "#add28e") : (Theme.colours.secondary || "#c2c9bd"))
                                        : (Theme.colours.surfaceContainerHighest || "#33362f")

                                    Behavior on height {
                                        NumberAnimation {
                                            duration: 350
                                            easing.type: Easing.BezierSpline
                                            easing.bezierCurve: [0.34, 0.8, 0.34, 1, 1, 1]
                                        }
                                    }
                                }
                            }

                            Label {
                                Layout.alignment: Qt.AlignHCenter
                                text: barColumn.modelData.label
                                font.pixelSize: 13
                                font.bold: barColumn.modelData.highlight
                                opacity: barColumn.modelData.dim ? 0.5 : 1
                                color: barColumn.modelData.highlight ? (Theme.colours.primary || "#add28e") : (Theme.colours.onSurfaceVariant || palette.text)
                            }
                        }
                    }
                }

                Label {
                    Layout.alignment: Qt.AlignHCenter
                    visible: window.chartItems.length === 0
                    text: "Nenhuma semana registrada ainda"
                    font.pixelSize: 13
                    color: Theme.colours.onSurfaceVariant || palette.text
                }
            }
            }

            // Divider between chart and table, faint
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 36
                Layout.preferredWidth: Math.min(600, Math.max(320, scroll.availableWidth - 32))
                Layout.preferredHeight: 5
                radius: 2.5
                color: Qt.alpha(Theme.colours.onSurface || "white", 0.15)
            }

            // Archived weeks: free-standing table, a row gets a box on hover
            ColumnLayout {
                id: weeksTable

                readonly property var colWidths: window.tableColumns

                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 36
                spacing: 10

                Label {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 6
                    text: "Semanas anteriores"
                    font.pixelSize: window.ts(32)
                    font.bold: true
                    color: Theme.colours.onSurface || "white"
                }

                // Header
                Row {
                    Layout.leftMargin: window.ts(12)
                    spacing: window.ts(8)

                    Repeater {
                        model: window.tableHeaders

                        delegate: Label {
                            required property int index
                            required property string modelData

                            width: weeksTable.colWidths[index]
                            text: modelData
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: window.ts(24)
                            font.bold: true
                            color: Theme.colours.onSurfaceVariant || palette.text
                        }
                    }
                }

                Repeater {
                    model: Weeks.records

                    delegate: Item {
                        id: weekRow

                        required property var modelData
                        readonly property var cells: [
                            modelData.week + "ª",
                            modelData.totalHours + "h",
                            (modelData.subjects["Fisica"] ?? 0) + "h",
                            (modelData.subjects["Matematica"] ?? 0) + "h",
                            (modelData.subjects["Quimica"] ?? 0) + "h",
                            (modelData.subjects["Portugues"] ?? 0) + "h",
                            (modelData.subjects["Computação"] ?? 0) + "h",
                            modelData.percentage.toFixed(1) + "%"
                        ]

                        implicitWidth: cellsRow.implicitWidth + window.ts(24)
                        implicitHeight: cellsRow.implicitHeight + window.ts(16)

                        HoverHandler {
                            id: rowHover
                        }

                        // Hover box; fades on its own so the text stays fully opaque
                        Rectangle {
                            anchors.fill: parent
                            radius: window.ts(14)
                            color: Theme.colours.surfaceContainer || "#1d201a"
                            opacity: rowHover.hovered ? 1 : 0

                            Behavior on opacity {
                                NumberAnimation { duration: 150 }
                            }
                        }

                        Row {
                            id: cellsRow

                            anchors.centerIn: parent
                            spacing: window.ts(8)

                            Repeater {
                                model: weekRow.cells

                                delegate: Label {
                                    required property int index
                                    required property string modelData

                                    width: weeksTable.colWidths[index]
                                    text: modelData
                                    horizontalAlignment: Text.AlignHCenter
                                    font.pixelSize: window.ts(26)
                                    font.weight: Font.DemiBold
                                    // Rows at rest are dimmed; the hovered row lights up
                                    color: rowHover.hovered
                                        ? (Theme.colours.onSurface || "white")
                                        : Qt.alpha(Theme.colours.onSurface || "white", 0.3)

                                    Behavior on color {
                                        ColorAnimation { duration: 150 }
                                    }
                                }
                            }
                        }
                    }
                }

                Label {
                    Layout.alignment: Qt.AlignHCenter
                    visible: Weeks.records.length === 0
                    text: "Nenhuma semana registrada ainda"
                    font.pixelSize: window.ts(24)
                    color: Theme.colours.onSurfaceVariant || palette.text
                }
            }

            }

            Item {
                Layout.preferredHeight: 8
            }
        }
    }



    // Page switch (top-right)
    Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 12
        anchors.rightMargin: 12
        z: 10
        spacing: 8

        PageButton {
            symbol: "schedule"
            text: "Clock"
            selected: window.page === 0
            onClicked: window.setPage(0)
        }

        PageButton {
            symbol: "bar_chart"
            text: "Statistics"
            selected: window.page === 1
            onClicked: window.setPage(1)
        }
    }

    // Settings button, mirrors caelestia's IconButton (Tonal): padding.small
    // around a 24px icon, rounding.large at rest, fully round while pressed or
    // while its popup is open.
    Button {
        id: settingsButton

        readonly property bool round: pressed || settingsPopup.opened

        x: 12
        y: 12
        z: 10
        padding: 8
        implicitWidth: 24 + padding * 2
        implicitHeight: implicitWidth
        onClicked: settingsPopup.open()

        scale: hovered ? 1.15 : 1

        Behavior on scale {
            NumberAnimation {
                duration: 350
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.42, 1.67, 0.21, 0.9, 1, 1]
            }
        }

        contentItem: Label {
            anchors.verticalCenterOffset: 1 // material symbols sit slightly high
            text: "settings"
            font.family: "Material Symbols Rounded"
            font.pixelSize: 24
            renderType: Text.NativeRendering // as caelestia's StyledText; distance-field rendering garbles the FILL axis
            font.variableAxes: ({ "FILL": settingsButton.round ? 1 : 0 })
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: Theme.colours.onSecondaryContainer || "white"
        }

        background: Rectangle {
            radius: settingsButton.round ? height / 2 : 16
            color: Theme.colours.secondaryContainer || "#3f4a3c"

            Behavior on radius {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.34, 0.8, 0.34, 1, 1, 1]
                }
            }

            // State layer
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: Theme.colours.onSecondaryContainer || "white"
                opacity: settingsButton.pressed ? 0.1 : settingsButton.hovered ? 0.08 : 0

                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }
            }
        }
    }

    Popup {
        id: settingsPopup

        parent: Overlay.overlay
        x: 50
        y: 50
        width: window.width - 100
        height: window.height - 100
        modal: true
        padding: 24
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        onOpened: {
            window.manualHours = {};
            window.manualWeek = Weeks.nextWeek;
            manualMessage.text = "";
        }

        Overlay.modal: Rectangle {
            color: Qt.alpha(Theme.colours.scrim || "black", 0.5)
        }

        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
            NumberAnimation { property: "scale"; from: 0.9; to: 1; duration: 200; easing.type: Easing.OutCubic }
        }

        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 150 }
        }

        background: Rectangle {
            color: Theme.colours.surfaceContainerHigh || "#272b24"
            radius: 28
        }

        contentItem: ColumnLayout {
            spacing: 12

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: availableWidth
                clip: true

                ColumnLayout {
                    width: parent.width
                    spacing: 2

            Label {
                Layout.bottomMargin: 8
                text: "Configurações"
                font.pixelSize: 22
                font.bold: true
                color: Theme.colours.onSurface || "white"
            }

            SectionHeader {
                text: "Metas de horas"
            }

            StepperRow {
                first: true
                label: "Total esperado"
                value: window.totalGoal
                from: 0
                to: 999
                onMoved: v => window.setTotalGoal(v)
            }

            Repeater {
                model: subjectsModel

                delegate: StepperRow {
                    id: goalRow

                    required property string name
                    required property int time
                    required property int index

                    label: name
                    last: index === subjectsModel.count - 1
                    value: window.goalOf(name, time)
                    from: 0
                    to: 99
                    onMoved: v => window.setGoal(name, v)
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 8
                Layout.topMargin: 6
                spacing: 12

                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    font.pixelSize: 12
                    color: Theme.colours.onSurfaceVariant || palette.text
                    text: window.totalGoalOverride >= 0
                        ? "Total fixo em " + window.totalGoalOverride + "h (soma das matérias: " + window.sumGoals + "h)."
                        : "O total acompanha a soma das matérias (" + window.sumGoals + "h)."
                }

                StepButton {
                    visible: window.totalGoalOverride >= 0
                    text: "Usar soma"
                    implicitWidth: 100
                    implicitHeight: 32
                    onClicked: window.setTotalGoal(-1)
                }
            }

            SectionHeader {
                text: "Histórico"
            }

            ExpandableRow {
                id: addWeek

                title: "Adicionar semana anterior"

                StepperRow {
                    label: "Semana"
                    value: window.manualWeek
                    from: 1
                    to: 9999
                    onMoved: v => window.manualWeek = v
                }

                Repeater {
                    model: subjectsModel

                    delegate: StepperRow {
                        id: manualRow

                        required property string name

                        label: name
                        value: window.manualHours[name] ?? 0
                        onMoved: v => window.setManualHours(name, v)
                    }
                }

                ConnectedRect {
                    Layout.fillWidth: true
                    implicitHeight: totalLabel.implicitHeight + 24

                    Label {
                        id: totalLabel

                        anchors.fill: parent
                        anchors.margins: 12
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        verticalAlignment: Text.AlignVCenter
                        text: "Total: " + window.manualTotal + "h de " + window.totalGoal + "h ("
                            + (window.totalGoal > 0 ? (window.manualTotal / window.totalGoal * 100).toFixed(1) : "0.0") + "%)"
                        font.pixelSize: 15
                        color: Theme.colours.onSurfaceVariant || palette.text
                    }
                }

                ConnectedRect {
                    Layout.fillWidth: true
                    implicitHeight: actionRow.implicitHeight + 24
                    last: true

                    RowLayout {
                        id: actionRow

                        anchors.fill: parent
                        anchors.margins: 12
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 12

                        Label {
                            id: manualMessage

                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                            font.pixelSize: 14
                            color: text.startsWith("Semana") ? (Theme.colours.primary || "#add28e") : (Theme.colours.error || "#ffb4ab")
                        }

                        StepButton {
                            text: "Adicionar"
                            implicitWidth: 110
                            onClicked: {
                                const subjects = {};
                                for (let i = 0; i < subjectsModel.count; i++) {
                                    const name = subjectsModel.get(i).name;
                                    subjects[name] = window.manualHours[name] ?? 0;
                                }
                                const err = Weeks.addManual(window.manualWeek, subjects, window.totalGoal);
                                manualMessage.text = err === "" ? "Semana " + window.manualWeek + " adicionada." : err;
                                if (err === "") {
                                    window.manualHours = {};
                                    window.manualWeek = Weeks.nextWeek;
                                }
                            }
                        }
                    }
                }
            }

                    Item {
                        Layout.preferredHeight: 12
                    }
                }
            }

            StepButton {
                Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                text: "Fechar"
                implicitWidth: 100
                onClicked: settingsPopup.close()
            }
        }
    }

}
