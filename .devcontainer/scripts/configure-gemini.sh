#!/bin/bash
set -e

echo "Configuring Gemini CLI for MCP Genmedia..."

# Ensure GOPATH is set
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

# Create the `gemini` executable wrapper
# We use sudo if needed, but in devcontainer we are usually vscode user with sudo rights or root
if command -v sudo &> /dev/null; then
    sudo bash -c 'cat > /usr/local/bin/gemini << "EOL"
#!/bin/bash
exec npx https://github.com/google-gemini/gemini-cli "$@"
EOL'
    sudo chmod +x /usr/local/bin/gemini
else
    cat > /tmp/gemini << "EOL"
#!/bin/bash
exec npx https://github.com/google-gemini/gemini-cli "$@"
EOL
    # Try to move to /usr/local/bin if possible, or just add to path
    mv /tmp/gemini $HOME/.local/bin/gemini
    chmod +x $HOME/.local/bin/gemini
fi

echo "Gemini CLI wrapper created."

# Create the Gemini CLI extensions directory
mkdir -p ~/.gemini/extensions/google-genmedia-extension/
echo "Gemini extensions directory created."

# Substitute environment variables into the template and save the final config
# If envsubst is not available, we can use a simple sed or python script
if command -v envsubst &> /dev/null; then
    envsubst '$GOPATH $PROJECT_ID $LOCATION $GENMEDIA_BUCKET' < .devcontainer/configs/gemini-extension.json \
      > ~/.gemini/extensions/google-genmedia-extension/gemini-extension.json
else
    # Fallback using python if envsubst is missing
    python3 -c "import os, sys; content = sys.stdin.read(); \
      content = content.replace('\${GOPATH}', os.environ.get('GOPATH', '')) \
               .replace('\${PROJECT_ID}', os.environ.get('PROJECT_ID', '')) \
               .replace('\${LOCATION}', os.environ.get('LOCATION', '')) \
               .replace('\${GENMEDIA_BUCKET}', os.environ.get('GENMEDIA_BUCKET', '')); \
      print(content)" < .devcontainer/configs/gemini-extension.json \
      > ~/.gemini/extensions/google-genmedia-extension/gemini-extension.json
fi

echo "Gemini extension configuration created."
echo "Gemini CLI configuration complete!"
