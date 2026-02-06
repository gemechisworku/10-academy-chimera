#!/bin/bash
# Spec Check Script for Project Chimera
# Verifies that code implementation aligns with specifications

# Don't exit on error - we want to collect all failures
set +e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Function to print results
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $2"
        ((FAILED++))
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

echo "=========================================="
echo "Project Chimera - Spec Check"
echo "=========================================="
echo ""

# Check if specs directory exists
if [ ! -d "specs" ]; then
    echo -e "${RED}ERROR: specs/ directory not found!${NC}"
    exit 1
fi

# Check if technical.md exists
if [ ! -f "specs/technical.md" ]; then
    echo -e "${RED}ERROR: specs/technical.md not found!${NC}"
    exit 1
fi

# Check if functional.md exists
if [ ! -f "specs/functional.md" ]; then
    echo -e "${RED}ERROR: specs/functional.md not found!${NC}"
    exit 1
fi

echo "Checking specification files..."
print_result 0 "Specs directory exists"
print_result 0 "technical.md found"
print_result 0 "functional.md found"
echo ""

# Check for required API endpoints in technical.md
echo "Checking API contract specifications..."

# Check for Detect Trends API (Section 2.2.3)
if grep -q "2.2.3 Detect Trends" specs/technical.md 2>/dev/null; then
    print_result 0 "Detect Trends API contract defined"
else
    echo "Debug: Searching for '2.2.3 Detect Trends' in specs/technical.md"
    grep -i "detect trends" specs/technical.md | head -1 || echo "Debug: Pattern not found"
    print_result 1 "Detect Trends API contract missing"
fi

# Check for Worker API
if grep -q "2.2 Worker API" specs/technical.md 2>/dev/null; then
    print_result 0 "Worker API section found"
else
    print_result 1 "Worker API section missing"
fi

# Check for Planner API
if grep -q "2.1 Planner API" specs/technical.md 2>/dev/null; then
    print_result 0 "Planner API section found"
else
    print_result 1 "Planner API section missing"
fi

# Check for Judge API
if grep -q "2.3 Judge API" specs/technical.md 2>/dev/null; then
    print_result 0 "Judge API section found"
else
    print_result 1 "Judge API section missing"
fi

echo ""

# Check for skills interface definitions
echo "Checking skills interface specifications..."

if [ -f "skills/README.md" ]; then
    print_result 0 "Skills README.md found"
    
    # Check for skill definitions
    if grep -q "skill_transcribe_audio" skills/README.md; then
        print_result 0 "skill_transcribe_audio defined"
    else
        print_warning "skill_transcribe_audio not found in skills/README.md"
    fi
    
    if grep -q "skill_download_youtube" skills/README.md; then
        print_result 0 "skill_download_youtube defined"
    else
        print_warning "skill_download_youtube not found in skills/README.md"
    fi
    
    if grep -q "skill_generate_content" skills/README.md; then
        print_result 0 "skill_generate_content defined"
    else
        print_warning "skill_generate_content not found in skills/README.md"
    fi
else
    print_result 1 "skills/README.md not found"
fi

echo ""

# Check for test files that validate specs
echo "Checking test coverage for specifications..."

if [ -f "tests/test_trend_fetcher.py" ]; then
    print_result 0 "test_trend_fetcher.py exists (validates trend API contract)"
else
    print_result 1 "test_trend_fetcher.py missing"
fi

if [ -f "tests/test_skills_interface.py" ]; then
    print_result 0 "test_skills_interface.py exists (validates skills contracts)"
else
    print_result 1 "test_skills_interface.py missing"
fi

echo ""

# Check for implementation files (these should exist or be planned)
echo "Checking implementation status..."

# Check for worker module
if [ -d "worker" ] || [ -f "worker/__init__.py" ] 2>/dev/null; then
    print_result 0 "worker module exists"
    
    if [ -f "worker/trend_fetcher.py" ]; then
        print_result 0 "worker/trend_fetcher.py implemented"
    else
        print_warning "worker/trend_fetcher.py not yet implemented (expected in TDD)"
    fi
else
    print_warning "worker module not yet created (expected in TDD)"
fi

# Check for skills modules
if [ -d "skills" ]; then
    SKILL_COUNT=$(find skills -name "*.py" -type f | grep -v __pycache__ | wc -l)
    if [ "$SKILL_COUNT" -gt 0 ]; then
        print_result 0 "Skills modules found: $SKILL_COUNT"
    else
        print_warning "No skill implementation files found yet (expected in TDD)"
    fi
else
    print_warning "skills directory structure incomplete"
fi

echo ""

# Check for required dependencies in pyproject.toml
echo "Checking project configuration..."

if [ -f "pyproject.toml" ]; then
    print_result 0 "pyproject.toml exists"
    
    if grep -q "requires-python" pyproject.toml; then
        PYTHON_VERSION=$(grep "requires-python" pyproject.toml | sed 's/.*>=\(.*\)/\1/')
        print_result 0 "Python version requirement specified: >=$PYTHON_VERSION"
    else
        print_result 1 "Python version requirement missing"
    fi
else
    print_result 1 "pyproject.toml missing"
fi

echo ""

# Summary
echo "=========================================="
echo "Spec Check Summary"
echo "=========================================="
echo -e "${GREEN}Passed:${NC} $PASSED"
echo -e "${RED}Failed:${NC} $FAILED"
echo -e "${YELLOW}Warnings:${NC} $WARNINGS"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All critical checks passed!${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠ Some warnings found (may be expected in TDD phase)${NC}"
    fi
    exit 0
else
    echo -e "${RED}✗ Some checks failed. Please review the output above.${NC}"
    exit 1
fi

