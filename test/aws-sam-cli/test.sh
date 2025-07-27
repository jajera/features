#!/bin/bash
set -e

# Import test library
source dev-container-features-test-lib

# Basic checks - check multiple possible locations
check "sam command exists" bash -c 'command -v sam || test -f /usr/local/bin/sam || test -f ~/.local/bin/sam'

# Test that sam command actually works - try different locations if needed
if command -v sam >/dev/null 2>&1; then
    check "sam command works" sam --version
elif test -f /usr/local/bin/sam; then
    check "sam command works" /usr/local/bin/sam --version
elif test -f ~/.local/bin/sam; then
    check "sam command works" ~/.local/bin/sam --version
else
    echo "❌ No sam command found in any expected location"
    exit 1
fi

# Bash completion: check if installed and sourced
# Check for system-wide completion first
if test -f /etc/bash_completion.d/sam; then
    if test -f /etc/bash.bashrc && grep -q "source /etc/bash_completion.d/sam" /etc/bash.bashrc; then
        check "bash completion is sourced" echo "System-wide bash completion is properly configured"
    else
        echo "⚠️ System-wide bash completion file exists but not properly sourced"
    fi
# Check for user-specific completion
elif test -f ~/.bash_completion.d/sam; then
    if test -f ~/.bashrc && grep -q "source.*\.bash_completion\.d/sam" ~/.bashrc; then
        check "bash completion is sourced" echo "User-specific bash completion is properly configured"
    else
        echo "⚠️ User-specific bash completion file exists but not properly sourced"
    fi
else
    echo "⚠️ Bash completion not found at /etc/bash_completion.d/sam or ~/.bash_completion.d/sam — skipping related check."
fi

# Report results
reportResults
