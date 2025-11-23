# Custom GitHub Actions Runner with build tools
# Based on the official GitHub runner image
FROM ghcr.io/actions/actions-runner:latest

# Switch to root to install packages
USER root

# Install build tools needed for native Node.js modules
RUN apt-get update && apt-get install -y \
    build-essential \
    make \
    g++ \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Switch back to runner user for security
USER runner
