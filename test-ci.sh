#!/bin/bash
# Test script to simulate CI environment locally

set -e

echo "🧪 Testing CI environment locally..."
echo ""

# Check environment
echo "📋 Environment Check:"
echo "  - OS: $(uname -s)"
echo "  - Python: $(python3 --version 2>/dev/null || echo 'Not found')"
echo "  - Godot: $(godot --version 2>/dev/null || echo 'Not found')"
echo ""

# Check if we're in the right directory
if [ ! -f "project.godot" ]; then
    echo "❌ project.godot not found. Please run from project root."
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
if [ -f "requirements.txt" ]; then
    python3 -m pip install -r requirements.txt
    echo "✅ Python dependencies installed"
else
    echo "⚠️  requirements.txt not found"
fi

# Check data directory structure
echo "📁 Checking data directory structure..."
if [ ! -d "data" ]; then
    echo "❌ data directory not found"
    exit 1
fi

required_dirs=("data/classes" "data/races" "data/backgrounds" "data/spells" "data/items" "data/activities")
for dir in "${required_dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo "✅ $dir"
    else
        echo "❌ $dir"
    fi
done

# Check key files
echo "📄 Checking key files..."
required_files=("data/currency.yaml" "data/languages.yaml" "data/level_requirements.yaml")
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file"
    fi
done

# Validate YAML files
echo "🔍 Validating YAML files..."
yaml_count=$(find data/ -name "*.yaml" | wc -l)
echo "Found $yaml_count YAML files"

failed_files=0
for file in $(find data/ -name "*.yaml"); do
    if python3 -c "
import yaml
try:
    with open('$file', 'r') as f:
        yaml.safe_load(f)
    print('✓ $file')
except Exception as e:
    print('✗ $file: $e')
    exit(1)
" 2>/dev/null; then
        echo "✅ $file"
    else
        echo "❌ $file"
        failed_files=$((failed_files + 1))
    fi
done

if [ $failed_files -gt 0 ]; then
    echo "❌ $failed_files YAML files failed validation"
    exit 1
else
    echo "✅ All YAML files validated"
fi

# Check scripts directory
echo "📜 Checking scripts directory..."
if [ -d "scripts" ]; then
    echo "✅ scripts directory found"
    script_count=$(find scripts -name "*.gd" | wc -l)
    echo "Found $script_count GDScript files"
else
    echo "❌ scripts directory not found"
fi

# Check tests directory
echo "🧪 Checking tests directory..."
if [ -d "tests" ]; then
    echo "✅ tests directory found"
    test_count=$(find tests -name "*.gd" | wc -l)
    echo "Found $test_count test files"
else
    echo "❌ tests directory not found"
fi

# Run environment check
echo "🔧 Running make check-env..."
if make check-env; then
    echo "✅ Environment check passed"
else
    echo "❌ Environment check failed"
    exit 1
fi

echo ""
echo "🎉 CI simulation completed successfully!"
echo "Your local environment appears to be ready for CI."
