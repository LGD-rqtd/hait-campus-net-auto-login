@echo off
cd /d "%~dp0"
echo 正在启动安装程序...
powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0setup.ps1"
