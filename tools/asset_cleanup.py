#!/usr/bin/env python3
"""
Asset cleanup tool for identifying unused assets in Godot project
"""

import os
import re
from pathlib import Path
from typing import Set, Dict, List

def find_asset_references() -> Set[str]:
    """Find all asset references in the project"""
    referenced_assets = set()

    # Search in .gd files
    for gd_file in Path(".").rglob("*.gd"):
        try:
            with open(gd_file, 'r', encoding='utf-8') as f:
                content = f.read()

            # Find res://assets/ references
            matches = re.findall(r'res://assets/[^"\s]+', content)
            for match in matches:
                referenced_assets.add(match)

        except Exception as e:
            print(f"Error reading {gd_file}: {e}")

    # Search in .tscn files
    for tscn_file in Path(".").rglob("*.tscn"):
        try:
            with open(tscn_file, 'r', encoding='utf-8') as f:
                content = f.read()

            # Find path="res://assets/..." references
            matches = re.findall(r'path="res://assets/[^"]+"', content)
            for match in matches:
                # Extract just the path
                path = match.split('"')[1]
                referenced_assets.add(path)

        except Exception as e:
            print(f"Error reading {tscn_file}: {e}")

    return referenced_assets

def find_all_assets() -> Dict[str, List[str]]:
    """Find all assets in the project"""
    assets = {}

    assets_dir = Path("assets")
    if not assets_dir.exists():
        return assets

    for asset_file in assets_dir.rglob("*"):
        if asset_file.is_file() and not asset_file.name.endswith('.import'):
            relative_path = str(asset_file.relative_to(Path(".")))
            res_path = f"res://{relative_path}"

            category = asset_file.parent.name
            if category not in assets:
                assets[category] = []
            assets[category].append(res_path)

    return assets

def analyze_unused_assets() -> Dict[str, List[str]]:
    """Analyze which assets are unused"""
    referenced = find_asset_references()
    all_assets = find_all_assets()

    unused = {}

    for category, assets in all_assets.items():
        unused_in_category = []
        for asset in assets:
            if asset not in referenced:
                unused_in_category.append(asset)

        if unused_in_category:
            unused[category] = unused_in_category

    return unused

def generate_godotignore_files(unused_assets: Dict[str, List[str]]):
    """Generate .godotignore files for unused asset categories"""
    for category, assets in unused_assets.items():
        if len(assets) > 10:  # Only create .godotignore for categories with many unused assets
            ignore_file = Path(f"assets/{category}/.godotignore")

            # Get file extensions to ignore
            extensions = set()
            for asset in assets:
                ext = Path(asset).suffix
                if ext:
                    extensions.add(f"*{ext}")

            if extensions:
                ignore_content = "\n".join(sorted(extensions))
                ignore_file.write_text(ignore_content)
                print(f"Created {ignore_file}")

def main():
    """Main analysis function"""
    print("🔍 Analyzing unused assets...")
    print()

    unused = analyze_unused_assets()

    total_unused = sum(len(assets) for assets in unused.values())
    print(f"📊 Found {total_unused} unused assets across {len(unused)} categories")
    print()

    for category, assets in unused.items():
        print(f"📁 {category}: {len(assets)} unused assets")

        # Show first few examples
        for asset in assets[:5]:
            print(f"   - {asset}")

        if len(assets) > 5:
            print(f"   ... and {len(assets) - 5} more")
        print()

    # Generate .godotignore files
    print("📝 Generating .godotignore files...")
    generate_godotignore_files(unused)

    print("💡 Recommendations:")
    print("   1. Review the unused assets list above")
    print("   2. Delete assets you're sure you won't use")
    print("   3. Use .godotignore files to exclude asset categories")
    print("   4. Consider moving unused assets to an 'archive' folder")

if __name__ == "__main__":
    main()
