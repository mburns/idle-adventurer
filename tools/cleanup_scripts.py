#!/usr/bin/env python3
"""
Cleanup script for the scripts/ directory
Identifies and removes redundant files and updates references
"""

import os
import re
from pathlib import Path
from typing import Dict, List, Tuple, Any

def analyze_script_usage() -> Dict[str, Dict[str, Any]]:
    """Analyze which scripts are actually being used"""
    scripts_dir = Path("scripts")

    # Files that are likely redundant
    potentially_redundant: List[str] = [
        "wiki_data_loader.gd",  # Replaced by data_loader.gd
        "dnd_data.gd",          # Replaced by data_loader.gd
        "check_todos.py"        # Utility script, not core game code
    ]

    # Check usage of each potentially redundant file
    usage_report: Dict[str, Dict[str, Any]] = {}

    for file_name in potentially_redundant:
        file_path = scripts_dir / file_name
        if not file_path.exists():
            continue

        usage_report[file_name] = {
            "references": [],
            "can_remove": True
        }

        # Search for references to this file
        for gd_file in scripts_dir.glob("*.gd"):
            try:
                with open(gd_file, 'r', encoding='utf-8') as f:
                    content = f.read()

                # Check for class name references
                class_name = file_name.replace('.gd', '').replace('_', '')
                if class_name in content:
                    usage_report[file_name]["references"].append(str(gd_file))
                    usage_report[file_name]["can_remove"] = False

            except Exception as e:
                print(f"Error reading {gd_file}: {e}")

    return usage_report

def find_unused_files() -> List[str]:
    """Find files that might be unused"""
    scripts_dir = Path("scripts")
    unused_candidates: List[str] = []

    # Check each .gd file for usage
    for gd_file in scripts_dir.glob("*.gd"):
        file_name = gd_file.name
        class_name = file_name.replace('.gd', '').replace('_', '')

        # Skip main game files that are definitely used
        if file_name in [
            "character_manager.gd", "character_creation.gd", "character.gd",
            "data_loader.gd", "main.gd", "start_screen.gd"
        ]:
            continue

        # Check if this class is referenced anywhere
        is_used = False
        for other_file in scripts_dir.glob("*.gd"):
            if other_file == gd_file:
                continue

            try:
                with open(other_file, 'r', encoding='utf-8') as f:
                    content = f.read()

                if class_name in content or file_name in content:
                    is_used = True
                    break

            except Exception as e:
                print(f"Error reading {other_file}: {e}")

        if not is_used:
            unused_candidates.append(file_name)

    return unused_candidates

def check_file_sizes() -> List[Dict[str, Any]]:
    """Check for unusually large files that might need refactoring"""
    scripts_dir = Path("scripts")
    large_files: List[Dict[str, Any]] = []

    for gd_file in scripts_dir.glob("*.gd"):
        try:
            size = gd_file.stat().st_size
            if size > 10000:  # Files larger than 10KB
                with open(gd_file, 'r', encoding='utf-8') as f:
                    lines = len(f.readlines())

                large_files.append({
                    "file": gd_file.name,
                    "size_kb": round(size / 1024, 1),
                    "lines": lines
                })
        except Exception as e:
            print(f"Error checking {gd_file}: {e}")

    return large_files

def main() -> None:
    """Main cleanup analysis"""
    print("🔍 Analyzing scripts/ directory for cleanup opportunities...")
    print()

    # Analyze redundant files
    print("📋 REDUNDANT FILES ANALYSIS:")
    usage_report = analyze_script_usage()

    for file_name, report in usage_report.items():
        if report["can_remove"]:
            print(f"✅ {file_name} - Can be removed (no references found)")
        else:
            print(f"⚠️  {file_name} - Still referenced in:")
            for ref in report["references"]:
                print(f"   - {ref}")
    print()

    # Find unused files
    print("🔍 POTENTIALLY UNUSED FILES:")
    unused = find_unused_files()
    if unused:
        for file_name in unused:
            print(f"❓ {file_name} - No references found")
    else:
        print("✅ All files appear to be in use")
    print()

    # Check file sizes
    print("📏 LARGE FILES (potential refactoring candidates):")
    large_files = check_file_sizes()
    if large_files:
        for file_info in large_files:
            print(f"📄 {file_info['file']} - {file_info['size_kb']}KB, {file_info['lines']} lines")
    else:
        print("✅ No unusually large files found")
    print()

    # Summary
    print("📊 CLEANUP SUMMARY:")
    print(f"   - Redundant files: {len([f for f, r in usage_report.items() if r['can_remove']])}")
    print(f"   - Potentially unused: {len(unused)}")
    print(f"   - Large files: {len(large_files)}")
    print()

    print("💡 RECOMMENDATIONS:")
    print("   1. Remove redundant files (wiki_data_loader.gd, dnd_data.gd)")
    print("   2. Update references to use DataLoader instead")
    print("   3. Consider moving check_todos.py to tools/ directory")
    print("   4. Review large files for potential refactoring")

if __name__ == "__main__":
    main()
