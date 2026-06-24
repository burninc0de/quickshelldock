# quickshelldock

<video src="https://private-user-images.githubusercontent.com/44199273/612524687-8de3dea3-8535-40db-8d07-a94fbe6f48e1.mp4" controls></video>

Minimal Hyprland dock/launchpad built with [Quickshell](https://quickshell.outfoxxie.de/). Launches apps, tracks running windows, and auto-hides when windows are present.

This is a **proof of concept** — not a full taskbar. There are no window thumbnails, no subprocess tracking, no icon rearrangement, no drag-and-drop. The scope is deliberately tight: a fast launcher for your pinned apps that gets out of the way when you don't need it.

> **Note:** If you already run another Quickshell-based panel/bar, this dock may conflict (Quickshell doesn't support multiple independent instances well). Test in an isolated session first.

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

Copy `config/UserConfig.example.qml` to `config/UserConfig.qml` and edit it to customize your apps. Both files are in the project directory so Quickshell's native hot reload picks up changes instantly — no restart needed.

`UserConfig.qml` is gitignored, so your personal config stays out of the repo.

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
    ├── DockApps.qml            config singleton
    ├── UserConfig.qml          your personal config (gitignored)
    └── UserConfig.example.qml  example to copy

```
