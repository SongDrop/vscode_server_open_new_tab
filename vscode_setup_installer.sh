#!/bin/bash
set -e

# ===============================================
# Open New Tab Extension Installer
# ===============================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🚀 Installing Open New Tab VS Code Extension...${NC}"

# --- Clone ByteStash repository if not already cloned ---
if [ ! -d "vscode_server_open_new_tab" ]; then
    echo -e "${CYAN}📥 Cloning Open New Tab repository...${NC}"
    git clone https://github.com/SongDrop/vscode_server_open_new_tab.git
else
    echo -e "${YELLOW}📂 'vscode_server_open_new_tab' directory already exists. Skipping clone.${NC}"
fi

cd vscode_server_open_new_tab

# --- Make installer executable and run it ---
chmod +x ./vscode_install.sh
echo -e "${CYAN}⚡ Running vscode_server_open_new_tab installer...${NC}"
./vscode_install.sh

echo -e "${GREEN}✅ vscode_server_open_new_tab VS Code Extension installation completed!${NC}"
