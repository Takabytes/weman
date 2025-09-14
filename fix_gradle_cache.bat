@echo off
echo Fixing Gradle cache corruption...

echo Stopping all Java processes...
taskkill /f /im java.exe >nul 2>&1
taskkill /f /im javaw.exe >nul 2>&1

echo Waiting for processes to terminate...
timeout /t 3 /nobreak >nul

echo Removing Gradle cache directories...
if exist "%USERPROFILE%\.gradle\caches" (
    rmdir /s /q "%USERPROFILE%\.gradle\caches" 2>nul
)

if exist "%USERPROFILE%\.gradle\wrapper" (
    rmdir /s /q "%USERPROFILE%\.gradle\wrapper" 2>nul
)

echo Removing project build directories...
if exist "build" rmdir /s /q "build" 2>nul
if exist "vector-app\build" rmdir /s /q "vector-app\build" 2>nul
if exist "matrix-sdk-android\build" rmdir /s /q "matrix-sdk-android\build" 2>nul
if exist "vector\build" rmdir /s /q "vector\build" 2>nul
if exist "vector-config\build" rmdir /s /q "vector-config\build" 2>nul

for /d %%i in (library\*) do (
    if exist "%%i\build" rmdir /s /q "%%i\build" 2>nul
)

echo Cleaning complete. You can now run gradlew clean build
pause
