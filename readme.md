# quickshelldock

[![Demo video](https://img.shields.io/badge/demo-video-blue)](https://github.com/burninc0de/quickshelldock/issues/1)

Minimal Hyprland dock/launchpad built with [Quickshell](https://quickshell.outfoxxie.de/). Launches apps, tracks running windows, and auto-hides when windows are present.

This is **not** a full taskbar — there are no window thumbnails, no subprocess tracking, no icon rearrangement, no drag-and-drop. The scope is deliberately tight: a fast launcher for your pinned apps that gets out of the way when you don't need it.

## Requirements

- [Quickshell](https://quickshell.outfoxxie.de/) (runtime)
- Hyprland (for window tracking)

## Install

Clone the repo anywhere and run with Quickshell:

```
quickshell -p /path/to/quickshelldock
```

Add to your Hyprland config to auto-start:

```
exec-once = quickshell -p /path/to/quickshelldock
```

## Configuration

Create `~/.config/quickshelldock/config.json` to customize your apps:

```json
{
  "showOnFloating": false,
  "apps": [
    { "name": "Firefox", "icon": "firefox", "cmd": "firefox", "order": 0 },
    { "name": "Kitty",   "icon": "kitty",   "cmd": "kitty",   "order": 1 },
    { "name": "Files",   "icon": "system-file-manager", "cmd": "dolphin", "order": 2 },
    { "name": "Code",    "icon": "code",    "cmd": "code",    "order": 3 }
  ]
}
```

See `config/config.example.json` for a full example.

### App entry fields

| Field   | Required | Description |
|---------|----------|-------------|
| `name`  | yes      | Display name |
| `icon`  | yes      | Icon name (theme) or absolute path to an image |
| `cmd`   | yes      | Shell command to launch (split on whitespace) |
| `order` | yes      | Sort position in the dock |
| `match` | no       | Match running windows by title substring |
| `appId` | no       | Match running windows by Wayland appId |

### Window matching

If no `match` or `appId` is set, the dock extracts the binary name from `cmd` and compares it against the app's `appId` and `class`.

### showOnFloating

When `true`, workspaces that contain only floating windows are treated as empty (dock stays visible). Default: `true`.

## Behavior

- **Empty workspace** &mdash; dock always visible
- **Workspace with windows** &mdash; dock auto-hides; shows on hover at the bottom edge
- **Click** &mdash; launches the app; if already running, focuses its window
- **Running indicator** &mdash; a small dot below the icon

## Project structure

```
├── shell.qml          entrypoint — one DockPanel per screen
├── DockPanel.qml      dock UI, auto-hide, window matching
└── config/
    ├── DockApps.qml   config singleton (loads ~/.config/quickshelldock/config.json)
    └── config.example.json
```
