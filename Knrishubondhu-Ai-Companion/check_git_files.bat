@echo off
cd /d d:\Knrishubondhu-Ai-Companion
echo Current directory:
cd
echo.
echo Listing Git tracked files with app_config:
git ls-files | findstr app_config
echo.
echo Git status:
git status
pause
