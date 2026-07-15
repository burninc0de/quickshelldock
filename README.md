# quickshelldock

Hyprland dock panel built with [Quickshell](https://quickshell.outfoxxed.me/). No build step — loaded directly by the Quickshell runtime.

## Usage

```sh
quickshell /path/to/quickshelldock
```

## Configuration

App list and options are in [`config/DockApps.qml`](config/DockApps.qml). To override without editing the defaults, create `config/UserConfig.qml` with the same structure:

```js
import QtQuick

QtObject {
  property bool showOnFloating: true

  property var apps: [
    { name: "Firefox", icon: "firefox", cmd: "firefox", order: 0 },
    { name: "Dolphin", icon: "system-file-manager", cmd: "dolphin", order: 1 },
  ]
}
```

### Per-app options

| Field         | Required | Description |
|---------------|----------|-------------|
| `name`        | yes      | Display name |
| `icon`        | yes      | Icon name (looked up via `Quickshell.iconPath`) |
| `cmd`         | yes      | Command to launch, split on whitespace |
| `order`       | yes      | Sort position in the dock |
| `match`       | no       | If set, matches against Hyprland toplevel `title` |
| `appId`       | no       | If set, matches against Wayland `appId` |
| `minimizable` | no       | Default `true`. When `false`, clicking a running app always focuses it instead of minimize/restore |

## Minimize / Restore

Since Hyprland has no native minimize, clicking a running app's dock icon hides it on the `special:dock_minimize` scratchpad workspace. Clicking again restores it to the current workspace.

This works for any app that has toplevels on the current workspace. Apps on other (non-special) workspaces are focused normally. Set `minimizable: false` per app to disable this behavior.
