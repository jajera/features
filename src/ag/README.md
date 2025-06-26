# ag - The Silver Searcher (ag)

Installs `ag` (The Silver Searcher), a fast grep-like text search tool.

## Example Usage

```json
"features": {
    "ghcr.io/jajera/features/ag:1": {}
}
```

## Options

This feature has no configurable options.

## Description

The Silver Searcher is a code search tool similar to ack, with a focus on speed. It's faster than ack and grep, and respects .gitignore files.

Key features of ag:

- Fast text searching
- Respects .gitignore and .hgignore files
- Searches specific file types
- Supports regular expressions
- Color-coded output
- Multi-threaded for speed

## Supported Platforms

This feature works on:

- Debian/Ubuntu (via `apt-get`)
- RHEL/CentOS/Fedora (via `yum`/`dnf`)
- Alpine Linux (via `apk`)
- Arch Linux (via `pacman`)
- openSUSE (via `zypper`)

## Installation

The feature automatically detects the platform and uses the appropriate package manager to install `ag`.

### Package Names by Platform

- Debian/Ubuntu: `silversearcher-ag`
- RHEL/CentOS/Fedora: `the_silver_searcher`
- Alpine: `the_silver_searcher`
- Arch: `the_silver_searcher`
- openSUSE: `the_silver_searcher`

## Usage Examples

After installation, you can use `ag` to search for text:

```bash
# Search for a string in current directory
ag "search_term"

# Search only in specific file types
ag "search_term" --go

# Search with regular expressions
ag "function\s+\w+" --python

# Show context lines
ag "search_term" -A 3 -B 3
```

## Documentation

For more information about The Silver Searcher, see:

- [Official GitHub Repository](https://github.com/ggreer/the_silver_searcher)
- [ag man page](https://linux.die.net/man/1/ag)
