# AWS SAM CLI (aws-sam-cli)

Install [AWS SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html) - AWS Serverless Application Model CLI for serverless application development.

## Example Usage

```json
"features": {
    "ghcr.io/jajera/features/aws-sam-cli:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select or enter a AWS SAM CLI version | string | latest |

## Installation Details

This feature automatically:

- **Detects system architecture** (x86_64, aarch64) and operating system
- **Downloads appropriate binary** for your system (Linux or macOS)
- **Installs for both root and non-root users**:
  - Root: Installs to `/usr/local/bin` with system-wide bash completion
  - Non-root: Installs to `~/.local/bin` with user-specific bash completion
- **Sets up bash completion** automatically
- **Handles dependencies** (curl, unzip) with appropriate privilege handling

## Supported Platforms

- **Operating Systems**: Linux, macOS
- **Architectures**: x86_64 (Intel/AMD 64-bit), aarch64 (ARM 64-bit)
- **Base Images**: Tested on Debian, Ubuntu, and Microsoft DevContainer base images
- **User Contexts**: Works as both root and non-root users

## Commands Available

After installation, the following commands are available:

- `sam` - Main AWS SAM CLI command for serverless application development

## Common SAM CLI Commands

```bash
# Initialize a new SAM application
sam init

# Build your SAM application
sam build

# Deploy your SAM application
sam deploy

# Start local API Gateway
sam local start-api

# Invoke a function locally
sam local invoke

# Validate SAM template
sam validate
```

## Compatibility

- **Package Management**: Uses apt-get (Debian/Ubuntu), yum (RHEL/CentOS), or Homebrew (macOS) with appropriate privileges
- **PATH**: Automatically adds `~/.local/bin` to PATH for non-root installations
- **Dependencies**: Automatically installs curl and unzip if not present

## Reference

- [AWS SAM CLI Documentation](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html)
- [AWS SAM CLI GitHub Repository](https://github.com/aws/aws-sam-cli)
