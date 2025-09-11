# Changelog - Idle Adventurer

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added

- **Bug Fix Test Suite**: Comprehensive test coverage for all bug fixes

  - Tests for lambda capture fixes
  - Tests for missing function errors
  - Tests for property access issues
  - Tests for division by zero prevention
  - Tests for node reference corrections
  - Tests for file operation error handling
  - Tests for array bounds safety
  - Tests for signal connection safety

- **Bug Fix Documentation**: Detailed documentation of fixes and prevention strategies

  - Created `docs/BUG_FIXES.md` with comprehensive bug tracking
  - Documented root causes and solutions for each issue
  - Added best practices for preventing similar issues
  - Included code examples of fixes

- **CharacterManager Comprehensive Testing**: Complete test suite for CharacterManager functionality

  - Tests for character creation, saving/loading, equipment assignment
  - Tests for race bonuses, class features, and background traits
  - Tests for inventory system integration and signal handling
  - Tests for edge cases and error handling
  - Performance tests for character operations

- **Code Quality Improvements**: Enhanced type safety and code organization
  - Comprehensive type hints added to CharacterManager
  - Dead code removal and cleanup of outdated references
  - Consistent use of DataLoader throughout the project

### Fixed

- **Lambda Capture Issues**: Resolved "Lambda capture at index 0 was freed" errors

  - Fixed button hover effects in `start_screen.gd` using WeakRef approach
  - Fixed button connections in `skill_buttons.gd` with safe lambda usage
  - Fixed tween callbacks in `animation_manager.gd` with helper functions

- **Missing Function Errors**: Added missing functions that were being called

  - Added `ThemeManager.apply_theme_to_children()` function
  - Added `DataLoader.load_json_data()` function for generic JSON loading

- **Property Access Issues**: Fixed "Invalid call. Nonexistent function 'get'" errors

  - Replaced generic `character.get()` calls with explicit property access
  - Fixed race bonus application in `character_manager.gd`
  - Fixed spell slots and buffs access in `character_sheet.gd` and `leveling_screen.gd`

- **Division by Zero**: Added safety checks for mathematical operations

  - Fixed experience bar calculation in `leveling_screen.gd`
  - Added null checks before division operations

- **Node Reference Issues**: Corrected incorrect node references
  - Fixed `%NameLineEdit` to `%CharacterNameInput` in character creation
  - Ensured all node references match actual scene node names

### Changed

- **Data Loading System**: Migrated from legacy WikiDataLoader and DnDData to unified DataLoader
  - Updated all test files to use DataLoader instead of deprecated classes
  - Updated UI screens to use DataLoader for consistent data access
  - Removed references to non-existent classes in documentation

### Removed

- **Dead Code Cleanup**: Removed obsolete files and references
  - Deleted test files for non-existent WikiDataLoader and DnDData classes
  - Removed duplicate cleanup scripts from scripts/ directory
  - Cleaned up outdated references in documentation

### Fixed

- **CharacterManager Dependencies**: Fixed missing dependency issues
  - Resolved "CharacterManager not available yet" error
  - Updated all data loading calls to use existing DataLoader autoload
  - Fixed parameter naming to resolve linter warnings

### Added

- **Enhanced Data Structure**: Individual JSON files for all game data

  - Classes: 12 individual class files with complete spell lists and features
  - Races: 9 individual race files with racial traits and abilities
  - Spells: 319 individual spell files with full descriptions and mechanics
  - Equipment: 7 category files with 175+ items including weapons, armor, and gear
  - Backgrounds: 12 individual background files with features and equipment
  - Feats: 1 feat file with prerequisites and benefits
  - Alignments: 9 alignment files with morality and attitude descriptions
  - Conditions: 15 condition files with effects and descriptions

- **Comprehensive Test Suite**: Enhanced testing framework

  - Comprehensive test runner with detailed reporting
  - Performance tests for memory usage and loading times
  - Integration tests for full game flow
  - 100% test pass rate maintained

- **Improved Documentation**: Professional README and project documentation

  - Complete feature overview with badges and status indicators
  - Quick start guide with installation instructions
  - Project structure documentation
  - Contributing guidelines and development workflow
  - Support and community information

- **Data Extraction System**: Automated data extraction from D&D SRD
  - Python scripts for extracting data from markdown files
  - Automatic JSON generation with proper formatting
  - Data validation and consistency checks
  - Support for all D&D 5e content types

### Changed

- **Data Organization**: Restructured data into individual files for better maintainability
- **JSON Formatting**: Improved JSON structure with proper indentation and line breaks
- **Test Coverage**: Enhanced test suite with comprehensive coverage
- **Code Quality**: Removed redundant code and optimized file structure
- **Documentation**: Updated README with professional open source project standards

### Fixed

- **Data Consistency**: Fixed markdown artifacts in JSON files
- **File Structure**: Cleaned up redundant and duplicate files
- **JSON Parsing**: Fixed JSON formatting issues and validation errors
- **Test Reliability**: Improved test stability and error handling

### Removed

- **Redundant Files**: Removed old consolidated data files
- **Duplicate Scripts**: Cleaned up old extraction scripts
- **Empty Directories**: Removed unused directory structures

## [0.2.0] - Data Structure Overhaul

### Added

- **Individual Data Files**: Each class, race, spell, and item now has its own JSON file
- **Enhanced Spell System**: Complete spell parsing with level-based organization
- **Equipment Categories**: Organized equipment into weapons, armor, and gear
- **Data Validation**: Comprehensive data validation and consistency checks
- **Automated Extraction**: Python scripts for extracting data from wiki markdown files

### Changed

- **Data Loading**: Updated data loader to work with individual files
- **File Organization**: Restructured data directory with subdirectories
- **JSON Structure**: Improved JSON formatting and organization
- **Test Coverage**: Enhanced test suite for new data structure

## [0.1.0] - Initial Version

### Added

- **Quest System**: Comprehensive quest system with storylines, objectives, and meaningful rewards
  - Quest templates for different types (faction, profession, social, personal, community)
  - Quest objectives with progress tracking
  - Quest rewards including reputation, gold, and experience
  - Quest requirements and availability based on character progression
- **NPC System**: NPCs, companions, and social relationship mechanics
  - 10+ NPCs with different types (merchant, craftsman, scholar, noble, guard, priest, entertainer, informant, mentor, companion)
  - Social interaction system with relationship tracking
  - NPC schedules and availability
  - Social events and gatherings
- **Town System**: Town locations and local services
  - 10+ town locations (market square, taverns, guild halls, temple, library, smithy, town hall, guard barracks, noble district, residential)
  - Location-based services with costs and requirements
  - Town events and activities
  - Location access based on reputation and requirements
- **Profession System**: Profession activities with income and reputation
  - 10+ professions across different types (artisan, merchant, scholar, guard, priest, entertainer, healer, informant, administrator, servant)
  - Daily work with income and reputation gains
  - Professional advancement and benefits
  - Work quality based on character stats
- **Lifestyle System**: Lifestyle expenses and living standards
  - 7 lifestyle levels from Wretched to Aristocratic
  - Daily expense tracking and sustainability
  - Lifestyle benefits and penalties
  - Social status and reputation effects
- **Random Events System**: Random encounters and dynamic events
  - 20+ random events across different types (social, economic, mystical, criminal, political, natural, professional, personal, community, adventure hooks)
  - Event rarity system with weighted selection
  - Skill checks and consequences
  - Event cooldowns and history tracking
- **Enhanced Documentation**: Updated screen flow and project documentation
- **Comprehensive Testing**: Unit tests for all new systems

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
