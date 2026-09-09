@echo off
title VetCare Flutter App Launcher
set "PATH=%USERPROFILE%\Downloads\flutter\bin;%PATH%"
cd /d "%~dp0"
echo ========================================
echo Starting VetCare Flutter App on http://localhost:3000 ...
echo ========================================
flutter run -d chrome --web-port=3000
pause
