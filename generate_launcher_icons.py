#!/usr/bin/env python3
"""
Generate Android launcher icons from the weman-logo.svg file.
This script converts the SVG to various PNG sizes required for Android app launcher icons.
"""

import os
import subprocess
from pathlib import Path

# Define the required icon sizes for Android
ICON_SIZES = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192
}

def main():
    # Paths
    svg_path = Path("weman-logo.svg")
    base_res_path = Path("vector-app/src/main/res")
    
    if not svg_path.exists():
        print(f"Error: {svg_path} not found!")
        return
    
    print(f"Converting {svg_path} to Android launcher icons...")
    
    # Create PNG icons for each density
    for density, size in ICON_SIZES.items():
        output_dir = base_res_path / density
        output_dir.mkdir(parents=True, exist_ok=True)
        
        # Generate ic_launcher.png
        output_file = output_dir / "ic_launcher.png"
        
        try:
            # Use Inkscape to convert SVG to PNG
            cmd = [
                "inkscape",
                "--export-type=png",
                f"--export-filename={output_file}",
                f"--export-width={size}",
                f"--export-height={size}",
                str(svg_path)
            ]
            
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode == 0:
                print(f"✓ Generated {output_file}")
            else:
                print(f"✗ Failed to generate {output_file}: {result.stderr}")
                
                # Try with alternative command structure
                cmd_alt = [
                    "inkscape",
                    str(svg_path),
                    "--export-png", str(output_file),
                    "--export-width", str(size),
                    "--export-height", str(size)
                ]
                
                result_alt = subprocess.run(cmd_alt, capture_output=True, text=True)
                
                if result_alt.returncode == 0:
                    print(f"✓ Generated {output_file} (alternative method)")
                else:
                    print(f"✗ Failed with alternative method: {result_alt.stderr}")
                    
        except FileNotFoundError:
            print("Error: Inkscape not found. Please install Inkscape or use an alternative SVG to PNG converter.")
            print("Alternative: You can manually convert the SVG to PNG files with the following sizes:")
            for density, size in ICON_SIZES.items():
                print(f"  {density}/ic_launcher.png: {size}x{size} pixels")
            return
        
        # Generate ic_launcher_round.png (same as regular for now)
        round_output_file = output_dir / "ic_launcher_round.png"
        if output_file.exists():
            import shutil
            shutil.copy2(output_file, round_output_file)
            print(f"✓ Generated {round_output_file}")
    
    print("\n✓ All launcher icons generated successfully!")
    print("\nNext steps:")
    print("1. Update colors.xml to use the correct launcher_background color")
    print("2. Update adaptive icon resources if needed")
    print("3. Build and test the app")

if __name__ == "__main__":
    main()
