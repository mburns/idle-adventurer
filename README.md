# Idle Adventurer

[![Build Status](https://github.com/mburns/idle-adventurer/workflows/CI/badge.svg)](https://github.com/mburns/idle-adventurer/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Godot Version](https://img.shields.io/badge/Godot-4.2-blue.svg)](https://godotengine.org/)
[![D&D 5e](https://img.shields.io/badge/D&D-5e-red.svg)](https://dnd.wizards.com/)

An idle D&D 5e RPG where characters progress between adventures through activities like studying, crafting, and training. Built with Godot 4.2 and following official D&D 5e rules.

## 🎮 Features

### Core Gameplay

- **Complete D&D 5e Character System**: All races, classes, backgrounds, and spells from the SRD
- **Idle Progression**: Characters continue to grow and develop while you're away
- **Comprehensive Activities**: 30+ activities across all ability scores and professions
- **Equipment System**: Full D&D equipment with stat modifications and durability
- **Faction System**: Reputation tracking and faction relationships
- **Quest System**: Dynamic quests with meaningful rewards and progression

### Character Management

- **Character Creation**: Full D&D 5e character creation with visual customization
- **Character Sheet**: Interactive character sheet with dice rolling for actual D&D play
- **Inventory Management**: Comprehensive inventory with search, filter, and organization
- **Spellbook**: Complete spell system with learning and casting mechanics
- **Journal System**: Activity logging, achievements, and campaign tracking

### Game Systems

- **Leveling System**: D&D-compliant leveling with class features and ability improvements
- **Currency System**: Gold tracking with lifestyle expenses and wealth management
- **Language Learning**: 16 D&D languages with permanent unlocks
- **Monster Glossary**: Comprehensive D&D monster database for reference
- **Town System**: Multiple locations with services and activities

## 🚀 Quick Start

### Prerequisites

- Godot 4.2 or later
- Git

### Installation

```bash
# Clone the repository
git clone https://github.com/mburns/idle-adventurer.git
cd idle-adventurer

# Set up development environment (recommended)
./setup-dev.sh

# Or manually:
# Install Python dependencies
pip3 install -r requirements.txt

# Open in Godot
# File -> Open Project -> Select project.godot
```

## 🏗️ Project Structure

```
idle-adventurer/
├── scenes/                 # Godot scene files
│   ├── character_creation.tscn
│   ├── main.tscn
│   └── ...
├── scripts/               # GDScript source code
│   ├── character.gd
│   ├── character_manager.gd
│   └── ...
├── data/                  # Game data (JSON)
│   ├── classes/           # Individual class files
│   ├── races/             # Individual race files
│   ├── spells/            # Individual spell files
│   └── items/             # Equipment and items
├── tests/                 # Test suite
│   ├── unit/              # Unit tests
│   └── integration/       # Integration tests
├── assets/                # Game assets
│   ├── icons/             # UI icons
│   ├── music/             # Audio files
│   └── images/            # Visual assets
├── wiki/                  # D&D SRD content
│   ├── Classes/           # Class definitions
│   ├── Races/             # Race definitions
│   ├── Spells/            # Spell definitions
│   └── Equipment/         # Equipment definitions
└── docs/                  # Documentation
    ├── GETTING_STARTED.md
    ├── PROJECT_STRUCTURE.md
    └── SCREEN_FLOW.md
```

## 🧪 Testing

The project includes a comprehensive test suite with 100% pass rate:

```bash
# Check development environment
make check-env

# Run all tests
make test

# Run specific test categories
make test-unit
make test-integration

# Run tests in Godot
# Open test_runner.tscn and run
```

## 🛠️ Development

### Building

```bash
# Build for all platforms
make build

# Build for specific platform
make build-linux
make build-windows
make build-macos
```

### Code Quality

```bash
# Format code
make format

# Lint code
make lint

# Run all quality checks
make check
```

### Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`make test`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## 📊 Data Sources

The game uses data extracted from the D&D 5e SRD (System Reference Document):

- **Classes**: 12 classes with complete spell lists and features
- **Races**: 9 races with racial traits and abilities
- **Spells**: 319 spells with full descriptions and mechanics
- **Equipment**: 175+ items including weapons, armor, and gear
- **Monsters**: 318+ monsters with complete stat blocks
- **Treasure**: 239+ magic items and treasure

All data is automatically extracted from markdown files in the `wiki/` directory and converted to structured JSON for game use.

## 🎯 Roadmap

### Phase 1: Core Systems ✅

- [x] Character creation and progression
- [x] Idle mechanics and activities
- [x] Equipment and inventory systems
- [x] Save/load functionality

### Phase 2: Enhanced Gameplay ✅

- [x] Quest system with dynamic objectives
- [x] NPC system with social relationships
- [x] Town system with multiple locations
- [x] Profession system with income and reputation

### Phase 3: Advanced Features 🚧

- [ ] Mobile support and touch controls
- [ ] Multiplayer support for shared adventures
- [ ] Mod support and community content
- [ ] Advanced graphics and effects

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) and [Code of Conduct](CODE_OF_CONDUCT.md).

### Areas for Contribution

- New activities and professions
- Additional character customization options
- UI/UX improvements
- Performance optimizations
- Documentation improvements
- Bug fixes and testing

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **D&D 5e SRD**: Game mechanics and content from Wizards of the Coast
- **Godot Engine**: Open source game engine
- **Game Icons**: UI icons from [game-icons.net](https://game-icons.net/)
- **D&D SRD Remastered**: Markdown conversion by [Old Man Umby](http://www.oldmanumby.com)

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/mburns/idle-adventurer/issues)
- **Discussions**: [GitHub Discussions](https://github.com/mburns/idle-adventurer/discussions)
- **Wiki**: [Project Wiki](https://github.com/mburns/idle-adventurer/wiki)

---

**Made with ❤️ for the D&D community**
