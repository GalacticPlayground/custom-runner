# Custom GitHub Actions Runner with build tools
# Based on the official GitHub runner image
FROM ghcr.io/actions/actions-runner:latest

# Switch to root to install packages
USER root

# Install build tools and GitHub CLI
RUN apt-get update && apt-get install -y \
    build-essential \
    make \
    g++ \
    python3 \
    python3-pip \
    curl \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Switch back to runner user for security
USER runner

# Set the entrypoint to run.sh which starts the runner
ENTRYPOINT ["/home/runner/run.sh"]
