# auto_login.ps1 - 校园网自动登录脚本
# 河南工学院 HAIT-Student Portal 自动认证
# 配置在同目录 config.ps1（首次使用从 config.example.ps1 复制）

$ErrorActionPreference = "SilentlyContinue"
$SCRIPT_DIR = $PSScriptRoot
$LOG_FILE = Join-Path $SCRIPT_DIR "auto_login.log"
$CONFIG_FILE = Join-Path $SCRIPT_DIR "config.ps1"
$CONFIG_EXAMPLE = Join-Path $SCRIPT_DIR "config.example.ps1"

function Log($msg) {
    $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $msg
    Add-Content -Path $LOG_FILE -Value $line -Encoding utf8
}

# ====== 加载配置 ======
if (-not (Test-Path $CONFIG_FILE)) {
    Copy-Item $CONFIG_EXAMPLE $CONFIG_FILE -Force
    Log "首次运行：已从示例创建 config.ps1，请编辑填入账号密码后重新运行"
    Write-Host "首次使用：请打开 $CONFIG_FILE 填入你的学号和密码，然后重新运行本脚本。" -ForegroundColor Yellow
    exit 2
}
. $CONFIG_FILE

if (-not $USERID -or $USERID -like "*你的学号*" -or -not $PASSWD -or $PASSWD -like "*你的密码*") {
    Log "config.ps1 尚未填写真实账号密码"
    Write-Host "请先编辑 $CONFIG_FILE 填入你的学号和密码。" -ForegroundColor Yellow
    exit 2
}

# ====== 默认参数兜底（即使config里没写）=====
if (-not $PORTAL)   { $PORTAL   = "http://211.69.15.10:6060/quickauth.do" }
if (-not $ACNAME)   { $ACNAME   = "HAIT-SR8808" }
if (-not $ACIP)     { $ACIP     = "172.21.8.73" }
if (-not $SSID_LIST){ $SSID_LIST = @("HAIT-Student-5G-12","HAIT-Student-5G-11","HAIT-Student-5G-10","HAIT-Student") }

function Test-Internet {
    try {
        $r = Invoke-WebRequest -Uri "http://www.baidu.com" -UseBasicParsing -TimeoutSec 5 -MaximumRedirection 0
        return $true
    } catch {
        return $false
    }
}

function Get-WlanIp {
    $ip = (Get-NetIPAddress -InterfaceAlias "WLAN" -AddressFamily IPv4 -ErrorAction SilentlyContinue |
           Where-Object { $_.IPAddress -like "10.*" -or $_.IPAddress -like "172.*" } |
           Select-Object -First 1).IPAddress
    return $ip
}

function Connect-Wifi {
    $current = (netsh wlan show interfaces | Select-String "SSID\s*:\s*(.+)").Matches.Groups[1].Value.Trim()
    if ($current -like "HAIT-Student*") {
        Log "已连接校园网WiFi: $current"
        return $current
    }
    foreach ($ssid in $SSID_LIST) {
        Log "尝试连接: $ssid"
        netsh wlan connect name="$ssid" ssid="$ssid" | Out-Null
        Start-Sleep -Seconds 4
        $now = (netsh wlan show interfaces | Select-String "SSID\s*:\s*(.+)").Matches.Groups[1].Value.Trim()
        if ($now -like "HAIT-Student*") {
            Log "WiFi连接成功: $now"
            return $now
        }
    }
    Log "所有候选WiFi均连接失败"
    return $null
}

function Portal-Login($wlanIp, $ssid) {
    $params = @{
        userid      = $USERID
        passwd      = $PASSWD
        wlanuserip  = $wlanIp
        wlanacname  = $ACNAME
        wlanacIp    = $ACIP
        ssid        = $ssid
    }
    try {
        $r = Invoke-WebRequest -Uri $PORTAL -Method Get -Body $params -UseBasicParsing -TimeoutSec 10
        $body = $r.Content
        if ($body -is [byte[]]) { $body = [System.Text.Encoding]::UTF8.GetString($body) }
        Log "Portal响应: $body"
        return $body
    } catch {
        $resp = $_.Exception.Response
        if ($resp) {
            $sr = New-Object System.IO.StreamReader($resp.GetResponseStream())
            $b = $sr.ReadToEnd()
            Log "Portal错误响应: $b"
            return $b
        }
        Log "Portal请求异常: $($_.Exception.Message)"
        return $null
    }
}

# ====== 主流程 ======
Log "===== 脚本启动 ====="

$wifiReady = $false
for ($i = 0; $i -lt 30; $i++) {
    if (Get-NetAdapter -Name "WLAN" -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq "Up" }) {
        $wifiReady = $true
        break
    }
    Start-Sleep -Seconds 2
}
if (-not $wifiReady) { Log "WLAN接口60秒内未就绪，退出"; exit 1 }

$connectedSsid = Connect-Wifi
if (-not $connectedSsid) { exit 1 }

$wlanIp = $null
for ($i = 0; $i -lt 15; $i++) {
    $wlanIp = Get-WlanIp
    if ($wlanIp) { break }
    Start-Sleep -Seconds 2
}
if (-not $wlanIp) { Log "未获取到WLAN IP，退出"; exit 1 }
Log "本机WLAN IP: $wlanIp"

if (Test-Internet) {
    Log "外网已通，无需登录"
    exit 0
}

for ($try = 1; $try -le 3; $try++) {
    Log "第 $try 次登录尝试..."
    Portal-Login $wlanIp $connectedSsid | Out-Null
    Start-Sleep -Seconds 4
    if (Test-Internet) {
        Log "登录成功，外网已通"
        exit 0
    }
    Log "登录后外网仍不通，重试..."
}

Log "3次尝试后仍未联网"
exit 1
