#!/bin/bash
set -euo pipefail

echo "🔧 Installing devcontainer CLI..."
npm install -g @devcontainers/cli

FEATURES=("ag" "amazon-q-cli" "aws-sam-cli" "gcloud-cli" "zip")
BASE_IMAGES=("debian:latest" "ubuntu:latest" "mcr.microsoft.com/devcontainers/base:ubuntu")

# Run autogenerated tests for each image
for feature in "${FEATURES[@]}"; do
  for image in "${BASE_IMAGES[@]}"; do
    echo "🧪 Running autogenerated test for '$feature' on image '$image'"
    devcontainer features test --skip-scenarios -f "$feature" -i "$image" .
  done
done

# Run scenario tests
for feature in "${FEATURES[@]}"; do
  echo "🧪 Running scenario test for '$feature'"
  devcontainer features test --skip-autogenerated --skip-duplicated -f "$feature" .
done

# Run global scenarios
echo "🧪 Running global scenario tests..."
devcontainer features test --global-scenarios-only .

echo "✅ All post-create feature tests complete."
