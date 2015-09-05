import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Window 2.2
import QtPositioning 5.5
import QtLocation 5.5

ApplicationWindow {

    title: qsTr("POC")

    width: 640
    height: 480
    visible: true


    Plugin {
        id: myPlugin
        name: "osm"
        PluginParameter { name: "osm.mapping.host"; value: "http://c.tile.thunderforest.com/outdoors/" }
    }


    GeocodeModel {
        id: geocodeModel
        plugin: myPlugin
        onQueryChanged: console.log("onQueryChanged")
    }
    GeocodeModel {
        id: geocodeModel2
        plugin: myPlugin
        onQueryChanged: console.log("onQueryChanged")
    }

    SplitView {
        id: splitview
        anchors.fill: parent
        orientation: Qt.Vertical

        TextField {
            id : txtinput
            placeholderText: qsTr("Enter name")
            Keys.onReturnPressed:  {
                geocodeModel.query = txtinput.text
                geocodeModel.update()
            }
        }

        Map {
            property bool followme : false

            id : map
            plugin: myPlugin
            height: splitview.height*0.5
            focus: true
            zoomLevel: 9
            gesture.activeGestures: MapGestureArea.PanGesture | MapGestureArea.FlickGesture | MapGestureArea.ZoomGesture
            gesture.flickDeceleration: 3000
            gesture.enabled: true

            onCenterChanged:{
                if (map.followme)
                    if (map.center !== positionSource.position.coordinate) map.followme = false
            }

            // fix bug QTBUG-46388
            MouseArea {
                anchors.fill: parent
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

            MapItemView {
                model: geocodeModel
                delegate: itemLocator
                autoFitViewport: true
            }
            MapItemView {
                model: geocodeModel2
                delegate: itemLocator
                autoFitViewport: true
            }

            Component {
                id: itemLocator
                MapQuickItem {
                    coordinate: locationData.coordinate
                    anchorPoint.x: image.width * 0.5
                    anchorPoint.y: image.height
                    sourceItem: Image {
                        id: image
                        source: "marker.png"
                        Text {
                            id: name
                            text: qsTr("geocodeModel.query")
                        }
                    }
                }
            }

//            Button {
//                id: locateButton
//                width: 200
//                height: 200
//                onClicked: {
//                    map.followme = true
//                    console.log("onClicked")
//                }
//            }

        }//Map


        TableView {
            sortIndicatorVisible: true

            itemDelegate: TextInput {
                text: styleData.value
                onAccepted: {
                    libraryModel.setProperty(styleData.row, styleData.column , text)
                    console.log("done")
                    geocodeModel2.query = text
                    geocodeModel2.update()
                }
            }

            TableViewColumn { role: "title"; title: "Title"; width: 100 }
            TableViewColumn { role: "author"; title: "Author"; width: 200 }

            model: ListModel {
                id: libraryModel
                ListElement {
                    title: "A Masterpiece"
                    author: "Gabriel"
                }
                ListElement {
                    title: "Brilliance"
                    author: "Jens"
                }
                ListElement {
                    title: "Outstanding"
                    author: "Frederik"
                }
            }

            onSortIndicatorOrderChanged: {
                console.log("sorrted")
            }

            onClicked: {
                console.log("clicked ", currentRow)
            }

            onSelectionChanged: {
                console.log("currentRow")
            }
        }//TableView

    }//SplitView

}//ApplicationWindow
