# Dev Container Features

## Contents

This repository contains following features:

- [amazon-q-cli](./src/amazon-q-cli/README.md): Install Amazon Q CLI for AWS development

## Usage

To use the features from this repository, add the desired features to devcontainer.json.

This example uses amazon-q-cli feature on devcontainer:

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/jajera/features/amazon-q-cli:1": {}
    }
}
```

## Repo and Feature Structure

Similar to the [`devcontainers/features`](https://github.com/devcontainers/features) repo, this repository has a `src` folder. Each feature has its own sub-folder, containing at least a `devcontainer-feature.json` and an entrypoint script `install.sh`.

```plaintext
├── src
│   ├── amazon-q-cli
│   │   ├── devcontainer-feature.json
│   │   └── install.sh
...
```

An [implementing tool](https://containers.dev/supporting#tools) will composite [the documented dev container properties](https://containers.dev/implementors/features/#devcontainer-feature-json-properties) from the feature's `devcontainer-feature.json` file, and execute in the `install.sh` entrypoint script in the container during build time. Implementing tools are also free to process attributes under the `customizations` property as desired.
