#!/usr/bin/env python3
import os
import re

def update_resource_manager(file_path):
    """Update a resource manager to use data_loader"""
    try:
        with open(file_path, 'r') as f:
            content = f.read()

        # Check if it already has data_loader
        if 'var data_loader: ResourceDataLoader' in content:
            print(f"Skipping {file_path} - already has data_loader")
            return False

        # Replace the old approach with new approach
        old_pattern = r'# Converter and loader instances\s*var converter: YAMLToResourceConverter\s*var yaml_parser: YAMLParser'
        new_replacement = '''# Resource data loader
var data_loader: ResourceDataLoader'''

        content = re.sub(old_pattern, new_replacement, content, flags=re.MULTILINE | re.DOTALL)

        # Update _ready method
        old_ready = r'func _ready\(\) -> void:\s*converter = YAMLToResourceConverter\.new\(\)\s*yaml_parser = YAMLParser\.new\(\)\s*load_all_\w+\(\)'
        new_ready = '''func _ready() -> void:
	# Use global data loader if available
	if Engine.has_singleton("AutoloadManager"):
		var autoload_manager = Engine.get_singleton("AutoloadManager")
		if autoload_manager and autoload_manager.data_loader:
			data_loader = autoload_manager.data_loader
		else:
			data_loader = ResourceDataLoader.new()
			add_child(data_loader)
	else:
		data_loader = ResourceDataLoader.new()
		add_child(data_loader)

	load_all_\w+()

func _init():
	# Initialize data loader early for immediate use
	data_loader = ResourceDataLoader.new()'''

        content = re.sub(old_ready, new_ready, content, flags=re.MULTILINE | re.DOTALL)

        with open(file_path, 'w') as f:
            f.write(content)

        return True
    except Exception as e:
        print(f"Error updating {file_path}: {e}")
        return False

def main():
    # Update remaining resource managers
    managers = [
        'scripts/systems/achievement_resource_manager.gd',
        'scripts/systems/name_resource_manager.gd',
        'scripts/systems/level_requirement_resource_manager.gd'
    ]

    updated = 0
    for manager in managers:
        if os.path.exists(manager):
            if update_resource_manager(manager):
                updated += 1
                print(f"Updated: {manager}")

    print(f"Updated {updated} resource managers")

if __name__ == "__main__":
    main()
