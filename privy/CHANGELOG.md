# Privy — Changelog

---

## privy.sh v1.6 — 2026-05-17

### Added
- **Phase 15: Nextcloud detection** — finds installation via `version.php`, extracts version, flags CVE-2023-48239 (auth bypass < 27.1.3) and CVE-2024-37302 (SSRF, 28.0.0–28.0.4); checks `config.php` for readable DB credentials
- **Phase 15: Portainer detection** — finds binary or running process, extracts version from Docker image tag, flags CVE-2022-26960 (path traversal < 2.11.1) and runc CVE-2024-21626; checks for readable `portainer.db`
- **pgrep fallbacks for Gitea and Grafana** — process-based detection when binary not found in standard paths (matching existing behaviour for Jenkins and Flowise)
- **P2 exploit entries** for Nextcloud auth bypass and Portainer path traversal in `01-ExploitPaths.txt`

### Fixed
- `pgrep -f 'grafana'` tightened to `pgrep -f 'grafana-server'` to avoid false positives from `grafana-agent` processes
- CVE-2024-37302 (Nextcloud) lower-bound guard added — was incorrectly firing on all 27.x installs; now correctly scoped to 28.0.0–28.0.4 only
- Portainer version extraction replaced dead `--version` call with `docker inspect` / `docker ps` image tag lookup

---

## privy.sh v1.5 — 2026-05-17

### Added
- **Phase 15: Third-Party Application CVE Check** — new phase scanning for self-hosted services with known critical CVEs; outputs to `ThirdPartyApps.txt`
- **Apps covered:** Gogs, Gitea, Jenkins, Grafana, MinIO, Flowise
- Version-aware CVE flagging: CVE-2024-39930/31/32/33 (Gogs RCE < 0.13.0), CVE-2024-23897 (Jenkins unauth file read < 2.442), CVE-2021-43798 (Grafana path traversal 8.0.0–8.3.0), CVE-2023-28432 (MinIO env leak), CVE-2025-59528 + CVE-2025-58434 (Flowise RCE + reset token leak < 3.0.6)
- Jenkins secrets detection: flags readable `credentials.xml` and `master.key`
- Grafana config credential check: flags plaintext `secret_key`/`admin_password` in `grafana.ini`
- MinIO process argument sniff: extracts `MINIO_ROOT_USER/PASSWORD` from `ps` output
- Gogs runtime check: flags if Gogs process runs as root; checks for writable git hooks
- Generic `/opt` scanner: lists unknown apps with version file hints
- P1/P2 exploit entries auto-generated in `01-ExploitPaths.txt` for all detected vulnerable versions

### Fixed
- Phase 16 display header corrected (was showing "PHASE 15")
- Flowise `package.json` version extraction fixed for standard npm format (space after colon); uses `jq` with grep fallback
- Binary path variables quoted in command substitutions to handle spaces in paths
- `/home` removed from `find` scope for Gogs/Gitea/Flowise (too broad, slow)
- Gitea CVE reference softened to advisory language (CVE ID unverified against NVD)
- MinIO finding clarified as version-uncertain (CalVer not comparable via semver)
- Header comment updated to Version: 1.5

---

## privy.sh v1.4 — 2026-05-08

### Added
- SSH client config detection: flags readable `~/.ssh/config` files revealing hosts, users, and identity files for lateral movement
- Vhost config credential scan: flags nginx/apache configs containing `auth_basic`, `proxy_pass`, or credential directives

---

## privy.sh v1.3 — 2026-05-08

### Added
- `.htpasswd` file detection: finds readable `.htpasswd` files under `/var/www`, `/etc`, `/home`; flags as potential plaintext/reused credential source

---

## privy.sh v1.2 — 2026-04-26

### Added
- **Kernel CVE checks:** DirtyCow (CVE-2016-5195, kernel < 4.8.3) and DirtyPipe (CVE-2022-0847, kernel 5.8–5.16.11)
- **sudo `-n` flag:** non-interactive sudo listing to avoid prompting for password during enumeration
- **Process credential sniffing:** scans `ps auxww` for passwords/tokens/API keys in process arguments
- **Loopback-only services:** flags services bound to `127.0.0.1` as SSH port-forward pivot candidates
- **MOTD script detection:** flags writable `/etc/update-motd.d/` scripts (execute as root on next SSH login)
- **Full PostgreSQL enumeration:** no-auth access check, superuser detection, `COPY TO PROGRAM` RCE path, untrusted procedural language detection, `pg_hba.conf` trust auth check, `.pgpass` readability
- **`/proc` and `/sys` exclusions** from find-based scans to reduce noise and runtime

### Fixed
- `pg_hba.conf` display suppressed when PostgreSQL is not installed

---

## privy.ps1 v1.2 — 2026-04-26

### Added
- HiveNightmare (CVE-2021-36934) detection
- GPP cPassword hunting in SYSVOL
- Privileged group membership analysis (`Administrators`, `Backup Operators`, `Remote Management Users`, etc.)
- DLL hijack directory enumeration (writable dirs in system PATH)
- LSA Protection and Credential Guard status checks
- PowerShell Constrained Language Mode detection
- RDP saved connection files (`.rdp`) hunting
- Truncation fix for long output lines

---

## v1.1 — 2026-04-24

### Added
- Initial consolidation of privy.sh and privy.ps1 into unified repo
- privy.sh: 14 phases covering system info, users, passwd/shadow, services, cron, PATH, network, SUID/SGID/capabilities, SSH keys, MySQL, interesting files, filesystem, histories, dev tools
- privy.ps1: 12 phases covering Windows privesc vectors
- P1/P2/P3 exploit path suggestions with copy-paste commands for both platforms
- GTFOBins SUID/SGID candidate detection (50+ binaries)
- Dangerous capability detection with per-capability exploit recipes
- Baron Samedit (CVE-2021-3156) and PwnKit (CVE-2021-4034) detection
