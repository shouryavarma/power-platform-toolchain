@echo off
title PowerMesh Installer
echo ============================================
echo  PowerMesh - Power Platform Toolchain
echo  One-command setup for Claude Code
echo ============================================
echo.

where powershell >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: PowerShell is required but not found.
    pause
    exit /b 1
)

echo Installing PowerMesh...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
if %ERRORLEVEL% equ 0 (
    echo.
    echo DONE! Open Claude Code and try: "list solutions"
) else (
    echo.
    echo Setup encountered issues. See output above.
)
echo.
pause
