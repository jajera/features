#!/bin/sh
set -e

echo "Activating feature 'ag'"

# Detect OS and architecture
OS="$(uname -s)"
ARCH="$(uname -m)"

echo "✅ Detected OS: $OS"
echo "✅ Detected ARCH: $ARCH"

# Skip install if already present
if command -v ag >/dev/null 2>&1; then
    echo "✅ ag (The Silver Searcher) is already installed. Skipping install."
    exit 0
fi

echo "Installing ag (The Silver Searcher)..."

# Function to run package managers with appropriate privileges
run_cmd() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        echo "⚠️ Warning: Running as non-root user without sudo. Package installation may fail."
        "$@"
    fi
}

# Retry apt-get update up to 3 times
try_apt_update() {
    for i in 1 2 3; do
        echo "Running apt-get update (attempt $i)..."
        if run_cmd apt-get update -y; then
            return 0
        fi
        echo "apt-get update failed, retrying in 2 seconds..."
        sleep 2
    done
    echo "ERROR: apt-get update failed after multiple attempts."
    return 1
}

# Function to install ag based on the OS/package manager
install_ag() {
    if command -v apt-get >/dev/null 2>&1; then
        # Debian/Ubuntu
        echo "📦 Installing ag via apt-get..."
        if ! try_apt_update; then
            echo "⚠️ Warning: Could not update package lists. Proceeding anyway..."
        fi
        run_cmd apt-get install -y silversearcher-ag
    elif command -v yum >/dev/null 2>&1; then
        # RHEL/CentOS/Fedora (older)
        echo "📦 Installing ag via yum..."
        # Enable EPEL repository for CentOS/RHEL
        run_cmd yum install -y epel-release || echo "⚠️ EPEL repository may already be enabled"
        run_cmd yum install -y the_silver_searcher
    elif command -v dnf >/dev/null 2>&1; then
        # Fedora (newer)
        echo "📦 Installing ag via dnf..."
        run_cmd dnf install -y the_silver_searcher
    elif command -v apk >/dev/null 2>&1; then
        # Alpine Linux
        echo "📦 Installing ag via apk..."
        run_cmd apk add --no-cache the_silver_searcher
    elif command -v pacman >/dev/null 2>&1; then
        # Arch Linux
        echo "📦 Installing ag via pacman..."
        run_cmd pacman -S --noconfirm the_silver_searcher
    elif command -v zypper >/dev/null 2>&1; then
        # openSUSE
        echo "📦 Installing ag via zypper..."
        run_cmd zypper install -y the_silver_searcher
    else
        echo "❌ ERROR: No supported package manager found (apt-get, yum, dnf, apk, pacman, zypper)"
        echo "Please install ag (The Silver Searcher) manually"
        exit 1
    fi
}

# Install ag
echo "Installing ag (The Silver Searcher)..."
if ! install_ag; then
    echo "❌ ERROR: Could not install ag via package manager"
    exit 1
fi

# Verify installation
echo "🔍 Verifying installation..."
if command -v ag >/dev/null 2>&1; then
    echo "✅ ag installed successfully."
    ag --version
else
    echo "❌ ERROR: 'ag' command not found in PATH"
    exit 1
fi

echo "✅ ag (The Silver Searcher) installation complete!"
