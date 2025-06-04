# Amazon Q CLI (amazon-q-cli)

Install [Amazon Q CLI](https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/command-line-installing.html) - AWS Q Developer CLI tool for AI-powered development assistance.

## Example Usage

```json
"features": {
    "ghcr.io/jajera/features/amazon-q-cli:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select or enter a Amazon Q CLI version | string | latest |

## Installation Details

This feature automatically:

- **Detects system architecture** (x86_64, aarch64) and glibc version
- **Downloads appropriate binary** for your system (with musl fallback for older systems)
- **Installs for both root and non-root users**:
  - Root: Installs to `/usr/local/bin` with system-wide bash completion
  - Non-root: Installs to `~/.local/bin` with user-specific bash completion
- **Sets up bash completion** automatically
- **Handles dependencies** (curl, unzip) with appropriate privilege handling

## Supported Platforms

- **Operating Systems**: Linux only
- **Architectures**: x86_64 (Intel/AMD 64-bit), aarch64 (ARM 64-bit)
- **Base Images**: Tested on Debian, Ubuntu, and Microsoft DevContainer base images
- **User Contexts**: Works as both root and non-root users

## Commands Available

After installation, the following commands are available:

- `q` - Main Amazon Q CLI command
- `qchat` - Amazon Q chat interface
- `qterm` - Amazon Q terminal interface

## Compatibility

- **glibc**: Automatically detects glibc version and uses musl build for older systems
- **Package Management**: Uses apt-get with appropriate privileges (sudo when available)
- **PATH**: Automatically adds `~/.local/bin` to PATH for non-root installations

## Reference

- [Amazon Q CLI Documentation](https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/command-line-installing.html)
