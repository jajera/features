# Zip Utility (zip)

Installs zip and unzip CLI tools for compression and extraction.

## Example Usage

```json
"features": {
    "ghcr.io/jajera/features/zip:1": {}
}
```

## Options

This feature has no configurable options.

## Description

This feature installs the `zip` and `unzip` command-line utilities for creating and extracting ZIP archives. The installation is compatible with multiple Linux distributions and package managers including:

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

## Usage Examples

After installation, you can use the zip utilities:

```bash
# Create a zip archive
zip archive.zip file1.txt file2.txt

# Extract a zip archive
unzip archive.zip

# View zip archive contents
unzip -l archive.zip

# Create zip with compression
zip -9 archive.zip file.txt

# Extract to specific directory
unzip archive.zip -d /target/directory
```

## Verification

The feature automatically verifies successful installation by:

- Checking if `zip` command is available
- Checking if `unzip` command is available
- Running version checks for both utilities

---

_Note, this file was auto-generated from the [devcontainer-feature.json](https://github.com/jajera/features/blob/main/src/zip/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
