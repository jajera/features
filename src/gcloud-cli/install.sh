#!/bin/sh
set -e

echo "Activating feature 'gcloud-cli'"

# Detect OS and architecture
OS="$(uname -s)"
ARCH="$(uname -m)"

if [ "$OS" != "Linux" ]; then
    echo "Google Cloud CLI is currently only supported on Linux"
    exit 1
fi

echo "✅ Detected OS: $OS"
echo "✅ Detected ARCH: $ARCH"

# Skip install if already present
if command -v gcloud >/dev/null 2>&1; then
    echo "✅ Google Cloud CLI is already installed. Skipping install."
    exit 0
fi

echo "Installing Google Cloud CLI..."

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

# Function to install dependencies based on the OS/package manager
install_dependencies() {
    if command -v apt-get >/dev/null 2>&1; then
        # Debian/Ubuntu
        echo "📦 Installing dependencies via apt-get..."
        if ! try_apt_update; then
            echo "⚠️ Warning: Could not update package lists. Proceeding anyway..."
        fi
        run_cmd apt-get install -y curl gnupg lsb-release
    elif command -v yum >/dev/null 2>&1; then
        # RHEL/CentOS/Fedora (older)
        echo "📦 Installing dependencies via yum..."
        run_cmd yum install -y curl gnupg2
    elif command -v dnf >/dev/null 2>&1; then
        # Fedora (newer)
        echo "📦 Installing dependencies via dnf..."
        run_cmd dnf install -y curl gnupg2
    elif command -v apk >/dev/null 2>&1; then
        # Alpine Linux
        echo "📦 Installing dependencies via apk..."
        run_cmd apk add --no-cache curl gnupg
    elif command -v pacman >/dev/null 2>&1; then
        # Arch Linux
        echo "📦 Installing dependencies via pacman..."
        run_cmd pacman -S --noconfirm curl gnupg
    elif command -v zypper >/dev/null 2>&1; then
        # openSUSE
        echo "📦 Installing dependencies via zypper..."
        run_cmd zypper install -y curl gnupg2
    else
        echo "❌ ERROR: No supported package manager found (apt-get, yum, dnf, apk, pacman, zypper)"
        echo "Please install curl and gnupg manually"
        exit 1
    fi
}

# Install dependencies
echo "Installing required dependencies..."
if ! install_dependencies; then
    echo "❌ ERROR: Could not install dependencies via package manager"
    exit 1
fi

# Check if curl is available
if ! command -v curl >/dev/null 2>&1; then
    echo "❌ ERROR: curl is required but not available"
    exit 1
fi

# Determine architecture-specific URL
case "$ARCH" in
x86_64)
    ARCH_NAME="x86_64"
    ;;
aarch64)
    ARCH_NAME="arm"
    ;;
*)
    echo "❌ Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

# Set install directory based on user permissions
if [ "$(id -u)" -eq 0 ]; then
    INSTALL_DIR="/usr/local/share/google-cloud-sdk"
    BIN_DIR="/usr/local/bin"
    BASHRC_FILE="/etc/bash.bashrc"
else
    INSTALL_DIR="$HOME/.local/share/google-cloud-sdk"
    BIN_DIR="$HOME/.local/bin"
    BASHRC_FILE="$HOME/.bashrc"
    # Ensure local bin directory exists and is in PATH
    mkdir -p "$BIN_DIR"
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        export PATH="$HOME/.local/bin:$PATH"
    fi
fi

echo "📁 Install directory: $INSTALL_DIR"

# Download and install
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo "⬇️ Downloading Google Cloud CLI..."
curl --proto '=https' --tlsv1.2 -sSf "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-${ARCH_NAME}.tar.gz" -o google-cloud-cli.tar.gz

echo "📦 Installing Google Cloud CLI..."
tar -xzf google-cloud-cli.tar.gz

