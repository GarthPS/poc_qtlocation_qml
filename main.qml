import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Window 2.2
import QtPositioning 5.5
import QtLocation 5.5

ApplicationWindow {

    title: qsTr("Hello World")
    width: 640
    height: 480
    visible: true

    Plugin {
        id: myPlugin
        name: "osm"
        PluginParameter { name: "osm.mapping.host"; value: "http://c.tile.thunderforest.com/outdoors/" }
    }

    Map {
        property bool followme : false

        id : map
        plugin: myPlugin
        anchors.fill: parent
        focus: true
        zoomLevel: 9
        gesture.activeGestures: MapGestureArea.PanGesture | MapGestureArea.FlickGesture | MapGestureArea.ZoomGesture
        gesture.flickDeceleration: 3000
        gesture.enabled: true

        onCenterChanged:{
            if (map.followme)
                if (map.center !== positionSource.position.coordinate) map.followme = false
        }

        PositionSource {
            id: positionSource
            updateInterval: 1000
            active: map.followme
            preferredPositioningMethods : PositionSource.SatellitePositioningMethods

            onPositionChanged: {
                map.center = positionSource.position.coordinate
            }
        }
    }

    Button {
        id: locateButton
        width: 200
        height: 200
        onClicked: {
            map.followme = true;
        }
    }
}
