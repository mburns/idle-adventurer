# Plugin Manifest for Idle Adventurer
# This file tracks recommended and integrated plugins

class_name PluginManifest
extends RefCounted

# Core Development Plugins
const CORE_PLUGINS = {
    "gdUnit4": {
        "name": "gdUnit4",
        "description": "Advanced testing framework for Godot 4",
        "url": "https://github.com/MikeSchulze/gdUnit4",
        "priority": "high",
        "category": "testing",
        "status": "pending"
    },
    "panku_console": {
        "name": "Panku Console",
        "description": "In-game debug console for runtime debugging",
        "url": "https://github.com/Ark2000/PankuConsole",
        "priority": "high",
        "category": "debugging",
        "status": "pending"
    },
    "resources_as_tables": {
        "name": "Resources as Tables 2",
        "description": "Data management and CSV import for game data",
        "url": "https://github.com/Ark2000/ResourcesAsTables",
        "priority": "medium",
        "category": "data_management",
        "status": "pending"
    }
}

# UI and UX Plugins
const UI_PLUGINS = {
    "better_terrain": {
        "name": "Better Terrain",
        "description": "Advanced terrain generation and editing",
        "url": "https://github.com/Arnklit/WaterGen_Godot",
        "priority": "low",
        "category": "terrain",
        "status": "not_needed"
    },
    "asset_drawer": {
        "name": "Asset Drawer",
        "description": "Asset management and organization",
        "url": "https://github.com/Ark2000/AssetDrawer",
        "priority": "medium",
        "category": "asset_management",
        "status": "pending"
    },
    "snappy": {
        "name": "Snappy",
        "description": "UI snapping and alignment tools",
        "url": "https://github.com/Ark2000/Snappy",
        "priority": "low",
        "category": "ui_tools",
        "status": "pending"
    }
}

# Physics and Gameplay Plugins
const GAMEPLAY_PLUGINS = {
    "rapier_2d": {
        "name": "Rapier 2D",
        "description": "High-performance 2D physics engine",
        "url": "https://github.com/dimforge/rapier",
        "priority": "low",
        "category": "physics",
        "status": "not_needed"
    },
    "softbody_2d": {
        "name": "SoftBody2D",
        "description": "Soft body physics for 2D",
        "url": "https://github.com/godotengine/godot",
        "priority": "low",
        "category": "physics",
        "status": "not_needed"
    }
}

# Project Management Plugins
const PROJECT_PLUGINS = {
    "todo_manager": {
        "name": "TODO Manager",
        "description": "In-editor TODO tracking and management",
        "url": "https://github.com/Ark2000/TodoManager",
        "priority": "medium",
        "category": "project_management",
        "status": "pending"
    },
    "godot_steam": {
        "name": "Godot Steam",
        "description": "Steam API integration for achievements and multiplayer",
        "url": "https://github.com/CoaguCo-Industries/GodotSteam",
        "priority": "high",
        "category": "platform_integration",
        "status": "pending"
    }
}

# Get all plugins by category
static func get_plugins_by_category(category: String) -> Dictionary:
    var all_plugins = {}
    all_plugins.merge(CORE_PLUGINS)
    all_plugins.merge(UI_PLUGINS)
    all_plugins.merge(GAMEPLAY_PLUGINS)
    all_plugins.merge(PROJECT_PLUGINS)

    var filtered = {}
    for key in all_plugins:
        if all_plugins[key].category == category:
            filtered[key] = all_plugins[key]
    return filtered

# Get high priority plugins
static func get_high_priority_plugins() -> Array:
    var all_plugins = {}
    all_plugins.merge(CORE_PLUGINS)
    all_plugins.merge(UI_PLUGINS)
    all_plugins.merge(GAMEPLAY_PLUGINS)
    all_plugins.merge(PROJECT_PLUGINS)

    var high_priority = []
    for key in all_plugins:
        if all_plugins[key].priority == "high":
            high_priority.append(all_plugins[key])
    return high_priority

# Get plugins by status
static func get_plugins_by_status(status: String) -> Array:
    var all_plugins = {}
    all_plugins.merge(CORE_PLUGINS)
    all_plugins.merge(UI_PLUGINS)
    all_plugins.merge(GAMEPLAY_PLUGINS)
    all_plugins.merge(PROJECT_PLUGINS)

    var filtered = []
    for key in all_plugins:
        if all_plugins[key].status == status:
            filtered.append(all_plugins[key])
    return filtered
