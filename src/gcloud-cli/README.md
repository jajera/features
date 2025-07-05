# Google Cloud CLI (gcloud-cli)

Installs `gcloud` (Google Cloud CLI), the command-line interface for Google Cloud Platform.

## Example Usage

```json
"features": {
    "ghcr.io/jajera/features/gcloud-cli:1": {}
}
```

## Options

This feature has no configurable options.

## Description

This feature installs `gcloud` (Google Cloud CLI), the command-line interface for Google Cloud Platform. The installation is compatible with multiple Linux distributions and package managers including:

- **Debian/Ubuntu**: Uses `apt-get`
- **RHEL/CentOS/Fedora**: Uses `yum`/`dnf`
- **Alpine Linux**: Uses `apk`
- **Arch Linux**: Uses `pacman`
- **openSUSE**: Uses `zypper`

## Features

- ✅ Cross-platform support for major Linux distributions
- ✅ Automatic package manager detection
- ✅ Retry logic for package updates
- ✅ Privilege escalation handling (sudo when needed)
- ✅ Comprehensive error handling
- ✅ Installation verification
- ✅ Automatic shell completion setup (bash and zsh)
- ✅ Symlinks for gcloud, gsutil, and bq binaries
- ✅ Non-interactive initialization
- ✅ Support for x86_64 and ARM64 architectures

### Package Names by Platform

Dependencies installed by platform:

- Debian/Ubuntu: `curl`, `gnupg`, `lsb-release`
- RHEL/CentOS/Fedora: `curl`, `gnupg2`
- Alpine: `curl`, `gnupg`
- Arch: `curl`, `gnupg`
- openSUSE: `curl`, `gnupg2`

## Usage Examples

After installation, you can use the Google Cloud CLI tools:

```bash
# Check gcloud version
gcloud version

# Initialize gcloud (if not done automatically)
gcloud init

# List available projects
gcloud projects list

# Set active project
gcloud config set project PROJECT_ID

# List compute instances
gcloud compute instances list

# Use gsutil for Cloud Storage operations
gsutil ls gs://

# Use bq for BigQuery operations
bq ls
```

## Verification

The feature automatically verifies successful installation by:

- Checking if `gcloud` command is available
- Running version check for the utility
- Verifying `gsutil` and `bq` binaries are accessible
- Testing basic gcloud functionality
- Setting up shell completion for bash and zsh

## Shell Completion

The feature automatically sets up shell completion:

- **Bash**: Completion is installed to `/etc/bash_completion.d/` (system-wide) or `~/.bash_completion.d/` (user-specific)
- **Zsh**: Completion is sourced in `~/.zshrc` or `/etc/zsh/zshrc`

---

_Note, this file was auto-generated from the [devcontainer-feature.json](https://github.com/jajera/features/blob/main/src/gcloud-cli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
