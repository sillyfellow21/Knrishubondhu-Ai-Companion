@echo off
cd /d d:\Knrishubondhu-Ai-Companion

echo ==========================================
echo  Committing All Changes to Git
echo ==========================================
echo.

echo Step 1: Adding all changes...
git add -A

echo.
echo Step 2: Checking status...
git status

echo.
echo Step 3: Committing with message...
git commit -m "v1.0.2: Integrate Perenual Plant API as primary source with detailed cultivation guides"

echo.
echo Step 4: Pushing to GitHub...
git push origin master

echo.
echo ==========================================
echo  Commit Complete!
echo ==========================================
echo.
echo Repository: https://github.com/sillyfellow21/Knrishubondhu-Ai-Companion
echo.

pause
