#!/usr/bin/env python3
"""
Check for TODO comments in code and ensure they're properly formatted.
This helps maintain code quality and track outstanding work.
"""

import os
import re
import sys
from pathlib import Path

def find_todos(file_path):
    """Find TODO comments in a file."""
    todos = []
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            for line_num, line in enumerate(f, 1):
                # Look for TODO, FIXME, HACK, NOTE comments
                todo_match = re.search(r'#\s*(TODO|FIXME|HACK|NOTE):\s*(.+)', line, re.IGNORECASE)
                if todo_match:
                    todo_type = todo_match.group(1).upper()
                    description = todo_match.group(2).strip()
                    todos.append({
                        'file': file_path,
                        'line': line_num,
                        'type': todo_type,
                        'description': description
                    })
    except Exception as e:
        print(f"Error reading {file_path}: {e}")

    return todos

def check_todo_format(todo):
    """Check if TODO is properly formatted."""
    issues = []

    # Check if description is not empty
    if not todo['description']:
        issues.append("Empty description")

    # Check if description starts with capital letter
    if todo['description'] and not todo['description'][0].isupper():
        issues.append("Description should start with capital letter")

    # Check if description ends with period
    if todo['description'] and not todo['description'].endswith('.'):
        issues.append("Description should end with period")

    return issues

def main():
    """Main function."""
    project_root = Path(__file__).parent.parent
    todo_files = []

    # Find all .gd and .md files
    for file_path in project_root.rglob('*.gd'):
        if 'test' not in str(file_path):  # Skip test files for now
            todo_files.append(file_path)

    for file_path in project_root.rglob('*.md'):
        todo_files.append(file_path)

    all_todos = []
    for file_path in todo_files:
        todos = find_todos(file_path)
        all_todos.extend(todos)

    if not all_todos:
        print("No TODO comments found.")
        return 0

    print(f"Found {len(all_todos)} TODO comments:")
    print()

    issues_found = False
    for todo in all_todos:
        format_issues = check_todo_format(todo)
        if format_issues:
            issues_found = True
            print(f"❌ {todo['file']}:{todo['line']} - {todo['type']}: {todo['description']}")
            for issue in format_issues:
                print(f"   - {issue}")
        else:
            print(f"✅ {todo['file']}:{todo['line']} - {todo['type']}: {todo['description']}")

    if issues_found:
        print("\nSome TODO comments need formatting improvements.")
        print("Format: # TODO: Description starts with capital and ends with period.")
        return 1
    else:
        print("\nAll TODO comments are properly formatted!")
        return 0

if __name__ == '__main__':
    sys.exit(main())
