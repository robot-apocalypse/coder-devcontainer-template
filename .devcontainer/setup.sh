#!/bin/bash
set -euo pipefail

echo "🚀 Bootstrapping AutoBundler project..."

echo "Fixing permissions on mounted volumes..."
sudo chown -R vscode:vscode /home/vscode/
# The workspace directory is dynamically set based on the repository name
WORKSPACE_DIR="/${REPO_NAME:-workspace}"
sudo chown -R vscode:vscode "$WORKSPACE_DIR"

# Navigate to the workspace to run project commands
cd "$WORKSPACE_DIR"

# --- The rest of your setup logic (like creating .env) goes here ---
git config --global user.email ian.buffington@gmail.com
git config --global user.name "Ian"  


echo "✅ Project setup complete!"
echo "🔥 Your development environment is ready."