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

# Validate YAML files with yamllint
echo "🔍 Validating YAML files with yamllint..."
if command -v yamllint >/dev/null 2>&1; then
	if yamllint -c .yamllint data/; then
		echo "✅ All YAML files validated with yamllint"
	else
		echo "❌ YAML validation failed"
		exit 1
	fi
else
	echo "⚠️  yamllint not found, falling back to basic validation"
	yaml_count=$(find data/ -name "*.yaml" | wc -l)
	echo "Found $yaml_count YAML files"

	# Collect all YAML files
	yaml_files=()
	while IFS= read -r -d '' file; do
		yaml_files+=("$file")
	done < <(find data/ -name "*.yaml" -print0)

	# Validate all files at once
	if ! python3 tools/validate_yaml.py "${yaml_files[@]}"; then
		failed_files=1
	else
		failed_files=0
	fi

	if [ $failed_files -gt 0 ]; then
		echo "❌ $failed_files YAML files failed validation"
		exit 1
	else
		echo "✅ All YAML files validated"
	fi
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
