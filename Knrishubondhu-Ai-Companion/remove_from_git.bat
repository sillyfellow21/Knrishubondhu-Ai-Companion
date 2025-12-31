@echo off
REM Remove app_config.dart from Git tracking completely
cd /d d:\Knrishubondhu-Ai-Companion\Knrishubondhu-Ai-Companion

echo.
echo ==========================================
echo  Removing app_config.dart from Git
echo ==========================================
echo.

echo Step 1: Removing app_config.dart from Git tracking...
git rm --cached lib\core\config\app_config.dart

echo.
echo Step 2: Committing the removal...
git add .gitignore
git commit -m "Remove app_config.dart from repository - security fix"

echo.
echo Step 3: Pushing changes...
git push origin master

echo.
echo ==========================================
echo  Complete!
echo ==========================================
echo.
echo The file app_config.dart has been removed from Git repository.
echo It still exists on your computer but won't be tracked anymore.
echo.
echo IMPORTANT: After this, restore your API keys in the local file:
echo   lib\core\config\app_config.dart
echo.
echo Use the keys from MY_API_KEYS_BACKUP.txt
echo.

pause
