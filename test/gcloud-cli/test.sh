#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests - simple existence checks
check "gcloud command exists" bash -c "command -v gcloud"
check "gsutil command exists" bash -c "command -v gsutil"
check "bq command exists" bash -c "command -v bq"

# Test basic version commands (these are fast and don't hang)
check "gcloud version" bash -c "gcloud version --format=text"
check "gsutil version" bash -c "gsutil version"
check "bq version" bash -c "bq version"

# Test basic functionality without hanging
check "gcloud config works" bash -c "gcloud config list --format=text"
check "gcloud auth works" bash -c "gcloud auth list --format=text"

# Check if completion files are installed
if test -f /etc/bash_completion.d/gcloud; then
    check "bash completion installed system-wide" echo "Bash completion found at /etc/bash_completion.d/gcloud"
elif test -f ~/.bash_completion.d/gcloud; then
    check "bash completion installed user-specific" echo "Bash completion found at ~/.bash_completion.d/gcloud"
else
    echo "⚠️ Bash completion not found at expected locations — skipping related check."
fi

# Check if zsh completion is configured
if test -f ~/.zshrc && grep -q "source.*gcloud" ~/.zshrc; then
    check "zsh completion configured" echo "Zsh completion is configured in ~/.zshrc"
elif test -f /etc/zsh/zshrc && grep -q "source.*gcloud" /etc/zsh/zshrc; then
    check "zsh completion configured system-wide" echo "Zsh completion is configured in /etc/zsh/zshrc"
else
    echo "⚠️ Zsh completion not found in expected locations — skipping related check."
fi

# Report results
reportResults
