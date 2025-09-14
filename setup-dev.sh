#!/bin/bash
# Development environment setup script for Idle Adventurer

set -e

echo "🚀 Setting up Idle Adventurer development environment..."
echo ""

# Check if Godot is installed
if ! command -v godot &> /dev/null; then
    echo "❌ Godot not found. Please install Godot 4.2+ from https://godotengine.org/"
    echo "   After installation, make sure 'godot' is in your PATH"
    exit 1
fi

echo "✅ Godot found: $(godot --version)"

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 not found. Please install Python 3.7+"
    exit 1
fi

echo "✅ Python found: $(python3 --version)"

# Install Python dependencies
echo "📦 Installing Python dependencies..."
python3 -m pip install -r requirements.txt
echo "✅ Python dependencies installed"

# Check if we're in the right directory
if [ ! -f "project.godot" ]; then
    echo "❌ project.godot not found. Please run this script from the project root."
    exit 1
fi

echo "✅ Project structure verified"

# Run environment check
echo "🔍 Running environment check..."
make check-env

echo ""
echo "🎉 Development environment setup complete!"
echo ""
echo "Next steps:"
echo "  1. Open the project in Godot: godot --path ."
echo "  2. Run tests: make test"
echo "  3. Check the README.md for more information"
echo ""
echo "Happy coding! 🎮"
