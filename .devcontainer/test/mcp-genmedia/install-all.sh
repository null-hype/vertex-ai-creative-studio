#!/bin/bash
set -e

source dev-container-features-test-lib

check "gemini version" gemini --version
check "mcp-avtool-go" mcp-avtool-go --help
check "mcp-chirp3-go" mcp-chirp3-go --help
check "mcp-gemini-go" mcp-gemini-go --help
check "mcp-imagen-go" mcp-imagen-go --help
check "mcp-lyria-go" mcp-lyria-go --help
check "mcp-veo-go" mcp-veo-go --help

check "avtool configured" jq -e '.mcpServers.avtool' ~/.gemini/settings.json
check "chirp3-hd configured" jq -e '.mcpServers["chirp3-hd"]' ~/.gemini/settings.json
check "gemini configured" jq -e '.mcpServers.gemini' ~/.gemini/settings.json
check "imagen configured" jq -e '.mcpServers.imagen' ~/.gemini/settings.json
check "lyria configured" jq -e '.mcpServers.lyria' ~/.gemini/settings.json
check "veo configured" jq -e '.mcpServers.veo' ~/.gemini/settings.json

reportResults
