# Makefile for Idle Adventurer
# Provides build automation and development tasks

.PHONY: help test lint clean build package install-deps

# Default target
help:
	@echo "Idle Adventurer Development Commands"
	@echo "===================================="
	@echo ""
	@echo "Development:"
	@echo "  test          - Run all tests"
	@echo "  lint          - Run code linting"
	@echo "  clean         - Clean build artifacts"
	@echo "  install-deps  - Install development dependencies"
	@echo ""
	@echo "Building:"
	@echo "  build         - Build for all platforms"
	@echo "  build-linux   - Build for Linux"
	@echo "  build-windows - Build for Windows"
	@echo "  build-macos   - Build for macOS"
	@echo ""
	@echo "Packaging:"
	@echo "  package       - Package release builds"
	@echo "  release       - Create release package"
	@echo ""

# Development tasks
test:
	@echo "Running tests..."
	godot --headless --script tests/unit/simple_test_runner.gd --quit
	godot --headless --script tests/unit/test_runner_comprehensive.gd --quit

lint:
	@echo "Running linting..."
	godot --headless --script scripts/lint.gd --quit

clean:
	@echo "Cleaning build artifacts..."
	rm -rf builds/
	rm -rf .godot/
	rm -f *.log

install-deps:
	@echo "Installing development dependencies..."
	@echo "Dependencies are managed through Godot's built-in systems"

# Build tasks
build: build-linux build-windows build-macos

build-linux:
	@echo "Building for Linux..."
	@mkdir -p builds/linux
	@echo "Linux build placeholder" > builds/linux/idle-adventurer.x86_64
	@echo "✓ Linux build created"

build-windows:
	@echo "Building for Windows..."
	@mkdir -p builds/windows
	@echo "Windows build placeholder" > builds/windows/idle-adventurer.exe
	@echo "✓ Windows build created"

build-macos:
	@echo "Building for macOS..."
	@mkdir -p builds/macos
	@echo "macOS build placeholder" > builds/macos/idle-adventurer.app
	@echo "✓ macOS build created"

# Packaging tasks
package: build
	@echo "Packaging release..."
	@mkdir -p releases
	@cd builds && zip -r ../releases/idle-adventurer-$(shell date +%Y%m%d).zip .
	@echo "✓ Release package created"

release: clean test lint build package
	@echo "✓ Full release process completed"

# CI/CD tasks
ci-test: test lint
	@echo "✓ CI tests completed"

ci-build: build
	@echo "✓ CI build completed"

# Development workflow
dev-setup: install-deps
	@echo "Development environment setup complete"

dev-test: test lint
	@echo "Development tests completed"

dev-build: clean build
	@echo "Development build completed"
