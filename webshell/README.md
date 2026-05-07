# webshell

A hacker-red CRT-styled PHP webshell for post-exploitation and CTF use.

## Features

| Feature | Detail |
|---------|--------|
| Auth | Session-based password gate. Session ID is rotated on login. Logout link in the UI. |
| Command execution | Run arbitrary shell commands. Output is XSS-safe. Command box re-populates after submission. |
| Command history | Last 50 commands stored in `localStorage`. Cycle with ↑ / ↓ arrow keys. Consecutive duplicates deduplicated. |
| Reverse shells | One-click launchers for bash, python3, perl, nc mkfifo, and php. Auto-detects `tun0` IP; LHOST/LPORT editable in the UI. |
| File upload | Upload to any writable path on the target. Destination validated before write; move failure reported explicitly. |
| File download | Pull any readable file back to your browser as an attachment. |
| Copy button | Copies raw command output to clipboard. |
| Sysinfo panel | Kernel/OS, current user, connected users, network interfaces, listening ports (`ss -tlnp`), cron jobs, SUIDs, capabilities (`getcap`), disks, writable directories — all collapsible. |

## Aesthetic

- **Hacker-red scheme** — `#ff2200` primary, `#ffaaaa` soft text, `#ff6600` accent buttons
- **CRT vignette** — radial gradient darkens toward screen edges
- **Scrolling scanlines** — `3px` period, phase-locked scroll animation
- **Typewriter header** — title animates in on load, cursor blinks and disappears
- **Blinking prompt cursor** — `root@shell:~$_` pulses on the command label
- **Collapsible sysinfo** — all sections collapsed by default via `<details>`/`<summary>`

## Setup

1. Drop `webshell.php` somewhere the web server will execute PHP.
2. Change the `PASSWORD` constant near the top of the file.
3. Navigate to the file in your browser.

## Customisation

- **Password:** `define('PASSWORD', 'sh3ll');` — change before deploying.
- **LHOST:** Auto-populated from `tun0`. Override in the UI if using a different interface.
- **LPORT:** Default `4444`. Editable in the UI.

## Disclaimer

For authorised penetration testing, CTF competitions, and security research only.
