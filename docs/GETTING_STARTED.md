# Getting Started with Idle Adventurer Development

Welcome to Idle Adventurer! This guide will help you set up your development environment and make your first contribution.

## 🚀 Quick Start

### Prerequisites

- **Godot 4.2+** - Download from [godotengine.org](https://godotengine.org/download/)
- **Git** - For version control
- **VS Code** (recommended) - With Godot Tools extension

### 1. Fork and Clone

```bash
# Fork the repository on GitHub, then clone your fork
git clone https://github.com/YOUR_USERNAME/idle-adventurer.git
cd idle-adventurer

# Add upstream remote
git remote add upstream https://github.com/ORIGINAL_OWNER/idle-adventurer.git
```

### 2. Open in Godot

1. Open Godot Engine
2. Click "Import" and select the `project.godot` file
3. Click "Import & Edit"

### 3. Run the Game

1. Press F5 or click the "Play" button
2. Select `start_screen.tscn` as the main scene
3. The game should start!

## 🛠️ Development Setup

### VS Code Setup

1. Install VS Code
2. Install the "Godot Tools" extension
3. Open the project folder in VS Code
4. The extension will automatically detect Godot

### Running Tests

```bash
# Run all tests
godot --headless --script run_tests.gd --quit

# Run specific test file
godot --headless --script tests/test_character.gd --quit
```

### Code Style

- Use 4 spaces for indentation
- Use `snake_case` for variables and functions
- Use `PascalCase` for classes
- Add comments for complex logic
- Keep lines under 120 characters

## 🎮 Game Architecture

### Core Systems

- **Character System** - D&D character creation and management
- **Idle Mechanics** - Time-based progression
- **Equipment System** - Inventory and gear management
- **Achievement System** - Progress tracking and rewards

### File Structure

```
scripts/
├── character.gd              # Character data and logic
├── character_manager.gd      # Character save/load
├── idle_mechanics.gd         # Activity system
├── dnd_data.gd              # D&D rules and data
└── ui/                      # UI screen scripts

tests/
├── test_character.gd         # Character tests
├── test_idle_mechanics.gd    # Idle system tests
└── test_integration.gd       # Full system tests

resources/
├── character_class_resource.gd  # Class definitions
└── equipment_resource.gd        # Equipment definitions
```

## 🐛 Making Your First Contribution

### 1. Pick an Issue

- Look for issues labeled `good first issue` or `help wanted`
- Comment on the issue to claim it
- Ask questions if anything is unclear!

### 2. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/issue-number-description
```

### 3. Make Changes

- Write your code
- Add tests for new functionality
- Update documentation if needed
- Follow the coding style guide

### 4. Test Your Changes

```bash
# Run tests
godot --headless --script run_tests.gd --quit

# Test the game manually
godot --path . --scene start_screen.tscn
```

### 5. Submit a Pull Request

1. Commit your changes with a clear message
2. Push to your fork
3. Create a pull request
4. Fill out the PR template

## 📚 Learning Resources

### Godot

- [Official Godot Documentation](https://docs.godotengine.org/)
- [Godot Tutorials](https://docs.godotengine.org/en/stable/getting_started/step_by_step/)
- [GDScript Reference](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/)

### D&D 5e

- [D&D 5e SRD](https://dnd.wizards.com/resources/systems-reference-document)
- [Open Game License](https://dnd.wizards.com/resources/systems-reference-document)

### Git

- [Git Handbook](https://guides.github.com/introduction/git-handbook/)
- [GitHub Flow](https://guides.github.com/introduction/flow/)

## 🤝 Getting Help

- **GitHub Issues** - For bugs and feature requests
- **Discussions** - For questions and general chat
- **Discord** - Real-time help (link in README)
- **Code Review** - Ask for help in PR comments

## 🎯 Common Tasks

### Adding a New Activity

1. Add to `IdleMechanics.activities` in `scripts/idle_mechanics.gd`
2. Add button to appropriate skill tab in `main.tscn`
3. Connect button in `scripts/skill_buttons.gd`
4. Write tests in `tests/test_idle_mechanics.gd`

### Adding a New UI Screen

1. Create `.tscn` scene file
2. Create `.gd` script file
3. Add navigation button in `main.tscn`
4. Add navigation method in `main.gd`
5. Write tests for the new screen

### Adding a New D&D Class

1. Create resource file in `resources/`
2. Add to DataLoader in `scripts/data_loader.gd`
3. Update character creation screen
4. Write tests for the new class

## 🚨 Troubleshooting

### Common Issues

- **Godot won't start** - Check Godot version (4.2+ required)
- **Tests fail** - Run `godot --headless --script run_tests.gd --quit` to see errors
- **Git issues** - Check the [Git Handbook](https://guides.github.com/introduction/git-handbook/)

### Getting Help

- Check existing issues and discussions
- Ask in Discord or GitHub Discussions
- Create a new issue with detailed information

Happy coding! 🎮
