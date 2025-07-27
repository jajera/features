#!/bin/sh
set -e

echo "Activating feature 'aws-sam-cli'"

# Detect OS and architecture
OS="$(uname -s)"
ARCH="$(uname -m)"

echo "✅ Detected OS: $OS"
echo "✅ Detected ARCH: $ARCH"

# Skip install if already present
if command -v sam >/dev/null 2>&1; then
    echo "✅ AWS SAM CLI is already installed. Skipping install."
    sam --version
    exit 0
fi

echo "Installing required dependencies..."

# Function to run package manager with appropriate privileges
run_pkg_mgr() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        echo "⚠️ Warning: Running as non-root user without sudo. Package installation may fail."
        "$@"
    fi
}

# Install dependencies based on OS
case "$OS" in
Linux)
    # Try to install dependencies, but don't fail if we can't
    if command -v apt-get >/dev/null 2>&1; then
        echo "Installing dependencies via apt-get..."
        if ! run_pkg_mgr apt-get update -y; then
            echo "⚠️ Warning: Could not update package lists. Proceeding anyway..."
        fi

        if ! command -v curl >/dev/null 2>&1 || ! command -v unzip >/dev/null 2>&1; then
            echo "Installing curl and unzip..."
            if ! run_pkg_mgr apt-get install -y curl unzip; then
                echo "⚠️ Warning: Could not install curl/unzip via apt. Checking if already available..."
                if ! command -v curl >/dev/null 2>&1; then
                    echo "❌ ERROR: curl is required but not available"
                    exit 1
                fi
                if ! command -v unzip >/dev/null 2>&1; then
                    echo "❌ ERROR: unzip is required but not available"
                    exit 1
                fi
            fi
        else
            echo "✅ curl and unzip are already available"
        fi
    elif command -v yum >/dev/null 2>&1; then
        echo "Installing dependencies via yum..."
        if ! command -v curl >/dev/null 2>&1 || ! command -v unzip >/dev/null 2>&1; then
            if ! run_pkg_mgr yum install -y curl unzip; then
                echo "⚠️ Warning: Could not install curl/unzip via yum. Checking if already available..."
                if ! command -v curl >/dev/null 2>&1; then
                    echo "❌ ERROR: curl is required but not available"
                    exit 1
                fi
                if ! command -v unzip >/dev/null 2>&1; then
                    echo "❌ ERROR: unzip is required but not available"
                    exit 1
                fi
            fi
        else
            echo "✅ curl and unzip are already available"
        fi
    else
        echo "⚠️ Warning: No supported package manager found. Checking if curl and unzip are available..."
        if ! command -v curl >/dev/null 2>&1; then
            echo "❌ ERROR: curl is required but not available"
            exit 1
        fi
        if ! command -v unzip >/dev/null 2>&1; then
            echo "❌ ERROR: unzip is required but not available"
            exit 1
        fi
    fi
    ;;
Darwin)
    echo "Installing dependencies via Homebrew..."
    if command -v brew >/dev/null 2>&1; then
        if ! command -v curl >/dev/null 2>&1 || ! command -v unzip >/dev/null 2>&1; then
            brew install curl unzip
        else
            echo "✅ curl and unzip are already available"
        fi
    else
        echo "⚠️ Warning: Homebrew not found. Checking if curl and unzip are available..."
        if ! command -v curl >/dev/null 2>&1; then
            echo "❌ ERROR: curl is required but not available"
            exit 1
        fi
        if ! command -v unzip >/dev/null 2>&1; then
            echo "❌ ERROR: unzip is required but not available"
            exit 1
        fi
    fi
    ;;
*)
    echo "❌ Unsupported operating system: $OS"
    exit 1
    ;;
esac

# Set install directory based on user permissions
if [ "$(id -u)" -eq 0 ]; then
    INSTALL_DIR="/usr/local/bin"
    COMPLETION_DIR="/etc/bash_completion.d"
    BASHRC_FILE="/etc/bash.bashrc"
    PROFILE_FILE="/etc/profile"
    ZSHRC_FILE="/etc/zsh/zshrc"
    ZPROFILE_FILE="/etc/zsh/zprofile"
else
    INSTALL_DIR="$HOME/.local/bin"
    COMPLETION_DIR="$HOME/.bash_completion.d"
    BASHRC_FILE="$HOME/.bashrc"
    PROFILE_FILE="$HOME/.profile"
    ZSHRC_FILE="$HOME/.zshrc"
    ZPROFILE_FILE="$HOME/.zprofile"
    # Ensure local bin directory exists and is in PATH
    mkdir -p "$INSTALL_DIR"
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        export PATH="$HOME/.local/bin:$PATH"
    fi
fi

echo "📁 Install directory: $INSTALL_DIR"

# Download and install
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo "⬇️ Downloading AWS SAM CLI..."

