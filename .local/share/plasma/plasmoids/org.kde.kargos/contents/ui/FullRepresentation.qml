/*
 * 
 * kargos
 * 
 * Copyright (C) 2017 - 2020 Daniel Glez-Peña
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public
 * License along with this program.  If not, see
 * <http://www.gnu.org/licenses/gpl-3.0.html>.
 */
import QtQuick 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: fullRoot
    
    Layout.preferredWidth: plasmoid.configuration.width
    Layout.preferredHeight: plasmoid.configuration.height
    
    ListModel {
        id: kargosModel
    }
    
    Component.onCompleted: { 
        //first update
        root.update();     
    }
    

    // Info for submenus.
    // This structure has information of all submenus and their visibility status.
    // Since on each update the listview is regenerated, we use this structure to preserve the open/closed
    // status of submenus
    property var categories: ({});
    
    ListView {        
        id: listView
        anchors.fill: parent
        model: kargosModel
        header: createHeader();
        
        function createHeader() {
            if (!root.isConstrained()) {

                return Qt.createComponent("FirstLinesRotator.qml");
            } else {
                return null;
            }

        }
        
        delegate: Row {
            
            id: row
            height: (typeof category === 'undefined' || (fullRoot.categories[category].visible)) ? row.visibleHeight: 0
            visible: (typeof category === 'undefined') ? true : (fullRoot.categories[category].visible)
            spacing: 2
            
            PlasmaCore.IconItem {
                id: icon
                source: (typeof iconName !== 'undefined')? iconName: ''
                anchors.verticalCenter: row.verticalCenter
                
                Component.onCompleted: {
                    if (typeof iconName === 'undefined') {
                        icon.width = 0
                    }
                }
            }
            
            Image {
                id: image
                anchors.verticalCenter: row.verticalCenter
                fillMode: Image.PreserveAspectFit

                MouseArea {
                    anchors.fill: parent
                    cursorShape: root.isClickable(model) ? Qt.PointingHandCursor: Qt.ArrowCursor
                    onClicked: {
                        root.doItemClick(model);
                    }
                }
            }
            
            Component.onCompleted: {
                if (typeof category !== 'undefined') {
                    fullRoot.categories[category].rows.push(row);
                }

                if (typeof model.image !== 'undefined') {
                    createImageFile(model.image, function(filename) {
                        image.source = filename;
                    });
                }

                if (typeof model.imageURL !== 'undefined') {
                    image.source = model.imageURL;
                }

                if (typeof model.imageWidth !== 'undefined') {
                    image.sourceSize.width = model.imageWidth
                }

                if (typeof model.imageHeight !== 'undefined') {
                    image.sourceSize.height = model.imageHeight
                }

                if (typeof model.image !== 'undefined' && typeof model.imageURL !== 'undefined') {
                    image.width = 0;
                }
            }
            
            Item {
                id: labelAndButtons
                width: fullRoot.width - icon.width - arrow_icon.width - image.width//some right margin
                height: itemLabel.implicitHeight + 10
                anchors.verticalCenter: row.verticalCenter

                PlasmaComponents.Label {
                    id: itemLabel
                    text: fullRoot.createTitleText(model);
                    width: labelAndButtons.width - (mousearea.goButton.width) - (mousearea.runButton.width)
                    anchors.verticalCenter: labelAndButtons.verticalCenter
                    wrapMode: Text.WordWrap
                   // elide: Text.ElideRight
                    Component.onCompleted: {
                        if (typeof model.font !== 'undefined') {
                            font.family = model.font;
                        }
                        if (typeof model.size !== 'undefined') {
                            font.pointSize = model.size;
                        }
                        if (typeof model.color !== 'undefined') {
                            color = model.color;
                        }
                    }
                }
                
                ItemTextMouseArea {
                    id: mousearea
                    item: model
                }
            }

            // expand-collapse icon
            PlasmaCore.IconItem {
                id: arrow_icon
                source: (fullRoot.categories[model.title] !== undefined && fullRoot.categories[model.title].visible) ? 'arrow-down': 'arrow-up'
                visible: (typeof model.category === 'undefined' && fullRoot.categories[model.title] !== undefined && fullRoot.categories[model.title].items.length > 0) ? true:false

                width: (visible) ? units.iconSizes.smallMedium : 0
                height: units.iconSizes.smallMedium

                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    onClicked: {
                       // In order to notify binding of fullRoot.categories property, we clone it, and then reassign it.
                       var newState = fullRoot.copyObject(fullRoot.categories);
                       newState[model.title].visible = !newState[model.title].visible
                       
                       fullRoot.categories = newState;
                    }

                    hoverEnabled: true

                    onEntered: {
                        // avoid flikering on each update
                        timer.running = false; 
                    }

                    onExited: {
                        // avoid flikering on each update
                        timer.running = true; 
                    }
                }
            }  
        }
    }
    
    Connections {
        target: commandResultsDS
        onExited: {
                update(stdout);
        }
    }
    
    function copyObject(object) {
        var copy = {};
            
        Object.keys(object).forEach(function(prop) {
            copy[prop] = object[prop];
            
        });
        
        return copy;
    }
    
    function createTitleText(item) {
        var titleText = '<div>'+item.title.replace(/\\n/g, '<br>').replace(/  /g, '&nbsp;&nbsp;') + '</div>';
        
        return titleText;
        
    }
    function update(stdout) {
        kargosModel.clear();
        
        var items = parseItems(stdout);
        
        items.forEach(function(item) {
            if (item.dropdown === undefined || item.dropdown === 'true') {
                if (item.category !== undefined) {
                    if (fullRoot.categories[item.category] === undefined) {
                        fullRoot.categories[item.category] = {visible : false, items: [], rows: []};
                    }
                    
                    if (item.category !== undefined) {
                        fullRoot.categories[item.category].items.push(item);
                    }
                }
            }
        });
        
        items.forEach(function(item) {
            if (item.dropdown === undefined || item.dropdown === true) {
                kargosModel.append(item);
            }
        });
    }
}

