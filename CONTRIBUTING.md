# Contributing to Idle Adventurer

Thank you for your interest in contributing to Idle Adventurer! This document provides guidelines for contributing to the project.

## Getting Started

1. Fork the repository
2. Clone your fork locally
3. Create a new branch for your feature or bugfix
4. Make your changes
5. Add tests for your changes
6. Run the test suite
7. Submit a pull request

## Development Setup

### Prerequisites
- Godot 4.2 or later
- Git

### Running Tests
```bash
# Run tests headlessly
godot --headless --script run_tests.gd --quit

# Run tests with UI
godot --path . --scene test_runner.tscn
```

### Building the Game
```bash
# Build for all platforms
godot --headless --script build.gd build

# Build for specific platform
godot --headless --script build.gd build linux
```

## Code Style

- Use 4 spaces for indentation
- Use snake_case for variables and functions
- Use PascalCase for classes
- Add comments for complex logic
- Follow Godot naming conventions

## Testing

- Write tests for all new features
- Ensure all tests pass before submitting PR
- Add integration tests for UI components
- Test on multiple platforms when possible

## Pull Request Process

1. Ensure your code follows the style guidelines
2. Add tests for new functionality
3. Update documentation as needed
4. Ensure all tests pass
5. Submit a pull request with a clear description

## Reporting Bugs

When reporting bugs, please include:
- Godot version
- Operating system
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable

## Feature Requests

When requesting features, please:
- Check existing issues first
- Provide a clear description
- Explain the use case
- Consider implementation complexity

## License

By contributing to Idle Adventurer, you agree that your contributions will be licensed under the MIT License.
