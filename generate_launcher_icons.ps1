# PowerShell script to generate Android launcher icons from weman-logo.svg
# This script will attempt to use available tools to convert SVG to PNG

$svgPath = "weman-logo.svg"
$baseResPath = "vector-app\src\main\res"

# Define required icon sizes
$iconSizes = @{
    "mipmap-mdpi" = 48
    "mipmap-hdpi" = 72
    "mipmap-xhdpi" = 96
    "mipmap-xxhdpi" = 144
    "mipmap-xxxhdpi" = 192
}

Write-Host "Converting $svgPath to Android launcher icons..." -ForegroundColor Green

if (-not (Test-Path $svgPath)) {
    Write-Host "Error: $svgPath not found!" -ForegroundColor Red
    exit 1
}

# Check if Inkscape is available
$inkscapeCmd = Get-Command inkscape -ErrorAction SilentlyContinue
if ($inkscapeCmd) {
    Write-Host "Using Inkscape for conversion..." -ForegroundColor Yellow
    
    foreach ($density in $iconSizes.Keys) {
        $size = $iconSizes[$density]
        $outputDir = Join-Path $baseResPath $density
        
        # Create directory if it doesn't exist
        if (-not (Test-Path $outputDir)) {
            New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
        }
        
        $outputFile = Join-Path $outputDir "ic_launcher.png"
        
        # Convert using Inkscape
        $args = @(
            "--export-type=png",
            "--export-filename=$outputFile",
            "--export-width=$size",
            "--export-height=$size",
            $svgPath
        )
        
        try {
            Start-Process -FilePath "inkscape" -ArgumentList $args -Wait -NoNewWindow
            if (Test-Path $outputFile) {
                Write-Host "✓ Generated $outputFile" -ForegroundColor Green
                
                # Copy to round version
                $roundOutputFile = Join-Path $outputDir "ic_launcher_round.png"
                Copy-Item $outputFile $roundOutputFile
                Write-Host "✓ Generated $roundOutputFile" -ForegroundColor Green
            }
        }
        catch {
            Write-Host "✗ Failed to generate $outputFile" -ForegroundColor Red
        }
    }
}
else {
    Write-Host "Inkscape not found. Checking for other options..." -ForegroundColor Yellow
    
    # Check for ImageMagick
    $magickCmd = Get-Command magick -ErrorAction SilentlyContinue
    if ($magickCmd) {
        Write-Host "Using ImageMagick for conversion..." -ForegroundColor Yellow
        
        foreach ($density in $iconSizes.Keys) {
            $size = $iconSizes[$density]
            $outputDir = Join-Path $baseResPath $density
            
            if (-not (Test-Path $outputDir)) {
                New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
            }
            
            $outputFile = Join-Path $outputDir "ic_launcher.png"
            
            try {
                & magick $svgPath -resize "${size}x${size}" $outputFile
                if (Test-Path $outputFile) {
                    Write-Host "✓ Generated $outputFile" -ForegroundColor Green
                    
                    $roundOutputFile = Join-Path $outputDir "ic_launcher_round.png"
                    Copy-Item $outputFile $roundOutputFile
                    Write-Host "✓ Generated $roundOutputFile" -ForegroundColor Green
                }
            }
            catch {
                Write-Host "✗ Failed to generate $outputFile" -ForegroundColor Red
            }
        }
    }
    else {
        Write-Host "No suitable SVG conversion tool found." -ForegroundColor Red
        Write-Host "Please install one of the following:" -ForegroundColor Yellow
        Write-Host "- Inkscape: https://inkscape.org/release/" -ForegroundColor Yellow
        Write-Host "- ImageMagick: https://imagemagick.org/script/download.php#windows" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Required icon sizes:" -ForegroundColor Yellow
        foreach ($density in $iconSizes.Keys) {
            $size = $iconSizes[$density]
            Write-Host "  $density/ic_launcher.png: ${size}x${size} pixels" -ForegroundColor Yellow
        }
        exit 1
    }
}

Write-Host ""
Write-Host "✓ Launcher icon generation completed!" -ForegroundColor Green
Write-Host "Next: Update colors.xml and test the app" -ForegroundColor Yellow
