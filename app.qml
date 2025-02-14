import QtQuick
import QtQuick.Controls.Basic
import QtMultimedia

ApplicationWindow {
    id: window

    property int work_time_seconds
    property int rest_time_seconds
    property QtObject settings_service
    property QtObject workflow_service

    property color backgroundColor: "#282828"
    property color white: "#ffffff"
    property color red: "#ff0000"

    property int remainingTime: work_time_seconds

    // State: true = Work Mode, false = Rest Mode
    property bool isWorkMode: true

    visible: true
    width: 600
    height: 400
    title: "Pomodoro Timer"

    color: backgroundColor

    Rectangle {
        width: window.width
        height: 150

        color: "transparent"
        Text {
            anchors.centerIn: parent
            text: "🍅 Pomodoro Timer"
            color: 'white'
            font.pixelSize: 42
        }
    }

    // MAIN CENTRALIZED CONTAINER
    Rectangle {
        anchors.fill: parent
        color: "transparent"

        // Positioning objects vertically
        Column {
            anchors.centerIn: parent

            Rectangle {
                color: "transparent"

                width: window.width
                height: childrenRect.height

                anchors.horizontalCenter: parent.horizontalCenter

                visible: (countdownTimer.running || countdownTimer.isPaused) ? true : false

                Column {
                    anchors.fill: parent

                    Text {
                        id: mode_display
                        text: isWorkMode ? "Work Time" : "Rest Time"
                        font.pixelSize: 20
                        color: white
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    // Timer Display
                    Text {
                        id: timer_display
                        text: formatTime(remainingTime)

                        font.pixelSize: 48

                        color: {
                            if (isWorkMode) {
                                if (remainingTime < Math.floor(work_time_seconds * 0.1)) {
                                    "red"
                                } else {
                                    "white"
                                }
                            } else {
                                if (remainingTime < Math.floor(rest_time_seconds * 0.1)) {
                                    "red"
                                } else {
                                    "white"
                                }
                            }
                        }

                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Item {
                        height: 70
                        width: 1
                    }

                    Rectangle {
                        id: timerControls
                        color: "transparent"

                        height: 15
                        width: window.width

                        Row {
                            spacing: 10
                            anchors.horizontalCenter: parent.horizontalCenter

                            Button {
                                width: 82
                                height: 40

                                text: "Pause"
                                onClicked: onClick()

                                background: Rectangle {
                                    color: {
                                        if (countdownTimer.isPaused) {
                                            "#aaaaaa"
                                        } else {
                                            white
                                        }
                                    }
                                    radius: 5
                                }

                                contentItem: Text {
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    anchors.fill: parent
                                    text: countdownTimer.isPaused ? "Resume" : "Pause"
                                }

                                function onClick() {
                                    if (countdownTimer.isPaused) {
                                        countdownTimer.start();
                                    } else {
                                        countdownTimer.stop();
                                    }
                                }
                            }

                            Button {
                                width: 82
                                height: 40

                                text: "Reset"
                                onClicked: countdownTimer.reset()

                                background: Rectangle {
                                    color: white
                                    radius: 5
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: settingsContainer
                visible: (countdownTimer.running || countdownTimer.isPaused) ? false : true
                color: "transparent"

                height: 200
                width: window.width

                Column {
                    anchors.centerIn: parent
                    height: 200

                    // Work time input
                    Rectangle {
                        width: 300
                        height: 50
                        color: "transparent"

                        Row {
                            anchors.centerIn: parent
                            spacing: 10

                            Text {
                                text: "Work time: "
                                font.pixelSize: 24
                                color: "#ffffff"
                            }
                            TextField {
                                id: work_time_field
                                width: 50
                                height: 32
                                font.pixelSize: 18
                                placeholderText: work_time_seconds / 60
                            }
                            Text {
                                text: "min."
                                font.pixelSize: 24
                                color: "#ffffff"
                            }
                            Button {
                                width: 70
                                height: 36
                                onClicked: {
                                    settings_service.work_time(work_time_field.text); // Update work_time_minutes
                                    // Update work time in seconds and refresh timer
                                    work_time_seconds = work_time_field.text * 60; // Convert to seconds
                                    remainingTime = work_time_seconds; // Set remainingTime to updated value
                                    countdownTimer.restart(); // Restart the timer
                                }
                                contentItem: Text {
                                    text: "SET"
                                    font.pixelSize: 16
                                    color: parent.down ? "#f0f0f0" : "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                background: Rectangle {
                                    color: parent.down ? "#404040" : "#505050"
                                    radius: 5
                                }
                            }
                        }
                    }

                    // Rest time input
                    Rectangle {
                        width: 300
                        height: 50
                        color: "transparent"

                        Row {
                            anchors.centerIn: parent
                            spacing: 10

                            Text {
                                text: "Rest time: "
                                font.pixelSize: 24
                                color: "#ffffff"
                            }
                            TextField {
                                id: rest_time_field
                                width: 50
                                height: 32
                                font.pixelSize: 18
                                placeholderText: rest_time_seconds / 60
                            }
                            Text {
                                text: "min."
                                font.pixelSize: 24
                                color: "#ffffff"
                            }
                            Button {
                                width: 70
                                height: 36
                                onClicked: {
                                    settings_service.rest_time(rest_time_field.text);
                                    // Update rest time in seconds and refresh timer
                                    rest_time_seconds = rest_time_field.text * 60; // Convert to seconds
                                    remainingTime = rest_time_seconds; // Set remainingTime to updated value
                                    countdownTimer.restart(); // Restart the timer
                                }
                                contentItem: Text {
                                    text: "SET"
                                    font.pixelSize: 16
                                    color: parent.down ? "#f0f0f0" : "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                background: Rectangle {
                                    color: parent.down ? "#404040" : "#505050"
                                    radius: 5
                                }
                            }
                        }
                    }

                    Item {
                        height: 100
                        width: 1
                    }

                    // Start session button
                    Button {
                        id: start_session

                        property color colorNormal: "#427642"
                        property color colorHovered: "#539353"
                        property color colorClicked: "#326632"

                        anchors.horizontalCenter: parent.horizontalCenter  // Ensure it's centered horizontally
                        width: 200
                        height: 40
                        // onClicked: countdownTimer.running = true
                        onClicked: countdownTimer.running = true

                        contentItem: Text {
                            text: "START SESSION"
                            font.pixelSize: 20
                            color: parent.down ? "#cbdfcb" : "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            color: if (parent.down) {
                                            parent.colorClicked
                                        } else if (parent.hovered) {
                                            parent.colorHovered
                                        } else {
                                            parent.colorNormal
                                        }
                            radius: 5 
                        }
                    }
                }
            }
        }
    }

    // Timer Object
    Timer {
        id: countdownTimer
        interval: 1000  // 1 second
        running: false
        repeat: true

        property bool isPaused: false

        onTriggered: {
            if (remainingTime > 0) {
                remainingTime--;  
            } else {
                playSound();
                switchMode();
            }
        }

        function restart() {
            running = false; // Stop current timer
            isPaused = false;
            remainingTime = work_time_seconds; // Reset to the new work time value
        }

        function start() {
            running = true;
            isPaused = false;
        }

        function stop() {
            running = false;
            isPaused = true;
        }

        function reset() {
            running = false;
            isPaused = false;
            remainingTime = work_time_seconds;
        }
    }

    function playSound() {
        timerFinishSound.play();
    }

    SoundEffect {
        id: timerFinishSound
        source: "./sounds/timer.wav"  // Replace with your sound file path
        volume: 1.0
    }

    function switchMode() {
        if (isWorkMode) {
            isWorkMode = false;
            remainingTime = rest_time_seconds;
        } else {
            isWorkMode = true;
            remainingTime = work_time_seconds;
        }
        countdownTimer.start(); // Auto-start next phase
    }


    // Function to format seconds as MM:SS
    function formatTime(seconds) {
        let minutes = Math.floor(seconds / 60);
        let secs = seconds % 60;
        return (minutes < 10 ? "0" : "") + minutes + ":" + (secs < 10 ? "0" : "") + secs;
    }
}