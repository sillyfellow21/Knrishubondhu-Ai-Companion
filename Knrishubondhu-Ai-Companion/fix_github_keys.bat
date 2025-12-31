@echo off
echo Removing app_config.dart from Git repository...
cd /d d:\Knrishubondhu-Ai-Companion

git rm --cached Knrishubondhu-Ai-Companion\lib\core\config\app_config.dart
git add Knrishubondhu-Ai-Companion\.gitignore
git commit -m "Remove app_config.dart from tracking - contains sensitive keys"
git push origin master

echo.
echo Done! The file is removed from GitHub but kept locally.
echo Restore your API keys from MY_API_KEYS_BACKUP.txt
pause
