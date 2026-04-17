# AgentCore CLI (`agentcore-cli`)

This feature installs the [Amazon Bedrock AgentCore CLI](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/agentcore-get-started-cli.html) from npm (`@aws/agentcore`). Source repository: [aws/agentcore-cli](https://github.com/aws/agentcore-cli).

## Dependencies

Node.js is declared as a **hard** dependency in `devcontainer-feature.json` via `dependsOn` on `ghcr.io/devcontainers/features/node:1` with `version: lts`, so the LTS Node line is installed before this feature and satisfies the AgentCore requirement of Node.js 20 or later.

`installsAfter` includes `common-utils` for consistent ordering when you also add that feature to your dev container.

## Options

| Option            | Type   | Default | Description                                                 |
| ----------------- | ------ | ------- | ----------------------------------------------------------  |
| `packageVersion`  | string | `""`    | npm semver or dist-tag for `@aws/agentcore`; empty = latest |

## Usage

Add the feature to `.devcontainer/devcontainer.json`. You only need to reference this feature; Node is pulled in automatically.

```jsonc
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/jajera/features/agentcore-cli:1": {
      "packageVersion": ""
    }
  }
}
```

Pin an npm version when needed:

```jsonc
"ghcr.io/jajera/features/agentcore-cli:1": {
  "packageVersion": "1.0.0"
}
```

## Verification

After the container builds:

```bash
agentcore --version
```

## Notes

- This feature does not configure AWS credentials, the AWS CLI, Python, or CDK; add other features or image setup as needed for `agentcore deploy` and local development.
