#!/bin/bash
set -e

# ===============================================
# vscode_server_open_new_tab VS Code Extension Installer
# ===============================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🚀 Installing vscode_server_open_new_tab VS Code Extension...${NC}"

echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║           vscode_server_open_new_tab VS Code Installer        ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# --- Ensure we are in the extension directory ---
if [ ! -f "package.json" ]; then
    echo -e "${RED}❌ Please run this script from the vscode_server_open_new_tab extension directory${NC}"
    exit 1
fi

# --- Load Node environment (optional NVM) ---
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
export NODE_OPTIONS=--openssl-legacy-provider

echo -e "${YELLOW}Node version: $(node -v)${NC}"
echo -e "${YELLOW}npm version: $(npm -v)${NC}"

# --- Node.js & TypeScript setup ---
echo -e "${CYAN}📦 Installing Node.js dependencies...${NC}"
if [ ! -d "node_modules" ]; then
    npm install
fi

# Install TypeScript globally if missing
if ! command -v tsc &> /dev/null; then
    npm install -g typescript
fi

# Compile TypeScript
echo -e "${CYAN}🔨 Compiling TypeScript...${NC}"
npm run compile

# --- Package VS Code Extension ---
echo -e "${CYAN}📦 Packaging VS Code extension...${NC}"

if ! command -v vsce &> /dev/null; then
    echo -e "${RED}⚠️ VSCE not installed. Install with: npm install -g vsce${NC}"
    exit 1
fi

vsce package --allow-missing-repository

# Detect the .vsix file dynamically
VSIX_FILE=$(ls vscode_server_open_new_tab-*.vsix 2>/dev/null | head -n1)

if [ ! -f "$VSIX_FILE" ]; then
    echo -e "${RED}❌ Failed to package extension.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Extension packaged: $VSIX_FILE${NC}"

# --- Detect environment and install accordingly ---
if command -v code-server &> /dev/null; then
    echo -e "${YELLOW}🔧 Detected code-server environment.${NC}"

    # Default locations
    CS_USER_DATA_DIR="${HOME}/.local/share/code-server"
    CS_EXT_DIR="${CS_USER_DATA_DIR}/extensions"

    # Try to detect active code-server process and extract custom paths
    CS_PID=$(pgrep -af "code-server" | head -n1 | awk '{print $1}')
    if [ -n "$CS_PID" ] && ps -p "$CS_PID" > /dev/null 2>&1; then
        CS_CMD=$(ps -p "$CS_PID" -o args=)
        if [[ "$CS_CMD" =~ --user-data-dir[=\ ]([^[:space:]]+) ]]; then
            CS_USER_DATA_DIR="${BASH_REMATCH[1]}"
        fi
        if [[ "$CS_CMD" =~ --extensions-dir[=\ ]([^[:space:]]+) ]]; then
            CS_EXT_DIR="${BASH_REMATCH[1]}"
        fi
    fi

    echo -e "${CYAN}📁 Using code-server data dir:${NC} $CS_USER_DATA_DIR"
    echo -e "${CYAN}📁 Using extensions dir:${NC} $CS_EXT_DIR"

    echo -e "${YELLOW}🔧 Installing extension in code-server...${NC}"
    code-server --install-extension "$VSIX_FILE" \
        --force \
        --user-data-dir "$CS_USER_DATA_DIR" \
        --extensions-dir "$CS_EXT_DIR"

    # Verify installation
    if code-server --list-extensions | grep -q "vscode_server_open_new_tab"; then
        echo -e "${GREEN}✅ vscode_server_open_new_tab extension installed in code-server!${NC}"
    else
        echo -e "${RED}❌ Installation command completed but vscode_server_open_new_tab not detected.${NC}"
        echo -e "${YELLOW}👉 Try manually running:${NC}"
        echo "   code-server --install-extension \"$VSIX_FILE\" --force --user-data-dir \"$CS_USER_DATA_DIR\" --extensions-dir \"$CS_EXT_DIR\""
    fi

else
    echo -e "${YELLOW}🔧 Installing extension in VS Code...${NC}"
    code --install-extension "$VSIX_FILE" --force
    echo -e "${GREEN}✅ vscode_server_open_new_tab extension installed successfully!${NC}"
fi



# --- Final instructions ---
echo ""
echo "🎉 Installation complete!"
echo ""
echo "To use vscode_server_open_new_tab extension in VS Code:"
echo "1. Open a workspace in VS Code"
echo "2. Open the Command Palette (Cmd+Shift+P / Ctrl+Shift+P)"
echo "3. Search for 'Open in new Tab...'"
echo "4. Configure extension settings under Preferences → Settings → Extensions → ByteStash"
echo ""

