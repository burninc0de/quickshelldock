# quickshelldock

Hyprland dock panel built with Quickshell (QML). No build step — loaded directly by the Quickshell runtime.

## Structure

- `shell.qml` — entrypoint, instantiates `DockPanel` per screen via `Variants`
- `DockPanel.qml` — the dock UI: auto-hide, bounce-on-launch, Hyprland toplevel matching, window focus
- `config/DockApps.qml` — singleton defining the ordered app list (name, icon, cmd, optional `match`)

## Key conventions

- App matching: if `match` is set, matches against Hyprland toplevel `title`; if `appId` is set, matches against the Wayland `appId`; otherwise extracts the binary name from `cmd` and matches against `appId` or `class`
- `Quickshell.execDetached(cmdParts)` launches apps — always split `cmd` on whitespace
- The dock uses `WlrLayershell.layer: Top` and `exclusiveZone: -1` (no exclusive zone)
- Layer namespace is `quickshelldock`

## Dock visibility

- Empty workspace → dock always visible
- Workspace with windows → dock auto-hides (shows on hover at bottom edge)
- `showOnFloating` config flag (default: `false`) — when `true`, floating-only workspaces are treated as empty
- Detection: fast path iterates `Hyprland.toplevels` for the common cases (empty workspace, `showOnFloating` disabled); only falls back to `hyprctl clients -j` when `showOnFloating` is true and there are windows on the workspace
- Relevant Hyprland events: `workspace`, `workspacev2`, `activewindow`, `activewindowv2`, `createworkspace`, `createworkspacev2`, `destroyworkspace`, `destroyworkspacev2`
