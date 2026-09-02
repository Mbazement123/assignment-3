#!/bin/bash
set -euo pipefail

# Build script: builds Docker image and performs smoke tests

echo "=== Building Docker Image ==="
echo ""

# Build the image
if docker build -t devops-tool . > /tmp/docker_build.log 2>&1; then
    echo "✓ Docker image built successfully: devops-tool"
else
    echo "✗ Docker image build failed"
    cat /tmp/docker_build.log
    exit 1
fi

echo ""
echo "=== Running Docker Smoke Tests ==="
echo ""

errors=0

# Test 1: help command
echo "Test 1: docker run --rm devops-tool help"
if docker run --rm devops-tool help &> /tmp/test_help.log; then
    echo "✓ help command executed successfully"
    grep -q "Usage:" /tmp/test_help.log && echo "  - Contains usage information"
else
    echo "✗ help command failed"
    ((errors++))
fi

echo ""

# Test 2: system-info command
echo "Test 2: docker run --rm devops-tool system-info"
if docker run --rm devops-tool system-info &> /tmp/test_sysinfo.log; then
    echo "✓ system-info command executed successfully"
    grep -q "Hostname:" /tmp/test_sysinfo.log && echo "  - Contains hostname info"
else
    echo "✗ system-info command failed"
    ((errors++))
fi

echo ""

# Test 3: check-host with localhost
echo "Test 3: docker run --rm devops-tool check-host localhost"
if docker run --rm devops-tool check-host localhost &> /tmp/test_host.log; then
    echo "✓ check-host command executed successfully"
else
    echo "⚠ check-host may have failed (possible network isolation in container)"
    # Don't count this as a hard error since containers may have limited network access
fi

echo ""

# Test 4: invalid command handling (should return exit code 2)
echo "Test 4: docker run --rm devops-tool invalid-command (should fail with exit code 2)"
if docker run --rm devops-tool invalid-command &> /tmp/test_invalid.log; then
    echo "✗ invalid command did not return non-zero exit code"
    ((errors++))
else
    exit_code=$?
    if [[ $exit_code -eq 2 ]]; then
        echo "✓ invalid command returned exit code 2 (as expected)"
    else
        echo "✗ invalid command returned exit code $exit_code (expected 2)"
        ((errors++))
    fi
fi

echo ""

# Test 5: check-port with missing port argument (should return exit code 2)
echo "Test 5: docker run --rm devops-tool check-port localhost (missing port, should return exit code 2)"
if docker run --rm devops-tool check-port localhost &> /tmp/test_missing_port.log; then
    echo "✗ missing port did not return non-zero exit code"
    ((errors++))
else
    exit_code=$?
    if [[ $exit_code -eq 2 ]]; then
        echo "✓ missing port returned exit code 2 (as expected)"
    else
        echo "✗ missing port returned exit code $exit_code (expected 2)"
        ((errors++))
    fi
fi

echo ""
if [[ $errors -eq 0 ]]; then
    echo "=== All Smoke Tests PASSED ==="
    exit 0
else
    echo "=== Some Smoke Tests FAILED ($errors errors) ==="
    exit 1
fi
