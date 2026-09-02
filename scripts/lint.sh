#!/bin/bash
set -euo pipefail

# Linting script: checks project structure and syntax

echo "=== Linting Project ==="
echo ""

# Track errors
errors=0

# Check required files and directories exist
echo "Checking required files and directories..."
required_files=(
    "app/app.sh"
    "scripts/lint.sh"
    "scripts/build.sh"
    "tests/test.sh"
    "Dockerfile"
    "compose.yaml"
    ".dockerignore"
    "grade.sh"
    "README.md"
)

for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "✓ $file"
    else
        echo "✗ $file (MISSING)"
        ((errors++))
    fi
done

echo ""
echo "Checking bash syntax on all .sh files..."

# Find and check all .sh files
for sh_file in $(find . -name "*.sh" -type f 2>/dev/null); do
    if bash -n "$sh_file" 2>&1; then
        echo "✓ $sh_file"
    else
        echo "✗ $sh_file (SYNTAX ERROR)"
        ((errors++))
    fi
done

echo ""

# Run shellcheck if available
if command -v shellcheck &> /dev/null; then
    echo "Running shellcheck..."
    shellcheck_errors=0
    for sh_file in $(find . -name "*.sh" -type f 2>/dev/null); do
        if ! shellcheck "$sh_file" 2>&1; then
            ((shellcheck_errors++))
        fi
    done
    
    if [[ $shellcheck_errors -eq 0 ]]; then
        echo "✓ No shellcheck issues found"
    else
        echo "✗ shellcheck found issues"
        ((errors++))
    fi
else
    echo "⚠ shellcheck not installed (optional check skipped)"
fi

echo ""
if [[ $errors -eq 0 ]]; then
    echo "=== Lint Check PASSED ==="
    exit 0
else
    echo "=== Lint Check FAILED ($errors errors) ==="
    exit 1
fi
