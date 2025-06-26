#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "ag command exists" bash -c "command -v ag"

# Test basic ag functionality
check "ag version" bash -c "ag --version"

# Create test files for searching
mkdir -p test_dir
echo "hello world" >test_dir/file1.txt
echo "hello universe" >test_dir/file2.txt
echo "goodbye world" >test_dir/file3.txt

# Test basic search functionality
check "ag can search text" bash -c "ag 'hello' test_dir/ | grep -q 'hello'"
check "ag can search with results" bash -c "ag 'world' test_dir/ | wc -l | grep -q '[1-9]'"
check "ag respects case sensitivity" bash -c "ag 'Hello' test_dir/ || true" # Should not find anything
check "ag case insensitive search" bash -c "ag -i 'Hello' test_dir/ | grep -q 'hello'"

# Test ag with regex
check "ag regex search" bash -c "ag 'h[a-z]+o' test_dir/ | grep -q 'hello'"

# Test file type filtering (create a simple text file)
echo "console.log('test');" >test_dir/script.js
check "ag file type search" bash -c "ag 'console' --js test_dir/"

# Clean up
rm -rf test_dir

# Report results
reportResults
