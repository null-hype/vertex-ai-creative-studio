#!/bin/bash
set -e

# Import test library
source dev-container-features-test-lib

# Check for Gemini CLI
check "gemini version" gemini --version

# Check for AVTool (default)
check "mcp-avtool-go version" mcp-avtool-go --help

# Check settings.json
check "settings.json exists" ls ~/.gemini/settings.json
check "avtool configured" jq -e '.mcpServers.avtool' ~/.gemini/settings.json

# Report results
reportResults
