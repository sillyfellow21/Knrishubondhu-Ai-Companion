@echo off
echo Checking Git status...
cd /d d:\Knrishubondhu-Ai-Companion\Knrishubondhu-Ai-Companion
git status
echo.
echo Checking if app_config.dart is tracked...
git ls-files | findstr app_config.dart
