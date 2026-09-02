#!/bin/bash

# Grader script: validates project structure and implementation

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
total_checks=0
passed_checks=0
failed_checks=0

# Helper function for test results
check_item() {
    local description="$1"
    local test_cmd="$2"
    
    ((total_checks++))
    
    if bash -c "$test_cmd" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $description"
        ((passed_checks++))
        return 0
    else
        echo -e "${RED}✗${NC} $description"
        ((failed_checks++))
        return 1
    fi
}

echo "========================================"
echo "  Assignment 3 Grading Script"
echo "========================================"
echo ""

# ========== Section 1: Directory Structure ==========
echo -e "${YELLOW}[1] Project Structure${NC}"
check_item "app/app.sh exists" "test -f app/app.sh"
check_item "scripts/lint.sh exists" "test -f scripts/lint.sh"
check_item "scripts/build.sh exists" "test -f scripts/build.sh"
check_item "tests/test.sh exists" "test -f tests/test.sh"
check_item ".github/workflows/ci.yml exists" "test -f .github/workflows/ci.yml"
check_item "Dockerfile exists" "test -f Dockerfile"
check_item "compose.yaml exists" "test -f compose.yaml"
check_item ".dockerignore exists" "test -f .dockerignore"
check_item "grade.sh exists" "test -f grade.sh"
check_item "README.md exists" "test -f README.md"
echo ""

# ========== Section 2: Executable Permissions ==========
echo -e "${YELLOW}[2] Executable Permissions${NC}"
check_item "app/app.sh is executable" "test -x app/app.sh"
check_item "scripts/lint.sh is executable" "test -x scripts/lint.sh"
check_item "scripts/build.sh is executable" "test -x scripts/build.sh"
check_item "tests/test.sh is executable" "test -x tests/test.sh"
check_item "grade.sh is executable" "test -x grade.sh"
echo ""

# ========== Section 3: Bash Syntax ==========
echo -e "${YELLOW}[3] Bash Script Syntax${NC}"
check_item "app/app.sh has valid syntax" "bash -n app/app.sh"
check_item "scripts/lint.sh has valid syntax" "bash -n scripts/lint.sh"
check_item "scripts/build.sh has valid syntax" "bash -n scripts/build.sh"
check_item "tests/test.sh has valid syntax" "bash -n tests/test.sh"
check_item "grade.sh has valid syntax" "bash -n grade.sh"
echo ""

# ========== Section 4: Application Commands ==========
echo -e "${YELLOW}[4] Application Commands (Functional Tests)${NC}"

# Test help command
if ./app/app.sh help > /tmp/help_output.txt 2>&1; then
    check_item "help command runs and exits with code 0" "true"
    check_item "help output contains 'Usage'" "grep -q 'Usage' /tmp/help_output.txt"
else
    check_item "help command runs and exits with code 0" "false"
fi

# Test system-info command
if ./app/app.sh system-info > /tmp/sysinfo_output.txt 2>&1; then
    check_item "system-info command exits with code 0" "true"
    check_item "system-info contains 'Hostname'" "grep -q 'Hostname' /tmp/sysinfo_output.txt"
else
    check_item "system-info command exits with code 0" "false"
fi

# Test invalid command returns exit code 2
if ./app/app.sh invalid-command > /dev/null 2>&1; then
    check_item "invalid command returns exit code 2" "false"
else
    invalid_exit=$?
    if [[ $invalid_exit -eq 2 ]]; then
        check_item "invalid command returns exit code 2" "true"
    else
        check_item "invalid command returns exit code 2" "false"
    fi
fi

# Test check-host missing argument returns exit code 2
if ./app/app.sh check-host > /dev/null 2>&1; then
    check_item "check-host missing host returns exit code 2" "false"
else
    check_host_missing_exit=$?
    if [[ $check_host_missing_exit -eq 2 ]]; then
        check_item "check-host missing host returns exit code 2" "true"
    else
        check_item "check-host missing host returns exit code 2" "false"
    fi
fi

# Test check-host with localhost returns exit code 0
check_item "check-host localhost returns exit code 0" "./app/app.sh check-host localhost > /dev/null 2>&1"

# Test check-port missing port returns exit code 2
if ./app/app.sh check-port 127.0.0.1 > /dev/null 2>&1; then
    check_item "check-port missing port returns exit code 2" "false"
else
    check_port_missing_exit=$?
    if [[ $check_port_missing_exit -eq 2 ]]; then
        check_item "check-port missing port returns exit code 2" "true"
    else
        check_item "check-port missing port returns exit code 2" "false"
    fi
fi

# Test check-port non-numeric port returns exit code 2
if ./app/app.sh check-port 127.0.0.1 abc > /dev/null 2>&1; then
    check_item "check-port non-numeric port returns exit code 2" "false"
else
    check_port_invalid_exit=$?
    if [[ $check_port_invalid_exit -eq 2 ]]; then
        check_item "check-port non-numeric port returns exit code 2" "true"
    else
        check_item "check-port non-numeric port returns exit code 2" "false"
    fi
fi

# Test check-port out-of-range port (70000) returns exit code 2
if ./app/app.sh check-port 127.0.0.1 70000 > /dev/null 2>&1; then
    check_item "check-port out-of-range port (70000) returns exit code 2" "false"
