@echo off
title Kanz-e-Naseem App Launcher
cd /d "D:\Kanz E Naseem"
set "PATH=C:\flutter\bin;%USERPROFILE%\mingit\cmd;%PATH%"

echo ========================================================
echo   Kanz-e-Naseem (کنزِ نسیم) - Launching App
echo ========================================================
echo.
echo Starting application in Google Chrome...
echo (Press 'r' in this window to Hot Reload, 'R' to Hot Restart, 'q' to Quit)
echo.

call flutter run -d chrome

echo.
pause
