import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.config
import Quickshell.Io

PanelWindow {
  id: root

  required property var screen

  anchors.bottom: true
  anchors.left: true
  anchors.right: true
  WlrLayershell.namespace: "quickshelldock"
  WlrLayershell.layer: WlrLayer.Top
  exclusiveZone: -1
  color: "transparent"
  focusable: false

  mask: Region {
    Region { item: triggerStrip }
    Region { item: dockBar }
  }

  implicitHeight: 80

  readonly property int dockHeight: 68
  readonly property real gap: 6
  readonly property real elevationMargin: -3

  readonly property var orderedApps: {
    let apps = []
    for (const app of DockApps.apps) {
      let entry = { icon: app.icon, name: app.name, cmd: app.cmd, order: app.order }
      if (app.match) entry.match = app.match
      if (app.appId) entry.appId = app.appId
      apps.push(entry)
    }
    apps.sort((a, b) => a.order - b.order)
    return apps
  }
  property bool dockVisible: true
  property bool mouseOverDockArea: triggerHover.hovered || dockHover.hovered
  property bool workspaceEmpty: true
  property string clientsJson: ""

  Process {
    id: clientsProcess
    command: ["hyprctl", "clients", "-j"]
    stdout: StdioCollector {
      onStreamFinished: { root.clientsJson = this.text }
    }
  }

  function checkWorkspaceEmpty() {
    const wsId = Hyprland.focusedWorkspace?.id
    if (wsId == null) return true
    try {
      const clients = JSON.parse(clientsJson)
      for (const c of clients) {
        if (c.workspace?.id !== wsId) continue
        if (DockApps.showOnFloating && c.floating) continue
        return false
      }
    } catch (e) {}
    return true
  }

  function updateWorkspaceEmpty() {
    const wsId = Hyprland.focusedWorkspace?.id
    if (wsId == null) return

    var hasToplevels = false
    for (const tl of Hyprland.toplevels.values) {
      if (tl.workspace?.id === wsId) {
        hasToplevels = true
        break
      }
    }

    if (!hasToplevels) {
      if (workspaceEmpty !== true) workspaceEmpty = true
      return
    }

    if (!DockApps.showOnFloating) {
      if (workspaceEmpty !== false) workspaceEmpty = false
      return
    }

    if (!clientsProcess.running) {
      clientsJson = ""
      clientsProcess.running = true
    }
  }

  onClientsJsonChanged: {
    if (clientsJson.length === 0) return
    const empty = checkWorkspaceEmpty()
    if (empty !== workspaceEmpty) workspaceEmpty = empty
  }

  function getToplevelsForApp(app) {
    let results = []
    for (const tl of Hyprland.toplevels.values) {
      let matched = false
      if (app.match) {
        const title = tl.title.toLowerCase()
        if (title.includes(app.match.toLowerCase())) matched = true
      } else if (app.appId) {
        const appId = (tl.wayland?.appId ?? "").toLowerCase()
        if (appId.includes(app.appId.toLowerCase())) matched = true
      } else {
        const exe = app.cmd.split(/\s+/)[0].split("/").pop().replace(/\.[^/.]+$/, "").toLowerCase()
        const appId = (tl.wayland?.appId ?? "").toLowerCase()
        const cls = (tl.lastIpcObject?.class ?? "").toLowerCase()
        if (appId.includes(exe) || cls.includes(exe) || (cls && exe.includes(cls))) matched = true
      }
      if (matched) {
        results.push({ toplevel: tl, pid: tl.lastIpcObject?.pid ?? -1 })
      }
    }
    return results
  }

  function showDockBar() {
    hideTimer.stop()
    dockVisible = true
  }

  function scheduleHide() {
    if (!workspaceEmpty) hideTimer.restart()
  }

  onWorkspaceEmptyChanged: {
    if (workspaceEmpty) showDockBar()
    else scheduleHide()
  }

  Component.onCompleted: updateWorkspaceEmpty()

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (["workspace", "workspacev2", "activewindow", "activewindowv2",
           "createworkspace", "createworkspacev2",
           "destroyworkspace", "destroyworkspacev2"].includes(event.name)) {
        updateWorkspaceEmpty()
      }
    }
  }

  Rectangle {
    id: triggerStrip
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: dockBar.horizontalCenter
    width: dockBar.width + 40
    height: 4
    color: "transparent"

    HoverHandler {
      id: triggerHover
      onHoveredChanged: hovered ? root.showDockBar() : root.scheduleHide()
    }
  }

  Timer {
    id: hideTimer
    interval: 100
    repeat: false
    onTriggered: {
      if (root.workspaceEmpty || root.mouseOverDockArea) return
      root.dockVisible = false
    }
  }

  Rectangle {
    id: dockBar
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: root.gap - root.dockHeight - 20

    implicitWidth: row.implicitWidth + 24
    implicitHeight: row.implicitHeight + 24

    color: "#1e1e2e"
    radius: 18
    border.color: "#313244"
    border.width: 1

    states: State {
      name: "visible"
      when: root.dockVisible
      PropertyChanges {
        target: dockBar
        anchors.bottomMargin: root.elevationMargin + root.gap
      }
    }

    transitions: Transition {
      NumberAnimation {
        property: "anchors.bottomMargin"
        duration: 200
        easing.type: Easing.InOutQuad
      }
    }

    Rectangle {
      anchors.fill: parent
      anchors.topMargin: 4
      radius: 18
      color: "#000000"
      opacity: 0.3
      z: -1
    }

    HoverHandler {
      id: dockHover
      onHoveredChanged: hovered ? hideTimer.stop() : root.scheduleHide()
    }

    RowLayout {
      id: row
      anchors.centerIn: parent
      spacing: 12

      Repeater {
        id: appRepeater
        model: root.orderedApps

        delegate: Item {
          implicitWidth: 54
          implicitHeight: 54

          property bool busy: false

          readonly property var toplevels: root.getToplevelsForApp(modelData)
          readonly property bool isRunning: toplevels.length > 0
          readonly property int pid: isRunning ? toplevels[0].pid : 0

          HoverHandler {
            id: itemHover
          }

          Rectangle {
            anchors.fill: parent
            anchors.margins: 2
            radius: 12
            color: "#cdd6f4"
            opacity: itemHover.hovered ? 0.15 : 0
            Behavior on opacity { NumberAnimation { duration: 150 } }
          }

          TapHandler {
            acceptedButtons: Qt.LeftButton
            onSingleTapped: {
              var cmdParts = modelData.cmd.split(/\s+/)
              if (isRunning) {
                var addr = toplevels[0].toplevel.lastIpcObject?.address
                if (!addr || addr === "0") addr = "0x" + toplevels[0].toplevel.address
                if (addr && addr !== "0x0") {
                  Hyprland.dispatch("focuswindow address:" + addr)
                } else {
                  var cls = toplevels[0].toplevel.lastIpcObject?.class
                  if (cls) Hyprland.dispatch("focuswindow class:" + cls)
                }
                if (!root.workspaceEmpty) root.dockVisible = false
              } else if (!busy) {
                busy = true
                bounceAnimation.start()
                Quickshell.execDetached(cmdParts)
              }
            }
          }

          onIsRunningChanged: {
            if (isRunning) busy = false
            bounceAnimation.stop()
            iconImg.y = 0
          }

          SequentialAnimation {
            id: bounceAnimation
            loops: Animation.Infinite
            NumberAnimation {
              target: iconImg
              property: "y"
              from: 0; to: -24; duration: 0
              easing.type: Easing.OutQuad
            }
            NumberAnimation {
              target: iconImg
              property: "y"
              to: 0; duration: 0
              easing.type: Easing.InQuad
            }
          }

          Image {
            id: iconImg
            anchors.centerIn: parent
            source: Quickshell.iconPath(modelData.icon, true)
            width: 40
            height: 40
            fillMode: Image.PreserveAspectFit
          }

          Rectangle {
            visible: isRunning
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -6
            width: 4
            height: 4
            radius: 2 
            color: "#ffffff"
          }
        }
      }
    }
  }
}
