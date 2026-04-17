#!/bin/sh
set -e

echo "Activating feature 'agentcore-cli'"

PACKAGEVERSION="${PACKAGEVERSION:-}"

if command -v agentcore >/dev/null 2>&1; then
    echo "AgentCore CLI is already installed. Skipping install."
    agentcore --version
    exit 0
fi

if ! command -v node >/dev/null 2>&1; then
    echo "ERROR: node is not on PATH. The node feature (dependsOn) should install it."
    exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
    echo "ERROR: npm is not on PATH."
    exit 1
fi

NODE_MAJOR=$(node -p 'parseInt(process.versions.node.split(".")[0], 10)' 2>/dev/null || echo 0)
if [ "$NODE_MAJOR" -lt 20 ]; then
    echo "ERROR: Node.js 20 or later is required for AgentCore CLI (found $(node --version 2>/dev/null || echo unknown))."
    exit 1
fi

SPEC='@aws/agentcore'
if [ -n "$PACKAGEVERSION" ]; then
    SPEC="@aws/agentcore@${PACKAGEVERSION}"
fi

echo "Installing AgentCore CLI (${SPEC}) via npm..."
npm install -g "$SPEC"

if ! command -v agentcore >/dev/null 2>&1; then
    echo "ERROR: agentcore was not found on PATH after npm install."
    exit 1
fi

echo "AgentCore CLI installed successfully."
agentcore --version
