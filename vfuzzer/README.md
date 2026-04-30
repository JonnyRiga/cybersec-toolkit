# vfuzzer

Virtual host and subdomain fuzzer built on `ffuf`. Supports vhost mode (Host header injection) and DNS subdomain mode, with auto-calibration when no filter size is provided.

## Dependencies

- `ffuf`
- SecLists (`/usr/share/seclists/`)

## Usage

```
vfuzzer <DOMAIN> [IP] [http|https] [WORDLIST] [FS] [-t THREADS] [-o OUTFILE] [--dns]

  DOMAIN      Target domain (required)
  IP          Target IP to connect to — defaults to DOMAIN (vhost mode only)
  http|https  Protocol — defaults to http
  WORDLIST    Path to wordlist (default: subdomains-top1million-5000.txt)
  FS          Filter size (positional, always last — omit to auto-calibrate)
  -t THREADS  Thread count (default: ffuf default 40)
  -o OUTFILE  Save results to file (JSON)
  --dns       Subdomain mode: fuzz http://FUZZ.DOMAIN instead of Host header
```

## Examples

```bash
# Vhost mode — domain resolves itself
vfuzzer example.com 1234

# Vhost mode — target IP differs from domain (typical CTF/lab)
vfuzzer example.com 10.10.10.5 1234

# HTTPS with threads and output file
vfuzzer example.com 10.10.10.5 https 1234 -t 20 -o results.json

# Subdomain mode (DNS fuzzing)
vfuzzer example.com --dns 1234

# Auto-calibrate (no FS — omit the filter size entirely)
vfuzzer example.com 10.10.10.5
```

## Modes

| Mode | How it works |
|------|-------------|
| **vhost** (default) | Injects `Host: FUZZ.DOMAIN` header, connects to `IP` |
| **subdomain** (`--dns`) | Fuzzes `http://FUZZ.DOMAIN` directly |

## Notes

- Omit `FS` to use `ffuf -ac` (auto-calibration) — useful when you don't have a baseline size yet
- `FS` is always the last positional argument; IP, protocol, and wordlist are auto-detected by format
- Default wordlist: `/usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt`
