#!/bin/bash
set -e

# Import test library
source dev-container-features-test-lib

check "agentcore command exists" bash -c 'command -v agentcore'

check "agentcore command works" agentcore --version

reportResults
