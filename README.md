# auto-campus-net（河南工学院校园网自动登录）

开机登录 Windows 后自动完成：连 HAIT-Student WiFi → 检测外网 → 未认证则自动调用 Portal 接口登录。无需再开网页输账号密码。

## 适用对象

- **河南工学院（HAIT）在校学生**
- Windows 10 / 11
- 宿舍/教室的 HAIT-Student-5G 系列开放 WiFi
- Portal 服务器：`211.69.15.10:6060`（华为 SR8808）

## 使用方法（3 步）

### 1. 下载代码

```powershell
git clone <你的仓库地址>
cd auto-campus-net
```

或直接下载 ZIP 解压。

### 2. 填账号密码

进入 `scripts/` 目录，把 `config.example.ps1` 复制为 `config.ps1`，编辑两行：

```powershell
$USERID = "你的学号@gxydx"   # 或 @gxyyd / @gxylt / @gxylocal
$PASSWD = "你的校园网密码"
```

后缀对照：
| 运营商 | 后缀 |
|---|---|
| 电信 | `@gxydx` |
| 移动 | `@gxyyd` |
| 联通 | `@gxylt` |
| 本地/单宽 | `@gxylocal` |

> 不确定后缀？登录一次网页版 Portal 看你平时点的是哪个运营商按钮。

### 3. 安装开机自启

在 `scripts/` 目录下右键 `install.ps1` → "使用 PowerShell 运行"，或：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\install.ps1
```

看到"安装完成"就完事了。以后开机自动后台运行，无黑窗口。

## 手动测试

```powershell
powershell -ExecutionPolicy Bypass -File scripts\auto_login.ps1
```

看 `scripts/auto_login.log` 排查问题。

## 卸载

```powershell
Unregister-ScheduledTask -TaskName "AutoCampusNet" -Confirm:$false
```

## 文件说明

```
auto-campus-net/
├── SKILL.md                    # 豆包skill元数据（给AI Agent用）
├── README.md
├── .gitignore
└── scripts/
    ├── auto_login.ps1          # 主脚本：连WiFi+Portal登录
    ├── install.ps1             # 一键安装开机自启
    ├── config.example.ps1      # 配置模板（上传GitHub）
    ├── config.ps1              # 你的真实配置（不上传）
    └── auto_login.log          # 运行日志（不上传）
```

## 安全说明

- 你的账号密码只存在本地 `config.ps1`，已被 `.gitignore` 排除，**不会**上传
- Portal 接口为学校内网明文 HTTP，登录请求在校园网内传输（与你用浏览器登录同等安全）
- 脚本不收集、不上传任何数据

## 常见问题

**Q: 提示"账号或密码不正确"？**
A: 检查 `config.ps1` 里的后缀是否和你平时网页登录选的运营商一致。

**Q: 开机后还是要手动开网页？**
A: 看 `auto_login.log`，如果日志里写"外网已通"但实际没网，可能是Portal会话过期，跑一次 `install.ps1` 重装任务。

**Q: 换WiFi信号了（从5G-12切到5G-11）？**
A: 脚本会自动按优先级尝试所有 HAIT-Student 信号，不用改。
