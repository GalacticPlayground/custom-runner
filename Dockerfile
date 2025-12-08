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
    unzip \
    openjdk-17-jdk \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Set up Android SDK environment variables
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

# Install Android SDK command-line tools
RUN mkdir -p $ANDROID_HOME/cmdline-tools && \
    cd $ANDROID_HOME/cmdline-tools && \
    curl -o commandlinetools.zip https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip && \
    unzip commandlinetools.zip && \
    rm commandlinetools.zip && \
    mv cmdline-tools latest

# Install Android SDK components
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.1" "cmdline-tools;latest"

# Set proper permissions for Android SDK
RUN chmod -R 755 $ANDROID_HOME && \
    chown -R runner:runner $ANDROID_HOME

# Switch back to runner user for security
USER runner

# Set the entrypoint to run.sh which starts the runner
ENTRYPOINT ["/home/runner/run.sh"]