# Determine architecture-specific URL
case "$ARCH" in
x86_64)
    ARCH_NAME="x86_64"
    ;;
aarch64|arm64)
    ARCH_NAME="aarch64"
    ;;
*)
    echo "❌ Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

# Download SAM CLI
if [ "$OS" = "Darwin" ]; then
    # macOS
    SAM_URL="https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-mac-${ARCH_NAME}.zip"
else
    # Linux
    SAM_URL="https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-${ARCH_NAME}.zip"
fi

echo "Downloading from: $SAM_URL"
if ! curl -L -o sam-cli.zip "$SAM_URL"; then
    echo "❌ ERROR: Failed to download AWS SAM CLI from $SAM_URL"
    echo "Checking if the URL is accessible..."
    curl -I "$SAM_URL" || echo "URL is not accessible"
    exit 1
fi

# Verify the downloaded file is valid
if [ ! -s sam-cli.zip ]; then
    echo "❌ ERROR: Downloaded file is empty"
    exit 1
fi

# Check if the file is actually a zip file
if ! unzip -t sam-cli.zip >/dev/null 2>&1; then
    echo "❌ ERROR: Downloaded file is not a valid zip file"
    echo "File size: $(wc -c < sam-cli.zip) bytes"
    echo "First 100 bytes:"
    head -c 100 sam-cli.zip | hexdump -C
    exit 1
fi

echo "📦 Installing AWS SAM CLI..."
unzip -o sam-cli.zip

# Install SAM CLI
echo "Installing AWS SAM CLI to $INSTALL_DIR..."
if [ -f "dist/sam" ]; then
    # Copy the entire dist directory to preserve the bundled Python libraries
    cp -r dist "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/dist/sam"
    # Create a symlink for easier access
    ln -sf "$INSTALL_DIR/dist/sam" "$INSTALL_DIR/sam"
elif [ -f "sam" ]; then
    cp sam "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/sam"
else
    echo "❌ ERROR: Could not find sam binary in downloaded package"
    ls -la
    exit 1
fi

# Clean up
cd /
rm -rf "$TEMP_DIR"

# Verify installation
if command -v sam >/dev/null 2>&1; then
    echo "✅ AWS SAM CLI installed successfully."
    sam --version
elif [ -f "$INSTALL_DIR/sam" ]; then
    echo "✅ AWS SAM CLI installed successfully at $INSTALL_DIR/sam."
    "$INSTALL_DIR/sam" --version
else
    echo "❌ ERROR: 'sam' command not found in PATH or at $INSTALL_DIR"
    echo "PATH: $PATH"
    echo "Contents of $INSTALL_DIR:"
    ls -la "$INSTALL_DIR" 2>/dev/null || echo "Directory does not exist"
    exit 1
fi

# Setup bash completion
echo "Setting up bash completion..."
mkdir -p "$COMPLETION_DIR"

COMPLETION_FILE="$COMPLETION_DIR/sam"
if command -v sam >/dev/null 2>&1; then
    sam completion bash >"$COMPLETION_FILE" 2>/dev/null || {
        echo "⚠️ Warning: Could not generate bash completion for sam"
    }
elif [ -f "$INSTALL_DIR/sam" ]; then
    "$INSTALL_DIR/sam" completion bash >"$COMPLETION_FILE" 2>/dev/null || {
        echo "⚠️ Warning: Could not generate bash completion for sam"
    }
fi

# Source completion in the appropriate bashrc
if [ -f "$COMPLETION_FILE" ]; then
    if [ "$(id -u)" -eq 0 ]; then
        # System-wide completion
        if ! grep -q 'source /etc/bash_completion.d/sam' "$BASHRC_FILE" 2>/dev/null; then
            echo 'source /etc/bash_completion.d/sam' >>"$BASHRC_FILE"
        fi
    else
        # User-specific completion
        COMPLETION_LINE="source \$HOME/.bash_completion.d/sam"
        grep -qxF "$COMPLETION_LINE" "$BASHRC_FILE" 2>/dev/null || echo "$COMPLETION_LINE" >>"$BASHRC_FILE"
    fi
fi

# For testing purposes, ensure SAM CLI command is visible in /usr/local/bin
# This helps with test visibility across different user contexts
if [ "$(id -u)" -ne 0 ]; then
    local_bin_path="$HOME/.local/bin/sam"
    usr_local_bin_path="/usr/local/bin/sam"

    if [ -f "$local_bin_path" ] && [ ! -f "$usr_local_bin_path" ]; then
        echo "🔁 Attempting to symlink sam to /usr/local/bin for test visibility"
        # Try to create symlink, but don't fail if we can't (permission issues)
        ln -sf "$local_bin_path" "$usr_local_bin_path" 2>/dev/null || {
            echo "⚠️ Could not create symlink to /usr/local/bin (permission denied) - continuing"
        }
    fi
fi

echo "✅ AWS SAM CLI installation complete!"
