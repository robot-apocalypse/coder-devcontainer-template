# Start FROM your new, versioned base image
FROM ghcr.io/robot-apocalypse/base-dev:20251001-545b8e5

# Declare build-time variables for this specific project
ARG NODE_VERSION=22.20.0
ARG TERRAFORM_VERSION=1.6.6
ARG TERRAGRUNT_VERSION=0.54.14
ARG REPO_NAME=workspace

# --- Run project-specific installations as ROOT ---
USER root

# Install project-specific language runtime (Node.js)
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then ARCH="x64"; fi && \
    curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${ARCH}.tar.xz" -o node.tar.xz && \
    tar -xJf node.tar.xz -C /usr/local --strip-components=1 --no-same-owner && \
    rm node.tar.xz

# Install project-specific global npm packages as root
RUN npm install -g yarn && \
    npm cache clean --force

# Add external APT repositories and install additional packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gnupg \
    apt-transport-https \
    ca-certificates \
    lsb-release \
    jq \
    gh \
    socat \
    iproute2 \
    xdg-utils \
    git \
    unzip \
  && \
    mkdir -p /etc/apt/keyrings && \
    # Docker Repository
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /tmp/docker.gpg && \
    gpg --batch --dearmor -o /etc/apt/keyrings/docker.gpg /tmp/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    # Google Cloud SDK Repository
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg -o /tmp/google.gpg && \
    gpg --batch --dearmor -o /etc/apt/keyrings/google.gpg /tmp/google.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee /etc/apt/sources.list.d/google-cloud-sdk.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      docker-ce \
      docker-ce-cli \
      containerd.io \
      docker-compose-plugin \
      google-cloud-sdk \
    && rm -rf /var/lib/apt/lists/* /tmp/*.gpg

# Install AWS CLI v2 and the required SSO credential process helper
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then ARCH="x86_64"; elif [ "$ARCH" = "arm64" ]; then ARCH="aarch64"; fi && \
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip" -o awscliv2.zip && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip ./aws
# Install Terraform & Terragrunt using version managers
RUN git clone --depth=1 https://github.com/tfutils/tfenv.git /usr/local/lib/tfenv && \
    git clone --depth=1 https://github.com/tgenv/tgenv.git /usr/local/lib/tgenv

# Add the shims and bin paths to the system PATH for all users
ENV PATH="/usr/local/lib/tfenv/bin:/usr/local/lib/tfenv/shims:/usr/local/lib/tgenv/bin:/usr/local/lib/tgenv/shims:${PATH}"

# Install and set the global default versions
RUN tfenv install ${TERRAFORM_VERSION} && \
    tfenv use ${TERRAFORM_VERSION} && \
    tgenv install ${TERRAGRUNT_VERSION} && \
    tgenv use ${TERRAGRUNT_VERSION}

# Add the vscode user to the docker group for DinD access
RUN usermod -aG docker vscode

# --- Switch to the non-root user for the final environment ---

# Set REPO_NAME as an environment variable
ENV REPO_NAME=${REPO_NAME}

# Switch to the non-root vscode user for security
USER vscode

# Install uv, Python, and uvicorn
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    /home/vscode/.local/bin/uv python install 3.12 && \
    /home/vscode/.local/bin/uv tool install uvicorn

# Set the default working directory
WORKDIR /${REPO_NAME}
