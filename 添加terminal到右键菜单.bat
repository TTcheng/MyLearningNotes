@REM 前置步骤：需要在WT中配置"startingDirectory": "."，否则不能在当前目录打开
@echo off
reg.exe add "HKEY_CLASSES_ROOT\Directory\Background\shell\wt" /f /ve /d "Windows Terminal here"
reg.exe add "HKEY_CLASSES_ROOT\Directory\Background\shell\wt" /f /v "Icon" /t REG_EXPAND_SZ /d "C:\Users\Administrator\Pictures\terminal.ico"
reg.exe add "HKEY_CLASSES_ROOT\Directory\Background\shell\wt\command" /f /ve /t REG_EXPAND_SZ /d "\"%%LOCALAPPDATA%%\Microsoft\WindowsApps\wt.exe\""
pause