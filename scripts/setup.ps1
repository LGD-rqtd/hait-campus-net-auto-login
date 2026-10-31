# setup.ps1 - 一键安装：图形弹窗收集账号密码 + 注册开机自启
Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName System.Windows.Forms

$SCRIPT_DIR = $PSScriptRoot
Set-Location $SCRIPT_DIR

# 弹窗输学号
$uid = [Microsoft.VisualBasic.Interaction]::InputBox(
    "请输入你的学号（如 2404244333）：",
    "校园网自动登录 - 第1步/共3步",
    ""
)
if ([string]::IsNullOrWhiteSpace($uid)) {
    [System.Windows.Forms.MessageBox]::Show("已取消。", "取消") | Out-Null
    exit
}

# 弹窗选运营商
$msg = @"
请选择你的运营商：

点【确定】= 电信账号（@gxydx）
点【取消】= 移动账号（@gxyyd）

（如果是联通或本地账号，会再问你一次）
"@
$r = [System.Windows.Forms.MessageBox]::Show($msg, "第2步/共3步：选择运营商", [System.Windows.Forms.MessageBoxButtons]::OKCancel)
if ($r -eq [System.Windows.Forms.DialogResult]::OK) {
    $sfx = "@gxydx"
} else {
    $r2 = [System.Windows.Forms.MessageBox]::Show("再选一次：`n`n【确定】= 联通（@gxylt）`n【取消】= 本地/单宽（@gxylocal）", "移动/其他", [System.Windows.Forms.MessageBoxButtons]::OKCancel)
    if ($r2 -eq [System.Windows.Forms.DialogResult]::OK) { $sfx = "@gxylt" } else { $sfx = "@gxyyd" }
}

# 弹窗输密码
$pwd = [Microsoft.VisualBasic.Interaction]::InputBox(
    "请输入你的校园网密码：",
    "第3步/共3步：输入密码",
    ""
)
if ([string]::IsNullOrWhiteSpace($pwd)) {
    [System.Windows.Forms.MessageBox]::Show("已取消。", "取消") | Out-Null
    exit
}

# 写config.ps1
$config = @"
`$USERID = "$uid$sfx"
`$PASSWD = "$pwd"
`$PORTAL = "http://211.69.15.10:6060/quickauth.do"
`$ACNAME = "HAIT-SR8808"
`$ACIP = "172.21.8.73"
`$SSID_LIST = @("HAIT-Student-5G-12","HAIT-Student-5G-11","HAIT-Student-5G-10","HAIT-Student")
"@
Set-Content -Path (Join-Path $SCRIPT_DIR "config.ps1") -Value $config -Encoding UTF8

# 调用install.ps1注册开机任务
& (Join-Path $SCRIPT_DIR "install.ps1")

[System.Windows.Forms.MessageBox]::Show(
    "全部完成！`n`n账号：$uid$sfx`n下次开电脑会自动连校园网。",
    "安装成功"
) | Out-Null
