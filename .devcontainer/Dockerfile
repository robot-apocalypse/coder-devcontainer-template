# Start FROM your new personal base image in GHCR
# Replace 'robot-apocalypse' with your GitHub username if it's different
FROM ghcr.io/robot-apocalypse/base-dev:latest

# Declare build-time variables after FROM to ensure they are in scope
ARG NODE_VERSION=22
ARG TERRAFORM_VERSION=1.6.6
ARG REPO_NAME=workspace

# Switch to root user to install project-specific packages
USER root

# RUN 1: Add external APT repositories and install their main packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Add prerequisites for adding new repos
    curl \
    gnupg \
    apt-transport-https \
    ca-certificates \
    lsb-release \
    # Add project-specific CLI tools
    jq \
    gh \
  && \
    # --- Setup external software repositories ---
    echo "Setting up external software repositories..." >&2 && \
    # Docker Repository
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    # Google Cloud SDK Repository
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee /etc/apt/sources.list.d/google-cloud-sdk.list && \
    # --- Install all APT packages at once ---
    echo "Installing packages from all repositories..." >&2 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      docker-ce-cli \
      google-cloud-sdk \
      xdg-utils \
    && rm -rf /var/lib/apt/lists/*

# RUN 2: Install Terraform (which doesn't have an APT repo)
RUN echo "Installing Terraform..." >&2 && \
    wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Set REPO_NAME as environment variable
ENV REPO_NAME=${REPO_NAME}

# Switch back to the non-root vscode user
USER vscode

# RUN 3: Install nvm and Node.js as vscode user
RUN echo "Installing nvm and Node.js..." >&2 && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash && \
    export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
    nvm install ${NODE_VERSION} && \
    nvm use ${NODE_VERSION} && \
    nvm alias default ${NODE_VERSION}

# RUN 4: Install Global NPM Packages for the project as vscode user
RUN echo "Installing global npm packages..." >&2 && \
    export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
    npm install -g yarn firebase-tools @shopify/cli @shopify/theme

# Set the default working directory for the final container
WORKDIR /${REPO_NAME}