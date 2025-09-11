#!/usr/bin/env python3
"""
Targeted cleanup for clearly redundant files
"""

import os
from pathlib import Path

def safe_remove_redundant_files():
    """Remove clearly redundant files that have been replaced"""
    scripts_dir = Path("scripts")

    # Files that are definitely redundant and safe to remove
    redundant_files = [
        "wiki_data_loader.gd",  # Replaced by data_loader.gd
        "dnd_data.gd",          # Replaced by data_loader.gd
        "check_todos.py"        # Utility script, not core game code
    ]

    removed_files = []

    for file_name in redundant_files:
        file_path = scripts_dir / file_name
        if file_path.exists():
            try:
                # Double-check it's not referenced in project.godot
                project_file = Path("project.godot")
                if project_file.exists():
                    with open(project_file, 'r', encoding='utf-8') as f:
                        project_content = f.read()

                    if file_name in project_content:
                        print(f"⚠️  Skipping {file_name} - referenced in project.godot")
                        continue

                # Remove the file
                file_path.unlink()
                removed_files.append(file_name)
                print(f"✅ Removed {file_name}")

            except Exception as e:
                print(f"❌ Error removing {file_name}: {e}")

    return removed_files

def create_tools_directory():
    """Create tools directory and move utility scripts there"""
    tools_dir = Path("tools")
    tools_dir.mkdir(exist_ok=True)

    # Move utility scripts to tools directory
    utility_scripts = [
        "cleanup_scripts.py",
        "targeted_cleanup.py"
    ]

    moved_files = []
    for script_name in utility_scripts:
        script_path = Path("scripts") / script_name
        if script_path.exists():
            try:
                new_path = tools_dir / script_name
                script_path.rename(new_path)
                moved_files.append(script_name)
                print(f"✅ Moved {script_name} to tools/")
            except Exception as e:
                print(f"❌ Error moving {script_name}: {e}")

    return moved_files

def main():
    """Perform targeted cleanup"""
    print("🧹 Performing targeted cleanup...")
    print()

    # Remove redundant files
    print("🗑️  REMOVING REDUNDANT FILES:")
    removed = safe_remove_redundant_files()
    print()

    # Create tools directory
    print("📁 ORGANIZING UTILITY SCRIPTS:")
    moved = create_tools_directory()
    print()

    # Summary
    print("📊 CLEANUP COMPLETE:")
    print(f"   - Files removed: {len(removed)}")
    print(f"   - Files moved to tools/: {len(moved)}")

    if removed:
        print("\n✅ Removed redundant files:")
        for file_name in removed:
            print(f"   - {file_name}")

    if moved:
        print("\n📁 Moved utility scripts to tools/:")
        for file_name in moved:
            print(f"   - {file_name}")

if __name__ == "__main__":
    main()
