#!/usr/bin/env godot
# Plugin Installation Script for Idle Adventurer
# This script helps install and configure recommended plugins

extends SceneTree

const PLUGINS = {
    "gdUnit4": {
        "url": "https://github.com/MikeSchulze/gdUnit4",
        "path": "addons/gdUnit4",
        "priority": "high",
        "description": "Advanced testing framework"
    },
    "panku_console": {
        "url": "https://github.com/Ark2000/PankuConsole",
        "path": "addons/PankuConsole",
        "priority": "high",
        "description": "Runtime debug console"
    },
    "resources_as_tables": {
        "url": "https://github.com/Ark2000/ResourcesAsTables",
        "path": "addons/ResourcesAsTables",
        "priority": "medium",
        "description": "Data management and CSV import"
    },
    "asset_drawer": {
        "url": "https://github.com/Ark2000/AssetDrawer",
        "path": "addons/AssetDrawer",
        "priority": "medium",
        "description": "Asset management and organization"
    },
    "todo_manager": {
        "url": "https://github.com/Ark2000/TodoManager",
        "path": "addons/TodoManager",
        "priority": "medium",
        "description": "In-editor TODO tracking"
    },
    "godot_steam": {
        "url": "https://github.com/CoaguCo-Industries/GodotSteam",
        "path": "addons/GodotSteam",
        "priority": "high",
        "description": "Steam API integration"
    }
}

func _init():
    print("🎮 Idle Adventurer Plugin Installer")
    print("====================================")
    print()

    check_plugin_status()
    show_installation_menu()

func check_plugin_status():
    print("📋 Plugin Status Check:")
    print("----------------------")

    for plugin_name in PLUGINS:
        var plugin = PLUGINS[plugin_name]
        var plugin_path = plugin.path
        var exists = DirAccess.dir_exists_absolute(plugin_path)
        var status = "✅ Installed" if exists else "❌ Not Installed"
        var priority = "🔥 HIGH" if plugin.priority == "high" else "⚡ MEDIUM" if plugin.priority == "medium" else "📝 LOW"

        print("%s %s - %s" % [status, plugin_name, priority])
        print("   %s" % plugin.description)
        print("   URL: %s" % plugin.url)
        print()

func show_installation_menu():
    print("🛠️ Installation Options:")
    print("1. Install High Priority Plugins (gdUnit4, Panku Console, Godot Steam)")
    print("2. Install Medium Priority Plugins (Resources as Tables, Asset Drawer, TODO Manager)")
    print("3. Install All Plugins")
    print("4. Check Plugin Status")
    print("5. Exit")
    print()

    # In a real implementation, this would be interactive
    # For now, we'll just show the status and exit
    print("💡 To install plugins manually:")
    print("1. Download from the URLs above")
    print("2. Extract to the addons/ directory")
    print("3. Enable in Project Settings > Plugins")
    print("4. Restart Godot")
    print()
    print("📚 See docs/GODOT_FEATURES_AND_PLUGINS.md for detailed instructions")

func install_plugin(plugin_name: String) -> bool:
    var plugin = PLUGINS.get(plugin_name)
    if not plugin:
        print("❌ Unknown plugin: %s" % plugin_name)
        return false

    var plugin_path = plugin.path
    if DirAccess.dir_exists_absolute(plugin_path):
        print("✅ Plugin already installed: %s" % plugin_name)
        return true

    print("📥 Installing %s..." % plugin_name)
    print("   URL: %s" % plugin.url)
    print("   Path: %s" % plugin_path)

    # In a real implementation, this would:
    # 1. Download the plugin from the URL
    # 2. Extract it to the correct path
    # 3. Enable it in project.godot
    # 4. Verify installation

    print("⚠️  Manual installation required - see documentation")
    return false

func enable_plugin(plugin_name: String) -> bool:
    var plugin_path = "addons/%s/plugin.cfg" % plugin_name
    if not FileAccess.file_exists(plugin_path):
        print("❌ Plugin not found: %s" % plugin_path)
        return false

    print("🔌 Enabling plugin: %s" % plugin_name)

    # In a real implementation, this would modify project.godot
    # to enable the plugin

    print("⚠️  Manual enable required - see Project Settings > Plugins")
    return false

func verify_plugin_installation(plugin_name: String) -> bool:
    var plugin = PLUGINS.get(plugin_name)
    if not plugin:
        return false

    var plugin_path = plugin.path
    var plugin_cfg = plugin_path + "/plugin.cfg"

    if not DirAccess.dir_exists_absolute(plugin_path):
        print("❌ Plugin directory not found: %s" % plugin_path)
        return false

    if not FileAccess.file_exists(plugin_cfg):
        print("❌ Plugin config not found: %s" % plugin_cfg)
        return false

    print("✅ Plugin verified: %s" % plugin_name)
    return true
