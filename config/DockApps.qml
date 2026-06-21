pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
  id: config

  property bool showOnFloating: true
  property var apps: defaultApps()

  property Process _configProc: Process {
    stdout: StdioCollector {
      onStreamFinished: {
        if (text.length === 0) return
        try {
          var json = JSON.parse(text)
          if (json.showOnFloating !== undefined)
            config.showOnFloating = json.showOnFloating
          if (json.apps && json.apps.length > 0)
            config.apps = json.apps
        } catch (e) {}
      }
    }
  }

  Component.onCompleted: {
    var home = Quickshell.env("HOME")
    if (home) {
      _configProc.command = ["cat", home + "/.config/quickshelldock/config.json"]
      _configProc.running = true
    }
  }

  function defaultApps() {
    return [
      { name: "Firefox", icon: "firefox", cmd: "firefox", order: 0 },
      { name: "Kitty", icon: "kitty", cmd: "kitty", order: 1 },
      { name: "Dolphin", icon: "system-file-manager", cmd: "dolphin", order: 2 },
      { name: "Code", icon: "code", cmd: "code", order: 3 },
    ]
  }
}
