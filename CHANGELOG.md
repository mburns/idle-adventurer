# Changelog - Idle Adventurer

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added

- TODO.md and CHANGELOG.md files for project tracking
- Initial analysis of existing codebase and D&D wiki structure
- Complete D&D 5e character system with races, classes, and backgrounds
- Idle mechanics system with skill-based activities
- Character creation screen with full D&D character creation
- Start screen with new character and load character options
- Save/load system for character progress
- Enhanced main game screen with character info and activity progress
- Skill button system connecting UI to idle activities
- SCREEN_FLOW.md documenting all planned screens
- Comprehensive testing framework with unit and integration tests
- Wiki data loader for D&D content from markdown files
- Character profile screen with detailed stats and equipment
- Equipment screen with inventory management
- Journal screen with activity logging and achievements
- Settings screen with game configuration options
- Navigation system connecting all screens
- Open source project files (LICENSE, CONTRIBUTING.md, CODE_OF_CONDUCT.md)
- Comprehensive build system for multiple platforms
- CI/CD pipeline with GitHub Actions
- Linting system for code quality
- Integration tests for full system functionality
- Wiki integration for classes, equipment, treasure, and spells
- Character display screen with visual character representation
- D&D character sheet screen with dice rolling functionality
- Character visualizer system for rendering based on stats and equipment
- Character texture generator for procedural character textures
- Asset pipeline for character sprites and visual assets
- Performance optimizer for game optimization
- Project structure reorganization (scenes/, tests/, assets/ directories)
- Comprehensive test suite with 100% pass rate
- GDScript formatter integrated with pre-commit hooks
- Code quality improvements with automated formatting
- Comprehensive theme system with multiple themes (default, dark, D&D classic, medieval)
- Reusable UI components for consistent styling
- Enhanced settings screen with theme switching and audio controls
- Visual effects and animations for UI elements
- CI/CD pipeline with GitHub Actions
- Makefile for build automation and development tasks
- Automated testing and linting in CI/CD
- Comprehensive equipment system with stat modifications and durability
- Equipment factory for generating D&D items
- Equipment sets and bonuses system
- Faction system with reputation tracking and relationships
- Multiple character support with character selection screen
- Adventuring activities system based on D&D wiki content (crafting, profession, training)
- Currency system with gold tracking and lifestyle expenses
- Comprehensive test coverage for equipment and faction systems
- Spellbook screen for viewing and learning spells from wiki/Spells directory
- Character Journal screen with roleplay notes, campaign tracking, and timeline events
- Racial traits integration from wiki/Meta/Races applied at character creation
- Enhanced character model with spellbook, buffs, racial traits, and spell slots
- Starting equipment assignment based on class and background from wiki
- Comprehensive activities system with 30+ activities across all ability scores
- Activities screen with organized tabs for each ability (Strength, Dexterity, Intelligence, Wisdom, Charisma, Constitution)
- Non-ability specific activities (Travel, Faction Work, Social Events, Rest & Recovery, Shopping, Gambling, Religious Services)
- Activity requirements, costs, rewards, and progress tracking
- Real-time activity processing with daily progress and completion rewards
- Offline progress tracking with time-based rewards and ability score scaling
- Language learning system with 16 D&D languages and permanent unlocks
- Level 20 cap with exponential experience requirements (355,000 XP for max level)
- Class abilities and leveling system with proper progression for all classes
- General Store with 20+ items, search/filter functionality, and rarity system
- Bank system for wealth management with deposit/withdrawal and wealth tiers
- Experience tracking for all ability scores with automatic improvements
- Character progression with hit point increases and class feature unlocks
- Comprehensive inventory system with visual organization and item stacking
- Inventory screen with search, filter, sort, and item management functionality
- Item categories (Weapons, Armor, Consumables, Tools, Adventuring Gear, Treasure, Spell Components)
- Stackable items (potions, ammunition, food) and unique items (weapons, armor, tools)
- Starting equipment integration with class-specific items for all character classes
- Item effects system for consumables, food, and scrolls
- Inventory weight and value tracking with summary display
- Monster Glossary system with comprehensive D&D monster database
- Monster browsing with search, filter, and detailed stat display
- Comprehensive test suite for all major subsystems
- Enhanced test coverage for inventory, activities, language, and leveling systems
- Code optimization and bug fixes for better stability
- Leveling UI system with class feature choices and upgrades
- Enhanced character sheet with class abilities, spell slots, and buff timers
- D&D-compliant currency system with proper coinage denominations
- Comprehensive racial traits system with wiki integration
- Faction quest system with reputation rewards
- Faction benefits and membership system

### Changed

- Updated main.tscn with new character info display and activity progress
- Updated main.gd to use new character system and idle mechanics
- Changed main scene from main.tscn to start_screen.tscn
- Enhanced D&D data system to use wiki markdown files
- Improved test coverage with comprehensive test suite
- Updated build system for automated multi-platform builds
- Reorganized project structure with proper directory hierarchy
- Updated all GDScript files to use consistent 4-space indentation
- Improved code formatting and line length compliance
- Enhanced pre-commit hooks with automatic formatting

### Fixed

- Fixed script syntax errors and class name conflicts
- Fixed autoload singleton configuration issues
- Fixed test runner compilation errors
- Fixed character save/load system issues

### Removed

- None yet

## [0.1.0] - Initial Version

- Basic coin system with manual increment
- Tab-based skill interface with D&D ability scores
- Simple UI with player info box and coin display
- Basic skill activities for each ability score
