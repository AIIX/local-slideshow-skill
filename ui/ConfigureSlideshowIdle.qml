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
import QtQuick.Controls 2.2
import org.kde.kirigami 2.8 as Kirigami
import Mycroft 1.0 as Mycroft

Mycroft.Delegate {
    id: configurePage
    background: Rectangle {
        color: "black"
    }
    leftPadding: 0
    topPadding: 0
    rightPadding: 0
    bottomPadding: 0
    fillWidth: true
    property bool showTime: sessionData.showTime
            
    Kirigami.Heading  {
        id: contactsPageHeading
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: Kirigami.Units.gridUnit * 3
        horizontalAlignment: Text.AlignHCenter
        font.bold: true
        text: "Configure"
        color: Kirigami.Theme.highlightColor
    }
        
    Kirigami.Separator {
        id: headerSept
        anchors.top: contactsPageHeading.bottom
        anchors.topMargin: Kirigami.Units.largeSpacing
        width: parent.width
        height: 1
    }
         
    ColumnLayout {
        id: configPageButtonsView
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Kirigami.Units.gridUnit
        anchors.rightMargin: Kirigami.Units.gridUnit
        
        TextField {
            id: defPath
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 4
            text: sessionData.defaultPath
            
            onEditingFinished: {
                triggerGuiEvent("slideshow.idle.setDefaultPath", {"path": defPath.text})
            }
        }
        
        Button {
            id: setPath
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 4
            
            background: Rectangle {
                color: "#029a4e"
                radius: Kirigami.Units.gridUnit
                border.width: enableTime.activeFocus ? Kirigami.Units.largeSpacing : 0
                border.color: enableTime.activeFocus ? Kirigami.Theme.linkColor : "transparent"
            }
            
            contentItem: Item {
                Kirigami.Heading {
                    level: 2
                    anchors.centerIn: parent
                    text: "Set Folder"
                }
            }
            
            onClicked: {
                triggerGuiEvent("slideshow.idle.setDefaultPath", {"path": defPath.text})
            }
        }
    
        Button {
            id: enableTime
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 4
            
            background: Rectangle {
                color: "#629ade"
                radius: Kirigami.Units.gridUnit
                border.width: enableTime.activeFocus ? Kirigami.Units.largeSpacing : 0
                border.color: enableTime.activeFocus ? Kirigami.Theme.linkColor : "transparent"
            }
            
            contentItem: Item {
                Kirigami.Heading {
                    level: 2
                    anchors.centerIn: parent
                    text: showTime ? "Disable Time" : "Enable Time"
                }
            }
            
            onClicked: {
                if(!showTime){
                    triggerGuiEvent("pixabay.idle.enableTime", {})
                } else {
                    triggerGuiEvent("pixabay.idle.disableTime", {})
                }
            }
        }
        
        Button {
            id: backButton
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 4
            
            background: Rectangle {
                color: "#ff9d00"
                radius: Kirigami.Units.gridUnit
                border.width: backButton.activeFocus ? Kirigami.Units.largeSpacing : 0
                border.color: backButton.activeFocus ? Kirigami.Theme.linkColor : "transparent"
            }
            
            contentItem: Item {
                Image {
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.medium
                    height: width
                    source: "images/back.png"
                }
            }
            
            onClicked: {
                triggerGuiEvent("slideshow.idle.removeConfigPage", {})
            }
        }
    }
}
 
