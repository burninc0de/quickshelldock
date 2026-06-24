import QtQuick

QtObject {
  property bool showOnFloating: true

  property var apps: [
    {
      name: "Firefox",
      icon: "firefox",
      cmd: "firefox",
      order: 0,
    },
    {
      name: "Kitty",
      icon: "kitty",
      cmd: "kitty",
      order: 1,
    },
    {
      name: "Dolphin",
      icon: "system-file-manager",
      cmd: "dolphin",
      order: 2,
    },
    {
      name: "Code",
      icon: "code",
      cmd: "code",
      order: 3,
    },
  ]
}
