#!/bin/sh
set -e

echo "Activating feature 'amazon-q-cli'"

# Detect OS and architecture
OS="$(uname -s)"
ARCH="$(uname -m)"

if [ "$OS" != "Linux" ]; then
    echo "Amazon Q CLI is currently only supported on Linux"
    exit 1
fi

echo "✅ Detected OS: $OS"
echo "✅ Detected ARCH: $ARCH"

# Skip install if already present
if command -v q >/dev/null 2>&1; then
    echo "✅ Amazon Q CLI is already installed. Skipping install."
    exit 0
fi

if [ "$(id -u)" -ne 0 ]; then
  echo "Installing dependencies requires root. Please run as root or use a Dev Container feature."
  exit 1
else
  echo "Installing required dependencies..."

  # Retry apt-get update up to 3 times
  try_apt_update() {
    for i in 1 2 3; do
      echo "Running apt-get update (attempt $i)..."
      apt-get update -y && return 0
      echo "apt-get update failed, retrying in 2 seconds..."
      sleep 2
    done
    echo "ERROR: apt-get update failed after multiple attempts."
    exit 1
  }

  try_apt_update
  apt-get install -y curl unzip
fi

# Check glibc version
GLIBC_VERSION=$(ldd --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+' || echo "0.0")
GLIBC_MAJOR=$(echo "$GLIBC_VERSION" | cut -d. -f1)
GLIBC_MINOR=$(echo "$GLIBC_VERSION" | cut -d. -f2)

# Ensure numeric values
case "$GLIBC_MAJOR" in ''|*[!0-9]*) GLIBC_MAJOR=0 ;; esac
case "$GLIBC_MINOR" in ''|*[!0-9]*) GLIBC_MINOR=0 ;; esac

# Decide musl suffix
if [ "$GLIBC_MAJOR" -gt 2 ] || { [ "$GLIBC_MAJOR" -eq 2 ] && [ "$GLIBC_MINOR" -ge 34 ]; }; then
    SUFFIX=""
else
    SUFFIX="-musl"
fi

# Determine architecture-specific URL
case "$ARCH" in
    x86_64)
        ARCH_NAME="x86_64"
        ;;
    aarch64)
        ARCH_NAME="aarch64"
        ;;
    *)
        echo "❌ Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Download and install
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo "⬇️ Downloading Amazon Q CLI..."
curl --proto '=https' --tlsv1.2 -sSf "https://desktop-release.q.us-east-1.amazonaws.com/latest/q-${ARCH_NAME}-linux${SUFFIX}.zip" -o q.zip

echo "📦 Installing Amazon Q CLI..."
unzip -o q.zip

# Manual user-local install (no prompt)
if [ "$(id -u)" -eq 0 ]; then
    echo "Installing Amazon Q CLI to /usr/local/bin..."
    INSTALL_DIR="/usr/local/bin"
else
    echo "Installing Amazon Q CLI to ~/.local/bin..."
    INSTALL_DIR="$HOME/.local/bin"
    mkdir -p "$INSTALL_DIR"
    export PATH="$INSTALL_DIR:$PATH"
fi

for binary in ./q/bin/*; do
    if [ -x "$binary" ]; then
        cp "$binary" "$INSTALL_DIR/"
    fi
done

# Clean up
cd /
rm -rf "$TEMP_DIR"

# Verify installation
if command -v q >/dev/null 2>&1; then
    echo "✅ Amazon Q CLI installed successfully."
    q --version
else
    echo "❌ ERROR: 'q' command not found in PATH"
    exit 1
fi

# Setup bash completion
if [ "$(id -u)" -eq 0 ]; then
    COMPLETION_DIR="/etc/bash_completion.d"
    COMPLETION_FILE="$COMPLETION_DIR/q"
    mkdir -p "$COMPLETION_DIR"
    q completion bash > "$COMPLETION_FILE"

    # Ensure it's sourced system-wide
    if ! grep -q 'source /etc/bash_completion.d/q' /etc/bash.bashrc; then
        echo 'source /etc/bash_completion.d/q' >> /etc/bash.bashrc
    fi
else
    COMPLETION_DIR="$HOME/.bash_completion.d"
    COMPLETION_FILE="$COMPLETION_DIR/q"
    mkdir -p "$COMPLETION_DIR"
    q completion bash > "$COMPLETION_FILE"

    COMPLETION_LINE='source $HOME/.bash_completion.d/q'
    grep -qxF "$COMPLETION_LINE" "$HOME/.bashrc" || echo "$COMPLETION_LINE" >> "$HOME/.bashrc"
fi
