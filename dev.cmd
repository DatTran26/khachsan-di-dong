@echo off
rem Chay hang ngay: bat backend + flutter run. Tham so: -Device chrome / -BackendOnly
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\dev.ps1" %*
