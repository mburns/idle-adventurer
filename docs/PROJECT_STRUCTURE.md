# Project Structure Reorganization

## Current Issues

- Too many top-level files (20+ .tscn, .gd files)
- Mixed file types at root level
- No clear organization for different file types

## Proposed Structure

```
idle-adventurer/
├── README.md
├── LICENSE
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── TODO.md
├── CHANGELOG.md
├── project.godot
├── export_presets.cfg
├── icon.svg
├── icon.svg.import
├── Makefile
├── Dockerfile
├── docker-compose.yml
├── .pre-commit-config.yaml
├── .github/
│   └── workflows/
│       └── ci.yml
├── .vscode/
│   ├── settings.json
│   └── extensions.json
├── docs/
│   ├── GETTING_STARTED.md
│   ├── PROJECT_STRUCTURE.md
│   └── GODOT_FEATURES_AND_PLUGINS.md
├── scenes/
│   ├── main/
│   │   ├── main.tscn
│   │   ├── main.gd
│   │   └── start_screen.tscn
│   ├── character/
│   │   ├── character_creation.tscn
│   │   ├── character_profile.tscn
│   │   ├── character_display.tscn
│   │   └── character_sheet.tscn
│   ├── gameplay/
│   │   ├── equipment_screen.tscn
│   │   ├── journal_screen.tscn
│   │   └── settings_screen.tscn
│   └── login/
│       └── login.tscn
├── scripts/
│   ├── core/
│   │   ├── character.gd
│   │   ├── character_manager.gd
│   │   ├── idle_mechanics.gd
│   │   ├── dnd_data.gd
│   │   └── game_events.gd
│   ├── ui/
│   │   ├── start_screen.gd
│   │   ├── character_creation.gd
│   │   ├── character_profile.gd
│   │   ├── character_display.gd
│   │   ├── character_sheet.gd
│   │   ├── equipment_screen.gd
│   │   ├── journal_screen.gd
│   │   └── settings_screen.gd
│   ├── systems/
│   │   ├── animation_manager.gd
│   │   ├── character_visualizer.gd
│   │   ├── character_texture_generator.gd
│   │   ├── wiki_data_loader.gd
│   │   └── skill_buttons.gd
│   ├── tools/
│   │   ├── build_system.gd
│   │   ├── lint.gd
│   │   ├── install_plugins.gd
│   │   └── check_todos.py
│   └── autoload/
│       └── autoload_manager.gd
├── resources/
│   ├── character_class_resource.gd
│   ├── equipment_resource.gd
│   ├── spell_resource.gd
│   └── themes/
│       └── new_theme.tres
├── assets/
│   ├── fonts/
│   │   └── Grundschrift-Normal.otf
│   ├── icons/
│   │   └── [all SVG icons]
│   ├── images/
│   │   ├── class_symbols/
│   │   ├── faction_symbols/
│   │   ├── rulebooks/
│   │   └── wallpapers/
│   └── archive/
│       └── [archived files]
├── tests/
│   ├── unit/
│   │   ├── test_character.gd
│   │   ├── test_character_manager.gd
│   │   ├── test_dnd_data.gd
│   │   ├── test_idle_mechanics.gd
│   │   └── test_wiki_data_loader.gd
│   ├── integration/
│   │   ├── test_integration.gd
│   │   └── test_equipment_system.gd
│   ├── test_base.gd
│   ├── test_runner.gd
│   ├── test_runner.tscn
│   └── run_tests.gd
├── addons/
│   ├── gut/
│   │   └── gut.gd
│   └── plugin_manifest.gd
└── wiki/
    ├── Classes/
    ├── Equipment/
    ├── Gameplay/
    ├── Meta/
    ├── Monsters/
    ├── Races/
    ├── Spells/
    └── Treasure/
```

## Migration Plan

### Phase 1: Create New Directories

1. Create `scenes/` directory structure
2. Create `scripts/core/`, `scripts/ui/`, `scripts/systems/`, `scripts/tools/`, `scripts/autoload/`
3. Create `tests/unit/` and `tests/integration/`
4. Create `assets/fonts/`, `assets/images/` subdirectories

### Phase 2: Move Files

1. Move all `.tscn` files to appropriate `scenes/` subdirectories
2. Move scripts to appropriate `scripts/` subdirectories
3. Move test files to appropriate `tests/` subdirectories
4. Move asset files to appropriate `assets/` subdirectories

### Phase 3: Update References

1. Update all script paths in scene files
2. Update import paths in scripts
3. Update test runner paths
4. Update build system paths

### Phase 4: Clean Up

1. Remove old file locations
2. Update documentation
3. Update CI/CD paths
4. Test all functionality

## Benefits

- **Clear Organization**: Related files grouped together
- **Easier Navigation**: Developers can find files quickly
- **Scalability**: Easy to add new features without cluttering root
- **Professional Structure**: Follows industry best practices
- **Better Testing**: Clear separation of unit vs integration tests
