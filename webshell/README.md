# webshell

A retro-styled PHP webshell for post-exploitation and CTF use.

## Features

| Feature | Detail |
|---------|--------|
| Auth | Session-based password gate. Set `PASSWORD` constant at the top of the file. Session ID is rotated on login. |
| Command execution | Run arbitrary shell commands. Output is XSS-safe. Command box re-populates after submission. |
| Command history | Last 50 commands stored in `localStorage`. Cycle with ↑ / ↓ arrow keys. |
| Reverse shells | One-click launchers for bash, python3, perl, nc mkfifo, and php. Auto-detects `tun0` IP; LHOST/LPORT are editable. |
| File upload | Upload to any writable path on the target. Destination validated before write. |
| File download | Pull any readable file back to your browser as an attachment. |
| Copy button | Copies raw command output to clipboard. |
| Sysinfo panel | Kernel/OS, current user, connected users, network interfaces, listening ports, cron jobs, SUIDs, capabilities, disks, writable directories. |

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
