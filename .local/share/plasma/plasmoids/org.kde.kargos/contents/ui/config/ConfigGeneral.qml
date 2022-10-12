import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

ConfigPage {
    id: page
    
    property alias cfg_command: command.text
    property alias cfg_interval: interval.value
    property alias cfg_rotation: rotation.value
    
    ConfigSection {
        label: i18n("Command line or executable path. The output of this command will be parsed following the Argos/Bitbar convention")
        
        TextField {
            id: command
            Layout.fillWidth: true
        }
    }
    
    ConfigSection {
        label: i18n("Interval in seconds (ignored if the previous property is an executable with the interval on its name. ex: myplugin.1s.sh)")
        
        SpinBox {
            id: interval
            Layout.fillWidth: true            
            maximumValue: 99999
        }
    }
    
    ConfigSection {
        label: i18n("Rotation delay in seconds (rotation interval of the lines before the ---)")
        
        SpinBox {
            id: rotation
            Layout.fillWidth: true        
            maximumValue: 60
        }
    }
}
