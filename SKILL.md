---
name: auto-campus-net
description: 河南工学院(HAIT)校园网开机自动连接脚本。当用户提到校园网连不上、开机要手动登录Portal、想自动连HAIT-Student WiFi、需要开机自动认证校园网时使用。Portal地址 211.69.15.10:6060 已内置，账号密码在 scripts/config.ps1 配置。
---

# auto-campus-net（校园网自动登录）

针对河南工学院 HAIT-Student 开放WiFi + Portal网页认证 的场景，开机后自动完成：连WiFi → 获取IP → 检测外网 → 未登录则调用 `quickauth.do` 自动认证。

## 首次使用

1. 进入 `scripts/` 目录
2. 复制 `config.example.ps1` 为 `config.ps1`
3. 编辑 `config.ps1`，填入自己的学号和密码（按运营商选后缀）
4. 运行 `scripts/install.ps1` 一键配置开机自启

## 内置参数（河南工学院，一般不用改）

- Portal：`http://211.69.15.10:6060/quickauth.do`
- AC名称：`HAIT-SR8808`，AC IP：`172.21.8.73`
- WiFi优先级：`HAIT-Student-5G-12` → `5G-11` → `5G-10` → `HAIT-Student`

## 手动运行

```powershell
powershell -ExecutionPolicy Bypass -File "<skill目录>/scripts/auto_login.ps1"
```

日志在同目录 `auto_login.log`。

## 脚本行为

1. 等待WLAN接口Up（最多60秒）
2. 若未连HAIT-Student WiFi，按优先级依次连接
3. 等待获取 10.x / 172.x 网段IP
4. 访问 baidu.com 判活：通则退出
5. 不通则携带 config.ps1 里的账号密码请求 `quickauth.do`，最多重试3次
