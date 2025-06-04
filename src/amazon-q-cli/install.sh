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

# Try to install dependencies, but don't fail if we can't
if ! try_apt_update; then
    echo "⚠️ Warning: Could not update package lists. Proceeding anyway..."
fi

# Try to install curl and unzip, but don't fail if they're already available
if ! command -v curl >/dev/null 2>&1 || ! command -v unzip >/dev/null 2>&1; then
    echo "Installing curl and unzip..."
    if ! run_apt apt-get install -y curl unzip; then
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

# Check glibc version
GLIBC_VERSION=$(ldd --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+' || echo "0.0")
GLIBC_MAJOR=$(echo "$GLIBC_VERSION" | cut -d. -f1)
GLIBC_MINOR=$(echo "$GLIBC_VERSION" | cut -d. -f2)

# Ensure numeric values
case "$GLIBC_MAJOR" in '' | *[!0-9]*) GLIBC_MAJOR=0 ;; esac
case "$GLIBC_MINOR" in '' | *[!0-9]*) GLIBC_MINOR=0 ;; esac

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

echo "⬇️ Downloading Amazon Q CLI..."
curl --proto '=https' --tlsv1.2 -sSf "https://desktop-release.q.us-east-1.amazonaws.com/latest/q-${ARCH_NAME}-linux${SUFFIX}.zip" -o q.zip

echo "📦 Installing Amazon Q CLI..."
unzip -o q.zip

echo "Installing Amazon Q CLI to $INSTALL_DIR..."

# Run the installer first - this handles proper installation
if [ "$(id -u)" -eq 0 ]; then
    ./q/install.sh --no-confirm --force
else
    ./q/install.sh --no-confirm
fi

# Ensure binaries are in the expected location
# The installer usually puts binaries in ~/.local/bin for non-root or /usr/local/bin for root
# But we need to ensure they're accessible
for binary in ./q/bin/*; do
    if [ -x "$binary" ]; then
        binary_name=$(basename "$binary")
        target_path="$INSTALL_DIR/$binary_name"

        # Copy or ensure binary is present
        if [ ! -f "$target_path" ]; then
            echo "📋 Copying $binary_name to $INSTALL_DIR"
            cp "$binary" "$INSTALL_DIR/"
            chmod +x "$INSTALL_DIR/$binary_name"
        fi
    fi
done

# System-wide: ensure /usr/local/bin/qchat exists and is executable
if [ -f /usr/local/bin/qchat ]; then
    chmod +x /usr/local/bin/qchat
fi

# Create a profile.d script to ensure symlink for all users (only if root)
if [ "$(id -u)" -eq 0 ]; then
    cat <<'EOF' >/etc/profile.d/qchat-local-bin.sh
#!/bin/sh
if [ -n "$HOME" ] && [ -d "$HOME" ]; then
    mkdir -p "$HOME/.local/bin"
    if [ ! -L "$HOME/.local/bin/qchat" ] && [ -x /usr/local/bin/qchat ]; then
        ln -sf /usr/local/bin/qchat "$HOME/.local/bin/qchat"
    fi
fi
EOF
    chmod +x /etc/profile.d/qchat-local-bin.sh
fi

# For testing purposes, ensure Amazon Q CLI commands are visible in /usr/local/bin
# This helps with test visibility across different user contexts
if [ "$(id -u)" -ne 0 ]; then
    for cmd in q qchat qterm; do
        local_bin_path="$HOME/.local/bin/$cmd"
        usr_local_bin_path="/usr/local/bin/$cmd"

        if [ -f "$local_bin_path" ] && [ ! -f "$usr_local_bin_path" ]; then
            echo "🔁 Attempting to symlink $cmd to /usr/local/bin for test visibility"
            # Try to create symlink, but don't fail if we can't (permission issues)
            ln -sf "$local_bin_path" "$usr_local_bin_path" 2>/dev/null || {
                echo "⚠️ Could not create symlink to /usr/local/bin (permission denied) - continuing"
            }
        fi
    done
fi

# Clean up
cd /
rm -rf "$TEMP_DIR"

# Verify installation
if command -v q >/dev/null 2>&1; then
    echo "✅ Amazon Q CLI installed successfully."
    q --version
elif [ -f "$INSTALL_DIR/q" ]; then
    echo "✅ Amazon Q CLI installed successfully at $INSTALL_DIR/q."
    "$INSTALL_DIR/q" --version
else
    echo "❌ ERROR: 'q' command not found in PATH or at $INSTALL_DIR"
    echo "PATH: $PATH"
    echo "Contents of $INSTALL_DIR:"
    ls -la "$INSTALL_DIR" 2>/dev/null || echo "Directory does not exist"
    exit 1
fi

# Setup bash completion
echo "Setting up bash completion..."
mkdir -p "$COMPLETION_DIR"

COMPLETION_FILE="$COMPLETION_DIR/q"
if command -v q >/dev/null 2>&1; then
    q completion bash >"$COMPLETION_FILE"
elif [ -f "$INSTALL_DIR/q" ]; then
    "$INSTALL_DIR/q" completion bash >"$COMPLETION_FILE"
fi

# Source completion in the appropriate bashrc
if [ "$(id -u)" -eq 0 ]; then
    # System-wide completion
    if ! grep -q 'source /etc/bash_completion.d/q' "$BASHRC_FILE" 2>/dev/null; then
        echo 'source /etc/bash_completion.d/q' >>"$BASHRC_FILE"
    fi
else
    # User-specific completion
    COMPLETION_LINE="source \$HOME/.bash_completion.d/q"
    grep -qxF "$COMPLETION_LINE" "$BASHRC_FILE" 2>/dev/null || echo "$COMPLETION_LINE" >>"$BASHRC_FILE"
fi

# Setup shell integrations
echo "Setting up shell integrations..."
if command -v q >/dev/null 2>&1; then
    Q_CMD="q"
elif [ -f "$INSTALL_DIR/q" ]; then
    Q_CMD="$INSTALL_DIR/q"
else
    Q_CMD=""
fi

if [ -n "$Q_CMD" ]; then
    # Install shell integrations
    echo "Installing shell integrations..."
    "$Q_CMD" integrations install dotfiles

    # Ensure Q_TERM is set in the environment
    if [ "$(id -u)" -eq 0 ]; then
        # System-wide environment
        if ! grep -q 'export Q_TERM=' "$PROFILE_FILE" 2>/dev/null; then
            echo 'export Q_TERM=1' >>"$PROFILE_FILE"
        fi
    else
        # User-specific environment
        if ! grep -q 'export Q_TERM=' "$PROFILE_FILE" 2>/dev/null; then
            echo 'export Q_TERM=1' >>"$PROFILE_FILE"
        fi
        if ! grep -q 'export Q_TERM=' "$BASHRC_FILE" 2>/dev/null; then
            echo 'export Q_TERM=1' >>"$BASHRC_FILE"
        fi
    fi

    # Set Q_TERM in current session
    export Q_TERM=1
fi

echo "✅ Amazon Q CLI installation complete!"
