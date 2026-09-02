#!/bin/bash

# Test suite for the Bash application

APP="./app/app.sh"
test_count=0
passed=0
failed=0

# Colors for output (optional, for readability)
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Test helper function
run_test() {
    local test_num=$1
    local test_name=$2
    local cmd=$3
    local expected_exit=$4
    
    ((test_count++))
    echo ""
    echo "Test $test_num: $test_name"
    echo "  Command: $cmd"
    
    # Run the command and capture output and exit code properly
    output=""
    exit_code=0
    output=$(bash -c "$cmd" 2>&1) || exit_code=$?
    
    if [[ $exit_code -eq $expected_exit ]]; then
        echo -e "  Result: ${GREEN}PASSED${NC} (exit code: $exit_code)"
        ((passed++))
    else
        echo -e "  Result: ${RED}FAILED${NC} (exit code: $exit_code, expected: $expected_exit)"
        ((failed++))
    fi
    
    # Print output if non-empty and it's a helpful command
    if [[ -n "$output" ]] && [[ $exit_code -ne 0 || "$test_name" =~ "help" || "$test_name" =~ "system" ]]; then
        echo "  Output:"
        printf '%s\n' "$output" | sed 's/^/    /'
    fi
}

echo "=== Running Test Suite ==="
echo "App: $APP"

# Ensure the app is executable
chmod +x "$APP" 2>/dev/null || true

# Test 1: help output and exit code 0
run_test 1 "help command returns exit code 0 and shows usage" "$APP help" 0

# Test 2: system-info output and exit code 0
run_test 2 "system-info command returns exit code 0" "$APP system-info" 0

# Test 3: invalid command handling (expects exit code 2)
run_test 3 "invalid command returns exit code 2" "$APP invalid-cmd" 2

# Test 4: check-host missing host argument (expects exit code 2)
run_test 4 "check-host missing argument returns exit code 2" "$APP check-host" 2

# Test 5: check-host valid host (localhost, expects exit code 0)
run_test 5 "check-host with localhost returns exit code 0" "$APP check-host localhost" 0

# Test 6: check-port missing port argument (expects exit code 2)
run_test 6 "check-port missing port argument returns exit code 2" "$APP check-port 127.0.0.1" 2

# Test 7: check-port non-numeric port (expects exit code 2)
run_test 7 "check-port with non-numeric port returns exit code 2" "$APP check-port 127.0.0.1 abc" 2

# Test 8: check-port out-of-range port (expects exit code 2)
run_test 8 "check-port with out-of-range port (70000) returns exit code 2" "$APP check-port 127.0.0.1 70000" 2

# Test 9 (bonus): check-port with port 0 (expects exit code 2)
run_test 9 "check-port with port 0 returns exit code 2" "$APP check-port 127.0.0.1 0" 2

# Test 10 (bonus): no command provided (expects exit code 2)
run_test 10 "no command provided returns exit code 2" "$APP" 2

# Test 11 (bonus): check-host with missing argument flag style
run_test 11 "check-host with IP but connection test" "$APP check-host 127.0.0.1" 0

# Test 12 (bonus): check-port with an unused local port
unused_port=49152
while timeout 1 bash -c "</dev/tcp/127.0.0.1/$unused_port" 2>/dev/null; do
    ((unused_port++))
done
run_test 12 "check-port with an unused localhost port" "$APP check-port 127.0.0.1 $unused_port" 1

echo ""
echo "=== Test Summary ==="
echo "Total Tests: $test_count"
echo -e "${GREEN}Passed: $passed${NC}"
echo -e "${RED}Failed: $failed${NC}"
echo ""

if [[ $failed -eq 0 ]]; then
    echo "=== All Tests PASSED ==="
    exit 0
else
    echo "=== Some Tests FAILED ==="
    exit 1
fi
