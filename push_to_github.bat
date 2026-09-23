@echo off
title Push Kanz-e-Naseem to GitHub
cd /d "D:\Kanz E Naseem"
set "PATH=%USERPROFILE%\mingit\cmd;%PATH%"
echo ========================================================
echo   Kanz-e-Naseem (کنزِ نسیم) - GitHub Upload Script
echo ========================================================
echo.
echo Target Repository: https://github.com/ranaalijaved154-wq/Kanz-E-Naseem.git
echo.
echo Pushing commits to branch 'main'...
git push -u origin main
echo.
if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] Project successfully uploaded to GitHub!
) else (
    echo [NOTICE] If prompted for credentials:
    echo   Username: ranaalijaved154-wq (or your GitHub email)
    echo   Password: Use your GitHub Personal Access Token (PAT)
)
echo.
pause
