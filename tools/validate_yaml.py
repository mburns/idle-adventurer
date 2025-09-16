#!/usr/bin/env python3
"""
YAML validation script for CI
Validates YAML files and reports syntax errors
"""

import sys
import yaml
from pathlib import Path

def validate_yaml_file(file_path: str) -> bool:
    """Validate a single YAML file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            yaml.safe_load(f)
        print(f"✅ {file_path}")
        return True
    except yaml.YAMLError as e:
        print(f"❌ {file_path}: YAML syntax error - {e}")
        return False
    except Exception as e:
        print(f"❌ {file_path}: Error reading file - {e}")
        return False

def main():
    """Main validation function"""
    if len(sys.argv) < 2:
        print("Usage: python3 validate_yaml.py <file1> [file2] ...")
        sys.exit(1)

    failed_files = 0

    for file_path in sys.argv[1:]:
        if not Path(file_path).exists():
            print(f"❌ {file_path}: File not found")
            failed_files += 1
            continue

        if not validate_yaml_file(file_path):
            failed_files += 1

    if failed_files > 0:
        print(f"\n❌ {failed_files} files failed validation")
        sys.exit(1)
    else:
        print(f"\n✅ All {len(sys.argv) - 1} files validated successfully")
        sys.exit(0)

if __name__ == "__main__":
    main()
