# install.ps1 - 一键安装开机自动登录（以当前用户身份登录时触发）
# 用法：右键 -> 使用 PowerShell 运行，或在 PowerShell 中执行：
#   powershell -ExecutionPolicy Bypass -File install.ps1

$SCRIPT_DIR = $PSScriptRoot
$LOGIN_SCRIPT = Join-Path $SCRIPT_DIR "auto_login.ps1"
$SYSTEM_POWERSHELL = "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe"
$TASK_NAME = "AutoCampusNet"

if (-not (Test-Path $LOGIN_SCRIPT)) {
    Write-Host "找不到 auto_login.ps1，请把本脚本放在它同一目录。" -ForegroundColor Red
    exit 1
}

# 检查config.ps1
$CONFIG_FILE = Join-Path $SCRIPT_DIR "config.ps1"
$CONFIG_EXAMPLE = Join-Path $SCRIPT_DIR "config.example.ps1"
if (-not (Test-Path $CONFIG_FILE)) {
    Copy-Item $CONFIG_EXAMPLE $CONFIG_FILE -Force
    Write-Host "已创建 config.ps1，请先填入你的学号和密码，再重新运行本安装脚本。" -ForegroundColor Yellow
    notepad $CONFIG_FILE
    exit 0
}

$action = New-ScheduledTaskAction -Execute $SYSTEM_POWERSHELL -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$LOGIN_SCRIPT`""
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 5)

Register-ScheduledTask -TaskName $TASK_NAME -Action $action -Trigger $trigger -Settings $settings -Description "开机自动登录校园网Portal" -Force | Out-Null

Write-Host ""
Write-Host "安装完成！" -ForegroundColor Green
Write-Host "  - 任务名：$TASK_NAME"
Write-Host "  - 触发：登录Windows时自动后台运行"
Write-Host "  - 立即测试一次："
Write-Host "      Start-ScheduledTask -TaskName $TASK_NAME"
Write-Host "  - 卸载："
Write-Host "      Unregister-ScheduledTask -TaskName $TASK_NAME -Confirm:`$false"
