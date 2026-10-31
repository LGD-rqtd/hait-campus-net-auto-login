# auto-campus-net（河南工学院校园网自动登录）

开机登录 Windows 后自动连校园网，不用再开网页输账号密码。

## 怎么用（30秒搞定）

1. 点绿色 **Code** 按钮 → **Download ZIP**，解压
2. 进入 `scripts` 文件夹
3. **双击 `一键安装.bat`**
4. 弹窗里输学号 → 选运营商 → 输密码
5. 看到"安装成功"就完事了

下次开电脑自动后台连校园网，无黑窗口。

## 常见问题

**Q: 弹窗一闪就没了？**
A: 右键 `一键安装.bat` → 以管理员身份运行。

**Q: 提示"账号或密码不正确"？**
A: 重新双击 `一键安装.bat`，选对运营商后缀（电信@gxydx / 移动@gxyyd / 联通@gxylt / 本地@gxylocal）。

**Q: 怎么卸载？**
A: 在PowerShell里运行：
```
Unregister-ScheduledTask -TaskName "AutoCampusNet" -Confirm:$false
```

## 文件说明

| 文件 | 作用 |
|---|---|
| `scripts/一键安装.bat` | **双击这个就行** |
| `scripts/setup.ps1` | 安装向导（被bat调用） |
| `scripts/auto_login.ps1` | 自动登录主脚本 |
| `scripts/install.ps1` | 注册开机自启 |
| `scripts/config.example.ps1` | 配置模板（不用手动改） |
