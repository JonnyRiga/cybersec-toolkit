# paramfuzz

Discovery + triage tool for hidden HTTP parameters.  
Built on `ffuf` for discovery, with built-in vuln probes and handoff suggestions for specialist tools.

## What it does

1. Discovers hidden GET/POST params via `ffuf`
2. Auto-detects dynamic pages (samples baseline twice; switches to `-ac` if unstable)
3. Runs configurable triage probes against each discovered param
4. Suggests specialist-tool commands (`sqlmap`, `dalfox`, `commix`, etc.) for each hit

## Dependencies

- `ffuf`
- `curl`
- `jq`
- `python3` (for URL encoding)
- SecLists (`/usr/share/seclists/`)

## Usage

```
paramfuzz -u URL [OPTIONS]

DISCOVERY
  -u URL       Target URL (required)
  -p PARAMS    Known params to include (e.g. "foo=bar&baz=qux")
  -d DATA      POST body data (auto-switches to POST)
  -H HEADER    Add header, repeatable
  -b COOKIE    Cookie string
  -w WORDLIST  Wordlist (default: burp-parameter-names.txt)
  -fs SIZE     Filter size — omit to auto-baseline
  -ac          Force ffuf auto-calibration
  -t THREADS   Threads
  -o OUTFILE   Save ffuf results (JSON)
  -x PROXY     Proxy URL (e.g. http://127.0.0.1:8080)

TRIAGE
  -M [MODS]    Comma-separated modules; omit value to run all:
                 lfi sqli sqli_time xss ssti cmdi redirect headers
  -A           Shortcut for -M all
  --no-handoff Suppress handoff suggestions
  --skip-fuzz  Skip discovery; only probe known params (-p / inline / headers)
```

## Examples

```bash
# Discovery only
paramfuzz -u "http://target/page.php"

# Discovery + full triage (the common case)
paramfuzz -u "http://target/page.php?foo=bar" -A

# Authenticated app through Burp
paramfuzz -u "https://app/api/user" -b "session=abc123" -A -x http://127.0.0.1:8080

# POST endpoint
paramfuzz -u "http://target/login.php" -d "user=admin&pass=test" -A

# Triage known params only (no fuzzing)
paramfuzz -u "http://target/view.php?id=1" --skip-fuzz -M sqli,sqli_time

# Header injection sweep only
paramfuzz -u "http://target/" --skip-fuzz -M headers
```

## Modules

| Module | Payload | Detection |
|--------|---------|-----------|
| `lfi` | `../../../../etc/passwd` | grep `root:x:` |
| `sqli` | `1'"` | grep SQL error patterns |
| `sqli_time` | `1' AND SLEEP(5)-- -` | response time delta >4s |
| `xss` | `<pfzz>test</pfzz>` | raw reflection check |
| `ssti` | `{{7*7}}` and variants | check for `49` in response |
| `cmdi` | `;id;` / `\|id` | grep `uid=` |
| `redirect` | `//evil.paramfuzz.test/` | check `Location` header |
| `headers` | Marker in Referer, User-Agent, X-Forwarded-* | reflection in body |

## Handoff suggestions

On a confirmed hit, paramfuzz prints the recommended specialist tool:

```
SQLI     -> sqlmap -u "..." -p NAME --batch
XSS      -> dalfox url "..." -p NAME
SSTI     -> sstimap -u "..." -P NAME
LFI      -> curl ".../page.php?NAME=/var/log/nginx/access.log"
CMDI     -> commix -u "..." -p NAME
REDIRECT -> manual: test //attacker/ with various encodings
HEADER   -> manual: probe header for SSTI/SQLi/LFI
```

## Notes

- Probes are triage, not exploitation — use specialist tools for confirmed vulns
- WAFs will block many payloads before the app sees them
- For complex auth (OAuth, CSRF tokens), use Burp instead
