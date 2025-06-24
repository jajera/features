#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "zip command exists" bash -c "command -v zip"
check "unzip command exists" bash -c "command -v unzip"

# Test basic zip functionality
check "zip can create archive" bash -c "echo 'test content' > test.txt && zip test.zip test.txt && ls test.zip"
check "unzip can extract archive" bash -c "rm test.txt && unzip test.zip && cat test.txt | grep 'test content'"
check "zip version" bash -c "zip --version"
check "unzip version" bash -c "unzip -v"

# Clean up
rm -f test.txt test.zip

# Report results
reportResults
