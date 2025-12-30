@echo off
REM Auto-detect branch and push to GitHub
cd /d d:\Knrishubondhu-Ai-Companion\Knrishubondhu-Ai-Companion

echo.
echo Detecting current branch...
echo.

REM Get current branch name
for /f "tokens=*" %%i in ('git rev-parse --abbrev-ref HEAD') do set BRANCH=%%i

echo Current branch: %BRANCH%
echo Remote URL: https://github.com/sillyfellow21/Knrishubondhu-Ai-Companion.git
echo.
echo Pushing to origin/%BRANCH%...
echo.

git push origin %BRANCH%

if %errorlevel%==0 (
    echo.
    echo ==========================================
    echo  SUCCESS! Code pushed to GitHub
    echo ==========================================
    echo.
    echo Your code is now on GitHub at:
    echo https://github.com/sillyfellow21/Knrishubondhu-Ai-Companion
    echo.
) else (
    echo.
    echo ==========================================
    echo  Push failed!
    echo ==========================================
    echo.
    echo Common solutions:
    echo 1. Make sure you've committed your changes first
    echo 2. Check your GitHub credentials
    echo 3. Verify the remote URL with: git remote -v
    echo.
)

pause
