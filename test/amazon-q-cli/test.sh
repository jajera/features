#!/bin/bash
set -e

# Import test library
source dev-container-features-test-lib

# Basic checks - check multiple possible locations
check "q command exists" bash -c 'command -v q || test -f /usr/local/bin/q || test -f ~/.local/bin/q'

# Test that q command actually works - try different locations if needed
if command -v q >/dev/null 2>&1; then
    check "q command works" q --version
elif test -f /usr/local/bin/q; then
    check "q command works" /usr/local/bin/q --version
elif test -f ~/.local/bin/q; then
    check "q command works" ~/.local/bin/q --version
else
    echo "❌ No q command found in any expected location"
    exit 1
fi

# Bash completion: check if installed and sourced
# Check for system-wide completion first
if test -f /etc/bash_completion.d/q; then
    if test -f /etc/bash.bashrc && grep -q "source /etc/bash_completion.d/q" /etc/bash.bashrc; then
        check "bash completion is sourced" echo "System-wide bash completion is properly configured"
    else
        echo "⚠️ System-wide bash completion file exists but not properly sourced"
    fi
# Check for user-specific completion
elif test -f ~/.bash_completion.d/q; then
    if test -f ~/.bashrc && grep -q "source.*\.bash_completion\.d/q" ~/.bashrc; then
        check "bash completion is sourced" echo "User-specific bash completion is properly configured"
    else
        echo "⚠️ User-specific bash completion file exists but not properly sourced"
    fi
else
    echo "⚠️ Bash completion not found at /etc/bash_completion.d/q or ~/.bash_completion.d/q — skipping related check."
fi

# Report results
reportResults
