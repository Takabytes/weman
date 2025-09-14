# Clean build script for Weman project
# Resolves incremental build issues by performing a full clean

Write-Host "Cleaning Weman project..." -ForegroundColor Green

# Remove all build directories
Write-Host "Removing build directories..." -ForegroundColor Yellow
Get-ChildItem -Path . -Name "*build*" -Directory -Recurse | ForEach-Object { 
    Remove-Item -Recurse -Force -Path $_ -ErrorAction SilentlyContinue 
    Write-Host "  Removed: $_" -ForegroundColor Gray
}

# Remove gradle cache
Write-Host "Removing gradle cache..." -ForegroundColor Yellow
Remove-Item -Recurse -Force -Path ".gradle" -ErrorAction SilentlyContinue

Write-Host "Clean completed! You can now build the project." -ForegroundColor Green
Write-Host "Run: .\gradlew.bat assembleDebug" -ForegroundColor Cyan
