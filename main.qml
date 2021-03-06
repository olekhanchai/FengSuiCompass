import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtSensors 5.0

ApplicationWindow {
    id: applicationWindow
    title: qsTr("Compass test")
    width: 640
    height: 480
    visible: true

    property real demoHeading
    property int realCompass

    Timer {
        //Timer for demo rotation of compass
        interval: 5
        running: true
        repeat: true
        onTriggered: {
            demoHeading += 1
            if (realCompass != 1)
                compassui.setBearing(demoHeading)
        }
    }

    Magnetometer {
        id: mag
        dataRate: 5
        active:true

        onReadingChanged: {
            //console.log("Mag:", mag.reading.x, ",", mag.reading.y, ",", mag.reading.z);
            //console.log("Accel:", accel.reading.x, ",", accel.reading.y, ",", accel.reading.z);

            var accelVec = [accel.reading.x, accel.reading.y, accel.reading.z]
            var magEast = crossProduct([mag.reading.x, mag.reading.y, mag.reading.z], accelVec)
            var magNorth = crossProduct(accelVec, magEast)

            magEast = normVec(magEast)
            magNorth = normVec(magNorth)

            var deviceHeading = [0., 1., -1.] //This is for portrait orientation on android
            deviceHeading = normVec(deviceHeading)

            var dotWithEast = dotProduct(deviceHeading, magEast)
            var dotWithNorth = dotProduct(deviceHeading, magNorth)
            var bearingRad = Math.atan2(dotWithEast, dotWithNorth)
            var bearingDeg = bearingRad * 180. / Math.PI
            console.log("bearingDeg:", bearingDeg);

            compassui.setBearing(bearingDeg)
            realCompass = 1
        }
    }

    Accelerometer
    {
        id: accel
        dataRate: 5
        active: true
    }

    function crossProduct(a, b) {

        // Check lengths
        if (a.length != 3 || b.length != 3) {
            return;
        }

        return [a[1]*b[2] - a[2]*b[1],
              a[2]*b[0] - a[0]*b[2],
              a[0]*b[1] - a[1]*b[0]];

    }

    function normVec(a) {
        var compSq = 0.
        for(var i=0;i<a.length;i++)
            compSq += Math.pow(a[i], 2)
        var mag = Math.pow(compSq, 0.5)
        if(mag == 0.) return
        var out = []
        for(var i=0;i<a.length;i++)
            out.push(a[i]/mag)
        return out
    }

    function dotProduct(a, b)
    {
        if (a.length != b.length) return;
        var comp = 0.
        for(var i=0;i<a.length;i++)
            comp += a[i] * b[i]
        return comp
    }

    Image {
        id: imagedown
        x: (parent.width - width) * 0.5
        width: 27
        height: 22
        anchors.top: parent.top
        source: "pointerdown.png"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 0
        fillMode: Image.Stretch
    }

    Image {
        id: imageup
        x: (parent.width - width) * 0.5
        width: 27
        height: 22
        anchors.bottom: parent.bottom
        source: "pointerup.png"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 0
        fillMode: Image.Stretch
    }

    Rectangle {
        id: rectangle
        x: (parent.width - width) * 0.5
        y: 0
        z: 10
        width: 1
        height: parent.height
        color: "#ff0000"
    }

    Rectangle {
        id: rectangle1
        x: (parent.width - width) * 0.5
        y: (parent.height - height) * 0.5
        z: 15
        width: parent.width * 0.5
        height: parent.width * 0.5
        color: "#e0e0e0"
        Rectangle {
            id: trilinetop
            x: 0
            y: parent.height / 3
            z: 20
            width: parent.width
            height: 1
            color: "#0000ff"
        }
        Rectangle {
            id: trilinebottom
            x: 0
            y: parent.height * (2 / 3)
            z: 20
            width: parent.width
            height: 1
            color: "#0000ff"
        }
        Rectangle {
            id: trilineleft
            x: parent.width / 3
            y: 0
            z: 20
            width: 1
            height: parent.height
            color: "#0000ff"
        }
        Rectangle {
            id: trilineright
            x: parent.width * (2 / 3)
            y: 0
            z: 20
            width: 1
            height: parent.height
            color: "#0000ff"
        }
    }

    CompassUi
    {
        id: compassui
    }

}
