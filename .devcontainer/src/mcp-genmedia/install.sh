#!/bin/bash
set -e

# Options
INSTALLALL="${INSTALLALL:-"false"}"
INSTALLAVTOOL="${INSTALLAVTOOL:-"true"}"
INSTALLCHIRP="${INSTALLCHIRP:-"false"}"
INSTALLGEMINI="${INSTALLGEMINI:-"false"}"
INSTALLIMAGEN="${INSTALLIMAGEN:-"false"}"
INSTALLLYRIA="${INSTALLLYRIA:-"false"}"
INSTALLVEO="${INSTALLVEO:-"false"}"

echo "Activating feature 'mcp-genmedia'"

# Install system dependencies
apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    jq \
    curl \
    ca-certificates \
    git

# Install Gemini CLI and DevContainer CLI
npm install -g @google/gemini-cli @devcontainers/cli

# MCP Servers to install
SERVERS=()
if [ "${INSTALLALL}" = "true" ]; then
    SERVERS=("mcp-avtool-go" "mcp-chirp3-go" "mcp-gemini-go" "mcp-imagen-go" "mcp-lyria-go" "mcp-veo-go")
else
    [ "${INSTALLAVTOOL}" = "true" ] && SERVERS+=("mcp-avtool-go")
    [ "${INSTALLCHIRP}" = "true" ] && SERVERS+=("mcp-chirp3-go")
    [ "${INSTALLGEMINI}" = "true" ] && SERVERS+=("mcp-gemini-go")
    [ "${INSTALLIMAGEN}" = "true" ] && SERVERS+=("mcp-imagen-go")
    [ "${INSTALLLYRIA}" = "true" ] && SERVERS+=("mcp-lyria-go")
    [ "${INSTALLVEO}" = "true" ] && SERVERS+=("mcp-veo-go")
fi

# Ensure go is in PATH (it should be if go feature is used)
# We check common locations and try to use go env if available
export PATH=$PATH:/usr/local/go/bin:/usr/local/bin:/root/go/bin
if command -v go &> /dev/null; then
    export PATH=$PATH:$(go env GOPATH)/bin
fi

if ! command -v go &> /dev/null; then
    echo "Go is not installed. MCP servers will not be built. Please ensure a Go feature is included."
else
    # To build the servers, we need the source code.
    # Since we are in the feature installation phase, we might not have the workspace.
    # We'll clone the repository to a temporary directory to build the servers.
    TEMP_DIR=$(mktemp -d)
    echo "Cloning repository to build MCP servers in ${TEMP_DIR}..."
    git clone --depth 1 https://github.com/GoogleCloudPlatform/vertex-ai-creative-studio.git "${TEMP_DIR}"

    cd "${TEMP_DIR}/experiments/mcp-genmedia/mcp-genmedia-go"
    go work sync

    for server in "${SERVERS[@]}"; do
        echo "Building and installing ${server}..."
        GOBIN=/usr/local/bin go install "./${server}"
    done

    cd /
    rm -rf "${TEMP_DIR}"
fi

# Configure Gemini CLI
# Determine the user to configure for
TARGET_USER="${_REMOTE_USER:-"root"}"
if [ "${TARGET_USER}" = "none" ] || [ "${TARGET_USER}" = "root" ]; then
    TARGET_USER="root"
    USER_HOME="/root"
else
    USER_HOME=$(getent passwd "${TARGET_USER}" | cut -d: -f6)
fi

GEMINI_DIR="${USER_HOME}/.gemini"
mkdir -p "${GEMINI_DIR}"

SETTINGS_FILE="${GEMINI_DIR}/settings.json"
if [ ! -f "${SETTINGS_FILE}" ]; then
    echo '{"mcpServers": {}}' > "${SETTINGS_FILE}"
fi

for server in "${SERVERS[@]}"; do
    NAME="${server%-go}"
    NAME="${NAME#mcp-}"
    [ "${NAME}" = "chirp3" ] && NAME="chirp3-hd"

    echo "Configuring ${NAME} in Gemini CLI settings..."

    # Use jq to update settings.json
    # We omit PROJECT_ID and GENMEDIA_BUCKET so they are inherited from the environment.
    TMP_SETTINGS=$(mktemp)
    jq --arg name "$NAME" --arg cmd "$server" '.mcpServers[$name] = {
        "command": $cmd,
        "env": {
            "MCP_SERVER_REQUEST_TIMEOUT": "55000"
        }
    }' "${SETTINGS_FILE}" > "${TMP_SETTINGS}" && mv "${TMP_SETTINGS}" "${SETTINGS_FILE}"
done

# Set ownership if we created the directory
chown -R "${TARGET_USER}:${TARGET_USER}" "${GEMINI_DIR}" || true

echo "MCP Genmedia feature installation finished."
