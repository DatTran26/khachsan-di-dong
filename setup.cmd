@echo off
rem Chuan bi moi truong lan dau. Tham so: -DbPort 5433 / -SkipDemo / -Docker
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\setup.ps1" %*