else
    check_port_range_exit=$?
    if [[ $check_port_range_exit -eq 2 ]]; then
        check_item "check-port out-of-range port (70000) returns exit code 2" "true"
    else
        check_item "check-port out-of-range port (70000) returns exit code 2" "false"
    fi
fi

echo ""

# ========== Section 5: Linting Script ==========
echo -e "${YELLOW}[5] Linting Script${NC}"
if bash scripts/lint.sh > /tmp/lint_output.txt 2>&1; then
    check_item "lint.sh runs successfully" "true"
else
    check_item "lint.sh runs successfully" "false"
fi
echo ""

# ========== Section 6: Test Suite ==========
echo -e "${YELLOW}[6] Test Suite${NC}"
if bash tests/test.sh > /tmp/tests_output.txt 2>&1; then
    check_item "test.sh runs successfully" "true"
    check_item "All tests pass" "grep -q 'All Tests PASSED' /tmp/tests_output.txt"
else
    check_item "test.sh runs successfully" "false"
fi
echo ""

# ========== Section 7: Dockerfile ==========
echo -e "${YELLOW}[7] Dockerfile${NC}"
check_item "Dockerfile has FROM directive" "grep -q '^FROM' Dockerfile"
check_item "Dockerfile installs bash" "grep -qi 'bash' Dockerfile"
check_item "Dockerfile installs networking tools" "grep -E 'iputils|bind-tools|netcat' Dockerfile"
check_item "Dockerfile sets ENTRYPOINT" "grep -q 'ENTRYPOINT' Dockerfile"
check_item "Dockerfile sets CMD" "grep -q 'CMD' Dockerfile"
check_item "Dockerfile copies app.sh" "grep -q '/app/app/app.sh' Dockerfile"
echo ""

# ========== Section 8: Docker Compose ==========
echo -e "${YELLOW}[8] Docker Compose Configuration${NC}"
check_item "compose.yaml is valid" "test -f compose.yaml"
check_item "compose.yaml defines devops-tool service" "grep -q 'devops-tool' compose.yaml"
check_item "compose.yaml has stdin_open setting" "grep -q 'stdin_open' compose.yaml"
check_item "compose.yaml has tty setting" "grep -q 'tty' compose.yaml"
echo ""

# ========== Section 9: .dockerignore ==========
echo -e "${YELLOW}[9] Docker Ignore File${NC}"
check_item ".dockerignore excludes .git" "grep -q '.git' .dockerignore"
check_item ".dockerignore excludes .github" "grep -q '.github' .dockerignore"
check_item ".dockerignore excludes logs" "grep -q 'logs' .dockerignore"
echo ""

# ========== Section 10: GitHub Actions Workflow ==========
echo -e "${YELLOW}[10] GitHub Actions Workflow${NC}"
check_item "workflow file exists" "test -f .github/workflows/ci.yml"
check_item "workflow runs on push" "grep -q 'push:' .github/workflows/ci.yml"
check_item "workflow runs on pull_request" "grep -q 'pull_request:' .github/workflows/ci.yml"
check_item "workflow has validate job" "grep -q 'validate:' .github/workflows/ci.yml"
check_item "workflow has test job" "grep -q 'test:' .github/workflows/ci.yml"
check_item "workflow has docker job" "grep -q 'docker:' .github/workflows/ci.yml"
check_item "test job uses needs: validate" "grep -q 'needs: validate' .github/workflows/ci.yml"
check_item "docker job uses needs: test" "grep -q 'needs: test' .github/workflows/ci.yml"
echo ""

# ========== Section 11: README ==========
echo -e "${YELLOW}[11] Documentation${NC}"
check_item "README.md contains project structure" "grep -q 'assignment-3' README.md"
check_item "README.md documents app.sh commands" "grep -E 'help|system-info|check-host|check-port' README.md"
check_item "README.md documents exit codes" "grep -qi 'exit code' README.md"
check_item "README.md includes Docker section" "grep -qi 'docker' README.md"
check_item "README.md includes GitHub Actions section" "grep -E -i 'github|action|workflow' README.md"
echo ""

# ========== Section 12: Error Handling ==========
echo -e "${YELLOW}[12] Error Handling${NC}"
check_item "app.sh uses set -euo pipefail" "grep -q 'set -euo pipefail' app/app.sh"
check_item "lint.sh uses set -euo pipefail" "grep -q 'set -euo pipefail' scripts/lint.sh"
check_item "app.sh validates arguments" "grep -q 'if.*-z' app/app.sh"
check_item "app.sh validates port range" "grep -E '65535|port.*range' app/app.sh"
echo ""

# ========== Summary ==========
echo "========================================"
echo "  GRADING SUMMARY"
echo "========================================"
echo -e "Total Checks: $total_checks"
echo -e "${GREEN}Passed: $passed_checks${NC}"
echo -e "${RED}Failed: $failed_checks${NC}"
echo ""

if [[ $failed_checks -eq 0 ]]; then
    echo -e "${GREEN}🎉 ALL CHECKS PASSED!${NC}"
    exit 0
else
    echo -e "${RED}⚠️  $failed_checks check(s) failed${NC}"
    exit 1
fi
