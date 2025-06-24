#!/bin/sh
set -e

echo "Activating feature 'zip'"

# Detect OS and architecture
OS="$(uname -s)"
ARCH="$(uname -m)"

echo "✅ Detected OS: $OS"
echo "✅ Detected ARCH: $ARCH"

# Skip install if already present
if command -v zip >/dev/null 2>&1 && command -v unzip >/dev/null 2>&1; then
    echo "✅ Zip utilities are already installed. Skipping install."
    exit 0
fi

echo "Installing required dependencies..."

# Function to run apt-get with appropriate privileges
run_apt() {
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
        if run_apt apt-get update -y; then
            return 0
        fi
        echo "apt-get update failed, retrying in 2 seconds..."
        sleep 2
    done
    echo "ERROR: apt-get update failed after multiple attempts."
    return 1
}

# Function to install packages based on the OS/package manager
install_zip_packages() {
    if command -v apt-get >/dev/null 2>&1; then
        # Debian/Ubuntu
        echo "📦 Installing zip utilities via apt-get..."
        if ! try_apt_update; then
            echo "⚠️ Warning: Could not update package lists. Proceeding anyway..."
        fi
        run_apt apt-get install -y zip unzip
    elif command -v yum >/dev/null 2>&1; then
        # RHEL/CentOS/Fedora (older)
        echo "📦 Installing zip utilities via yum..."
        run_apt yum install -y zip unzip
    elif command -v dnf >/dev/null 2>&1; then
        # Fedora (newer)
        echo "📦 Installing zip utilities via dnf..."
        run_apt dnf install -y zip unzip
    elif command -v apk >/dev/null 2>&1; then
        # Alpine Linux
        echo "📦 Installing zip utilities via apk..."
        run_apt apk add --no-cache zip unzip
    elif command -v pacman >/dev/null 2>&1; then
        # Arch Linux
        echo "📦 Installing zip utilities via pacman..."
        run_apt pacman -S --noconfirm zip unzip
    elif command -v zypper >/dev/null 2>&1; then
        # openSUSE
        echo "📦 Installing zip utilities via zypper..."
        run_apt zypper install -y zip unzip
    else
        echo "❌ ERROR: No supported package manager found (apt-get, yum, dnf, apk, pacman, zypper)"
        echo "Please install zip and unzip manually"
        exit 1
    fi
}

# Install zip utilities
if ! command -v zip >/dev/null 2>&1 || ! command -v unzip >/dev/null 2>&1; then
    echo "Installing zip and unzip..."
    if ! install_zip_packages; then
        echo "⚠️ Warning: Could not install zip utilities via package manager. Checking if already available..."
        if ! command -v zip >/dev/null 2>&1; then
            echo "❌ ERROR: zip is required but not available"
            exit 1
        fi
        if ! command -v unzip >/dev/null 2>&1; then
            echo "❌ ERROR: unzip is required but not available"
            exit 1
        fi
    fi
else
    echo "✅ zip and unzip are already available"
fi

# Verify installation
echo "🔍 Verifying installation..."
if command -v zip >/dev/null 2>&1; then
    echo "✅ zip installed successfully."
    zip --version | head -n 1
else
    echo "❌ ERROR: 'zip' command not found in PATH"
    exit 1
fi

if command -v unzip >/dev/null 2>&1; then
    echo "✅ unzip installed successfully."
    unzip -v | head -n 1
else
    echo "❌ ERROR: 'unzip' command not found in PATH"
    exit 1
fi

echo "✅ Zip utilities installation complete!"
