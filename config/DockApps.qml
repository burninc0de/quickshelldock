pragma Singleton
import QtQuick

QtObject {
  id: config

  property bool showOnFloating: true

  property var apps: [
    { name: "Firefox", icon: "firefox", cmd: "firefox", order: 0 },
    { name: "Kitty", icon: "kitty", cmd: "kitty", order: 1 },
    { name: "Dolphin", icon: "system-file-manager", cmd: "dolphin", order: 2 },
    { name: "Code", icon: "code", cmd: "code", order: 3 },
  ]

  Component.onCompleted: {
    var comp = Qt.createComponent("UserConfig.qml")
    if (comp.status === Component.Ready) {
      var obj = comp.createObject(null)
      if (obj) {
        if (obj.showOnFloating !== undefined)
          config.showOnFloating = obj.showOnFloating
        if (obj.apps !== undefined && obj.apps.length > 0)
          config.apps = obj.apps
        obj.destroy()
      }
    }
  }
}
