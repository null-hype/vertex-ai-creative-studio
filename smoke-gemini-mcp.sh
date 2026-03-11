#!/bin/bash
set -e

echo "Running Genmedia MCP Smoke Test..."

# Check Gemini CLI
if command -v gemini &> /dev/null; then
    echo "[PASS] Gemini CLI is installed: $(gemini --version)"
else
    echo "[FAIL] Gemini CLI is not installed."
    exit 1
fi

# Check MCP Server
if command -v mcp-avtool-go &> /dev/null; then
    echo "[PASS] mcp-avtool-go is installed."
else
    echo "[FAIL] mcp-avtool-go is not installed."
    exit 1
fi

# Check Configuration
SETTINGS_FILE="${HOME}/.gemini/settings.json"
if [ -f "${SETTINGS_FILE}" ]; then
    echo "[PASS] Gemini settings.json found at ${SETTINGS_FILE}"
    if jq -e '.mcpServers.avtool' "${SETTINGS_FILE}" > /dev/null; then
        echo "[PASS] avtool is configured in Gemini settings."
    else
        echo "[FAIL] avtool is NOT configured in Gemini settings."
        exit 1
    fi
else
    echo "[FAIL] Gemini settings.json NOT found."
    exit 1
fi

echo "Smoke Test Completed Successfully!"
