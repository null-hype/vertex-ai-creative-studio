FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-22.04

# Install system dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    jq \
    curl \
    git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
