@echo off
cd /d d:\Knrishubondhu-Ai-Companion

echo ==========================================
echo  Committing Everything to GitHub
echo ==========================================
echo.

echo Step 1: Adding all files...
git add -A

echo.
echo Step 2: Committing changes...
git commit -m "Update KrishiBondhu AI project - remove sensitive API keys"

echo.
echo Step 3: Pushing to GitHub (force overwrite)...
git push origin master --force

echo.
echo ==========================================
echo  Done! All changes pushed to GitHub
echo ==========================================
echo.
echo Your repository: https://github.com/sillyfellow21/Knrishubondhu-Ai-Companion
echo.
echo REMEMBER: Restore your API keys locally from MY_API_KEYS_BACKUP.txt
echo.
pause