echo "Installing Google Cloud CLI to $INSTALL_DIR..."

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Copy the SDK
cp -r google-cloud-sdk/* "$INSTALL_DIR/"

# Set up the installation manually instead of using the problematic installer script
echo "🔧 Setting up Google Cloud CLI manually..."

# Remove any file at $INSTALL_DIR/properties before creating the directory
if [ -f "$INSTALL_DIR/properties" ]; then
    rm -f "$INSTALL_DIR/properties"
fi

# Create the properties directory
PROPERTIES_DIR="$INSTALL_DIR/properties"
mkdir -p "$PROPERTIES_DIR"

# Create a basic properties file
cat > "$PROPERTIES_DIR/core.json" << 'EOF'
{
  "disable_usage_reporting": true,
  "disable_updater": true
}
EOF

# Create symlinks
echo "🔗 Creating symlinks..."
if [ ! -L "$BIN_DIR/gcloud" ]; then
    ln -sf "$INSTALL_DIR/bin/gcloud" "$BIN_DIR/gcloud"
fi

if [ ! -L "$BIN_DIR/gsutil" ]; then
    ln -sf "$INSTALL_DIR/bin/gsutil" "$BIN_DIR/gsutil"
fi

if [ ! -L "$BIN_DIR/bq" ]; then
    ln -sf "$INSTALL_DIR/bin/bq" "$BIN_DIR/bq"
fi

# Make binaries executable
chmod +x "$INSTALL_DIR/bin/gcloud"
chmod +x "$INSTALL_DIR/bin/gsutil"
chmod +x "$INSTALL_DIR/bin/bq"

# Set up shell completion if possible
if [ -f "$INSTALL_DIR/completion.bash.inc" ]; then
    echo "🔧 Setting up bash completion..."
    if [ "$(id -u)" -eq 0 ]; then
        # For root, add to system bashrc
        if ! grep -q "google-cloud-sdk/completion.bash.inc" "$BASHRC_FILE" 2>/dev/null; then
            echo "" >> "$BASHRC_FILE"
            echo "# Google Cloud SDK completion" >> "$BASHRC_FILE"
            echo "source '$INSTALL_DIR/completion.bash.inc'" >> "$BASHRC_FILE"
        fi
    else
        # For non-root, add to user bashrc
        if ! grep -q "google-cloud-sdk/completion.bash.inc" "$BASHRC_FILE" 2>/dev/null; then
            echo "" >> "$BASHRC_FILE"
            echo "# Google Cloud SDK completion" >> "$BASHRC_FILE"
            echo "source '$INSTALL_DIR/completion.bash.inc'" >> "$BASHRC_FILE"
        fi
    fi
fi

# Set up PATH if not already set
if [ "$(id -u)" -eq 0 ]; then
    # For root, create a profile.d script
    PROFILE_SCRIPT="/etc/profile.d/google-cloud-sdk.sh"
    cat > "$PROFILE_SCRIPT" << EOF
#!/bin/sh
export PATH="$INSTALL_DIR/bin:\$PATH"
EOF
    chmod +x "$PROFILE_SCRIPT"
else
    # For non-root, add to user bashrc if not already there
    if ! grep -q "google-cloud-sdk/bin" "$BASHRC_FILE" 2>/dev/null; then
        echo "" >> "$BASHRC_FILE"
        echo "# Google Cloud SDK PATH" >> "$BASHRC_FILE"
        echo "export PATH=\"$INSTALL_DIR/bin:\$PATH\"" >> "$BASHRC_FILE"
    fi
fi

# Clean up
cd /
rm -rf "$TEMP_DIR"

# Verify installation
echo "🔍 Verifying installation..."
if command -v gcloud >/dev/null 2>&1; then
    echo "✅ Google Cloud CLI installed successfully."
    gcloud version
else
    echo "❌ ERROR: 'gcloud' command not found in PATH"
    echo "Trying to add to PATH manually..."
    export PATH="$INSTALL_DIR/bin:$PATH"
    if command -v gcloud >/dev/null 2>&1; then
        echo "✅ Google Cloud CLI found after PATH adjustment."
        gcloud version
    else
        echo "❌ ERROR: 'gcloud' command still not found"
        exit 1
    fi
fi

# Initialize gcloud (non-interactive)
echo "🔧 Initializing Google Cloud CLI..."
"$INSTALL_DIR/bin/gcloud" init --skip-diagnostics --quiet || {
    echo "⚠️ Warning: Could not initialize gcloud automatically. You may need to run 'gcloud init' manually."
}

echo "✅ Google Cloud CLI installation complete!"
