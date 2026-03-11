#!/bin/bash
set -e

source dev-container-features-test-lib

check "gemini version" gemini --version
check "mcp-avtool-go" mcp-avtool-go --help

check "avtool configured" jq -e '.mcpServers.avtool' ~/.gemini/settings.json
check "no imagen" jq -e '.mcpServers.imagen == null' ~/.gemini/settings.json

reportResults
