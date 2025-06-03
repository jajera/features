#!/bin/bash
set -e

# Import test library
source dev-container-features-test-lib

# Basic checks
check "q command exists" command -v q
check "q command works" q --version

# Bash completion: check if installed and sourced
if test -f /etc/bash_completion.d/q; then
    check "bash completion is sourced" grep -q "source /etc/bash_completion.d/q" /etc/bash.bashrc
else
    echo "⚠️ Bash completion not found at /etc/bash_completion.d/q — skipping related check."
fi

# Report results
reportResults
