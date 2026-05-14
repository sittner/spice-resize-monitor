# spice-resize-monitor

Auto-resize display for SPICE guests on non-GNOME desktops (MATE, XFCE, LXQt, etc.).

## Problem

`spice-vdagent` fails to auto-apply display resolution changes on desktops that don't provide `org.gnome.Mutter.DisplayConfig` over DBus. When you resize the SPICE viewer window, the guest resolution doesn't follow.

## Solution

This package provides a simple event-driven systemd service that listens for X RandR events using `xev` and applies the SPICE-provided preferred resolution automatically via `xrandr`.

## Dependencies

- `spice-vdagent` — SPICE guest agent (for clipboard, drag & drop, etc.)
- `x11-utils` — provides `xev`
- `x11-xserver-utils` — provides `xrandr`

## Building the Debian package

```bash
sudo apt install debhelper build-essential
git clone https://github.com/sittner/spice-resize-monitor.git
cd spice-resize-monitor
dpkg-buildpackage -us -uc -b
```

The `.deb` will be in the parent directory:

```bash
sudo dpkg -i ../spice-resize-monitor_1.0.0-1_all.deb
```

## Manual installation

```bash
sudo install -m 0755 spice-resize-monitor.sh /usr/lib/spice-resize-monitor/spice-resize-monitor.sh
sudo install -m 0644 spice-resize-monitor.service /usr/lib/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now spice-resize-monitor.service
```

## How it works

1. Finds the active X session user
2. Applies the current preferred resolution on startup
3. Listens for RandR events via `xev -root -event randr`
4. On each event, runs `xrandr --output Virtual-1 --auto` to apply the new resolution

No polling, no sleep hacks, no race conditions.

## License

GPL-2.0-or-later
