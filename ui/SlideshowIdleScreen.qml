/*
 * Copyright 2020 by Aditya Mehra <aix.m@outlook.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick.Layouts 1.4
import QtQuick 2.9
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.2
import QtQuick.Window 2.2
import org.kde.kirigami 2.8 as Kirigami
import Mycroft 1.0 as Mycroft

Mycroft.Delegate {
    id: idleSlideshowView
    background: Rectangle {
        color: "black"
    }
    leftPadding: 0
    topPadding: 0
    rightPadding: 0
    bottomPadding: 0
    fillWidth: true

    property var slideshowModel: sessionData.slideshow_model
    property bool showTime: sessionData.showTime
    property string time_string: sessionData.time_string
    
    Item {
        id: rootImage
        anchors.fill: parent
        
        Timer {
            id: dTimeTimer
            running: idleSlideshowView.showTime && rootImage.visible ? 1 : 0
            repeat: idleSlideshowView.showTime && idleSlideshowView.visible ? 1 : 0
            interval: 10000
            onTriggered: {
                console.log("dTimeTimer Triggered, should get updated Time")
                triggerGuiEvent("slideshow.idle.updateTime", {})
            }
        }
        
        Timer {
            id: slideShowTimer
            interval: 5000
            running: true
            repeat: true
            onTriggered: {
                var getCount = slideShowListView.count
                if(slideShowListView.currentIndex !== getCount){
                    slideShowListView.currentIndex = slideShowListView.currentIndex+1;
                } else{
                    slideShowListView.currentIndex = 0
                }
            }
        }
        
        ListView {
            id: slideShowListView
            anchors.fill: parent
            layoutDirection: Qt.LeftToRight
            orientation: ListView.Horizontal
            snapMode: ListView.SnapOneItem;
            flickableDirection: Flickable.AutoFlickDirection
            highlightRangeMode: ListView.StrictlyEnforceRange
            highlightFollowsCurrentItem: true
            clip: true
            model: slideshowModel
            delegate: Image {
                id: image
                width: slideShowListView.width
                height: slideShowListView.height
                fillMode: Image.PreserveAspectCrop
                source: Qt.resolvedUrl(model.image)
            }
            
            move: Transition {
                SmoothedAnimation {
                    property: "x"
                    duration: Kirigami.Units.shortDuration
                }
            }
            
            onFlickEnded: {
                slideShowTimer.restart()
            }
            
            Rectangle {
                anchors.top: parent.top
                anchors.topMargin: Kirigami.Units.gridUnit * 3
                anchors.left: parent.left
                anchors.leftMargin: -Kirigami.Units.gridUnit * 1.25
                radius: 30
                width: time.contentWidth + (Kirigami.Units.gridUnit * 2)
                enabled: idleSlideshowView.showTime
                visible: idleSlideshowView.showTime
                height: time.contentHeight
                color: Qt.rgba(0, 0, 0, 0.5)
                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 2
                    verticalOffset: 1
                }
                
                Label {
                    id: time
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: Kirigami.Units.gridUnit * 0.25
                    font.capitalization: Font.AllUppercase
                    font.family: "Noto Sans Display"
                    font.weight: Font.Bold
                    font.pixelSize: 75
                    enabled: idleSlideshowView.showTime
                    visible: idleSlideshowView.showTime
                    color: "white"
                    text: idleSlideshowView.time_string.replace(":", "꞉")
                }
            }
        }
    }
} 
