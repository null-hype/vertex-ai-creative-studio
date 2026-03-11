#!/bin/bash
set -e

echo "Starting setup script..."

# Install uv
if ! command -v uv &> /dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh -s -- --no-modify-path
fi

# Ensure uv is in PATH for this script
export PATH="$HOME/.local/bin:$PATH"

# Install Python dependencies
echo "Installing Python dependencies..."
uv sync

# Setup Go workspace and install MCP servers
echo "Setting up Go MCP servers..."
cd experiments/mcp-genmedia/mcp-genmedia-go

# Tidy workspace
go work sync

# Install all MCP servers
echo "Installing MCP servers..."
# We use a non-interactive approach for the installer or just run the commands
go install ./mcp-avtool-go ./mcp-chirp3-go ./mcp-gemini-go ./mcp-imagen-go ./mcp-lyria-go ./mcp-veo-go

echo "Setup complete!"
