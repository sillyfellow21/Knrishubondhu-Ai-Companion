@echo off
REM Quick commit script after preparing the repository
cd /d d:\Knrishubondhu-Ai-Companion\Knrishubondhu-Ai-Companion

echo.
echo Enter your commit message (or press Enter for default):
set /p commit_msg="Commit message: "

if "%commit_msg%"=="" (
    set commit_msg=Initial commit - KrishiBondhu AI project without sensitive data
)

echo.
echo Committing with message: %commit_msg%
echo.

git commit -m "%commit_msg%"

echo.
echo Commit complete! To push to remote, run:
echo   git push origin main
echo.
echo Or run:
echo   git push origin master
echo.

pause
