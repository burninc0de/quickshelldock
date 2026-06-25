# quickshelldock

<video src="https://private-user-images.githubusercontent.com/44199273/612524687-8de3dea3-8535-40db-8d07-a94fbe6f48e1.mp4" controls></video>

Tiling window managers are great when you're in the zone, but sometimes you just want to click a shiny icon. This dock is for those times.

Built with [Quickshell](https://quickshell.outfoxxie.de/) for Hyprland. Launches your pinned apps, tracks running windows, and — most importantly — **gets out of your way** when you don't need it. Instead of a timer or hover toggle, hide/show is driven by what's actually on your workspace: empty workspace → dock is visible. Windows present → dock hides. Event-driven, workspace-aware.

The scope is deliberately tight — no window thumbnails, no subprocess tracking, no icon rearrangement, no drag-and-drop. Just a fast launcher that knows when to be there and when to vanish.

## Caveats

- **Multiple Quickshell instances** &mdash; Quickshell doesn't support running multiple independent shells well. If you already have another Quickshell-based panel or bar, this dock will likely conflict. Test in an isolated Hyprland session first.

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
| `cmd`   | yes      | Shell command to launch (split on whitespace — arguments with spaces aren't supported) |
| `order` | yes      | Sort position in the dock |
| `match` | no       | Match running windows by title substring |
| `appId` | no       | Match running windows by Wayland appId |

### Window matching

If no `match` or `appId` is set, the dock extracts the binary name from `cmd` and compares it against the app's `appId` and `class`.

### showOnFloating

When `true`, workspaces that contain only floating windows are treated as empty (dock stays visible). Default: `true`.

## Behavior

- **Empty workspace** &mdash; dock visible. Provides a visual shelf and one-click launchers.
- **Workspace with windows** &mdash; dock hides. No screen real estate wasted. Hover the bottom edge to reveal.
- **Click** &mdash; launches the app; if already running, focuses its window.
- **Running indicator** &mdash; small dot below the icon.
- **Keyboard vs mouse** &mdash; not a dichotomy. Launching a terminal or editor? Use Super+Enter. Launching YouTube or checking email? Click the icon. The dock is there for the moments your hands aren't on the keyboard.

### Workspace detection

The dock uses a two-tier approach: `Hyprland.toplevels` (fast, via `rawEvent`) covers the common cases — empty workspace keeps the dock visible, occupied hides it. When `showOnFloating` is enabled and toplevels exist, it falls back to `hyprctl clients -j` to check whether only floating windows are present, since the Quickshell API doesn't expose a `floating` flag on toplevels.

## Project structure

```
├── shell.qml          entrypoint — one DockPanel per screen
├── DockPanel.qml      dock UI, auto-hide, window matching
└── config/
    ├── DockApps.qml            config singleton
    ├── UserConfig.qml          your personal config (gitignored)
    └── UserConfig.example.qml  example to copy

```
