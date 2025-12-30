@echo off
REM =====================================================
REM KrishiBondhu AI - Safe Git Commit Script
REM This script removes sensitive files from Git tracking
REM and prepares your code for safe commit
REM =====================================================

echo.
echo ==========================================
echo  KrishiBondhu AI - Safe Commit Setup
echo ==========================================
echo.

cd /d d:\Knrishubondhu-Ai-Companion\Knrishubondhu-Ai-Companion

echo [Step 1/5] Checking current Git status...
echo.
git status
echo.

echo [Step 2/5] Removing sensitive files from Git tracking (if they exist)...
echo.

REM Remove app_config.dart from Git tracking but keep local file
git rm --cached lib\core\config\app_config.dart 2>nul
if %errorlevel%==0 (
    echo    - Removed app_config.dart from Git tracking
) else (
    echo    - app_config.dart was not tracked
)

REM Remove google-services.json if it exists
git rm --cached android\app\google-services.json 2>nul
if %errorlevel%==0 (
    echo    - Removed google-services.json from Git tracking
) else (
    echo    - google-services.json was not found/tracked
)

REM Remove iOS GoogleService-Info.plist if it exists
git rm --cached ios\Runner\GoogleService-Info.plist 2>nul
if %errorlevel%==0 (
    echo    - Removed GoogleService-Info.plist from Git tracking
) else (
    echo    - GoogleService-Info.plist was not found/tracked
)

echo.
echo [Step 3/5] Adding new files (.gitignore updates, example config, guide)...
echo.
git add .gitignore
git add lib\core\config\app_config.example.dart
git add API_SETUP_GUIDE.md

echo    - Added .gitignore updates
echo    - Added app_config.example.dart template
echo    - Added API_SETUP_GUIDE.md

echo.
echo [Step 4/5] Adding other safe project files...
echo.
git add lib\core\services\weather_service.dart
git add .

echo    - Updated weather_service.dart with placeholder
echo    - Added all other safe files

echo.
echo [Step 5/5] Current Git status (what will be committed):
echo.
git status
echo.

echo ==========================================
echo  Setup Complete!
echo ==========================================
echo.
echo Your sensitive files are now protected.
echo The following files are EXCLUDED from Git:
echo   - lib\core\config\app_config.dart
echo   - android\app\google-services.json
echo   - ios\Runner\GoogleService-Info.plist
echo.
echo To commit your code, run:
echo   git commit -m "Initial commit - KrishiBondhu AI project"
echo   git push origin main
echo.
echo IMPORTANT: Keep your local app_config.dart file for development!
echo Other developers should copy app_config.example.dart and add their own keys.
echo.

pause
