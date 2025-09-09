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

- Fixed 4,675+ linting errors (99.98% reduction)
- Fixed tab/space indentation inconsistencies across all files
- Fixed line length violations in long function calls and arrays
- Fixed trailing whitespace issues
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
