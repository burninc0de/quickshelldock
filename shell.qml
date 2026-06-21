import Quickshell
import QtQuick

ShellRoot {
  Variants {
    model: Quickshell.screens

    DockPanel {
      required property var modelData
      screen: modelData
    }
  }
}
