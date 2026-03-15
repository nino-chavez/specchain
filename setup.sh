#!/bin/bash

# Specchain Setup Script
# Usage: ./setup.sh /path/to/your/project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}"
echo "  ___                 _       _"
echo " / __|_ __  ___ __  _| |_  __| |_ ___ _ _"
echo " \__ \ '_ \/ -_) _|/ _| ' \/ _\` | / -_) '_|"
echo " |___/ .__/\___\__|_\__|_||_\__,_|_\___|_|"
echo "     |_|"
echo -e "${NC}"
echo "Spec-driven development workflow for Claude Code"
echo ""

# Check if target directory is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Please provide the target project directory${NC}"
    echo ""
    echo "Usage: ./setup.sh /path/to/your/project"
    echo ""
    echo "Example:"
    echo "  ./setup.sh ~/projects/my-app"
    exit 1
fi

TARGET_DIR="$1"

# Check if target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}Error: Target directory does not exist: $TARGET_DIR${NC}"
    exit 1
fi

echo -e "Target: ${GREEN}$TARGET_DIR${NC}"
echo ""

# Check for existing specchain
if [ -d "$TARGET_DIR/specchain" ]; then
    echo -e "${YELLOW}Warning: specchain directory already exists${NC}"
    read -p "Overwrite? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
    rm -rf "$TARGET_DIR/specchain"
fi

# Check for existing .claude/commands/specchain
if [ -d "$TARGET_DIR/.claude/commands/specchain" ]; then
    echo -e "${YELLOW}Warning: .claude/commands/specchain already exists${NC}"
    read -p "Overwrite? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

# Check for existing .claude/agents/specchain
if [ -d "$TARGET_DIR/.claude/agents/specchain" ]; then
    echo -e "${YELLOW}Warning: .claude/agents/specchain already exists${NC}"
    read -p "Overwrite? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

# Copy specchain directory
echo "Installing specchain..."
cp -r "$SCRIPT_DIR/specchain" "$TARGET_DIR/"

# Create .claude directories if they don't exist
mkdir -p "$TARGET_DIR/.claude/commands"
mkdir -p "$TARGET_DIR/.claude/agents"

# Remove existing and copy fresh
rm -rf "$TARGET_DIR/.claude/commands/specchain" 2>/dev/null || true
rm -rf "$TARGET_DIR/.claude/agents/specchain" 2>/dev/null || true

# Copy command files
echo "Installing commands..."
cp -r "$SCRIPT_DIR/.claude/commands/specchain" "$TARGET_DIR/.claude/commands/"

# Copy agent files
echo "Installing agents..."
cp -r "$SCRIPT_DIR/.claude/agents/specchain" "$TARGET_DIR/.claude/agents/"

# Create specs directory
mkdir -p "$TARGET_DIR/specchain/specs"

echo ""

# --- Governance Templates ---
echo ""
echo -e "${BLUE}Governance Templates${NC}"
read -p "Generate CLAUDE.md and .cursorrules for this project? (y/n) " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Project name: " GOV_PROJECT_NAME
    read -p "One-line description: " GOV_DESCRIPTION
    read -p "Language (e.g. TypeScript): " GOV_LANGUAGE
    read -p "Framework (e.g. Next.js): " GOV_FRAMEWORK

    # Default commands based on common patterns
    GOV_CMD_INSTALL="npm install"
    GOV_CMD_DEV="npm run dev"
    GOV_CMD_BUILD="npm run build"
    GOV_CMD_TEST="npm test"
    GOV_CMD_TYPECHECK="npx tsc --noEmit"
    GOV_DATE="$(date +%Y-%m-%d)"

    # Generate CLAUDE.md
    echo "Generating CLAUDE.md..."
    sed -e "s|{{PROJECT_NAME}}|${GOV_PROJECT_NAME}|g" \
        -e "s|{{PROJECT_DESCRIPTION}}|${GOV_DESCRIPTION}|g" \
        -e "s|{{LANGUAGE}}|${GOV_LANGUAGE}|g" \
        -e "s|{{FRAMEWORK}}|${GOV_FRAMEWORK}|g" \
        -e "s|{{CMD_INSTALL}}|${GOV_CMD_INSTALL}|g" \
        -e "s|{{CMD_DEV}}|${GOV_CMD_DEV}|g" \
        -e "s|{{CMD_BUILD}}|${GOV_CMD_BUILD}|g" \
        -e "s|{{CMD_TEST}}|${GOV_CMD_TEST}|g" \
        -e "s|{{CMD_TYPECHECK}}|${GOV_CMD_TYPECHECK}|g" \
        "$TARGET_DIR/specchain/governance/claude-md.tmpl" > "$TARGET_DIR/CLAUDE.md"

    # Generate .cursorrules
    echo "Generating .cursorrules..."
    sed -e "s|{{PROJECT_NAME}}|${GOV_PROJECT_NAME}|g" \
        -e "s|{{PROJECT_DESCRIPTION}}|${GOV_DESCRIPTION}|g" \
        -e "s|{{LANGUAGE}}|${GOV_LANGUAGE}|g" \
        -e "s|{{FRAMEWORK}}|${GOV_FRAMEWORK}|g" \
        -e "s|{{CMD_INSTALL}}|${GOV_CMD_INSTALL}|g" \
        -e "s|{{CMD_DEV}}|${GOV_CMD_DEV}|g" \
        -e "s|{{CMD_BUILD}}|${GOV_CMD_BUILD}|g" \
        -e "s|{{CMD_TEST}}|${GOV_CMD_TEST}|g" \
        -e "s|{{CMD_TYPECHECK}}|${GOV_CMD_TYPECHECK}|g" \
        -e "s|{{DATE}}|${GOV_DATE}|g" \
        "$TARGET_DIR/specchain/governance/cursorrules.tmpl" > "$TARGET_DIR/.cursorrules"

    echo -e "${GREEN}Generated CLAUDE.md and .cursorrules${NC}"
else
    echo -e "Skipped. Raw templates available at:"
    echo "  ${YELLOW}specchain/governance/claude-md.tmpl${NC}"
    echo "  ${YELLOW}specchain/governance/cursorrules.tmpl${NC}"
fi

echo ""
echo -e "${GREEN}Specchain installed successfully!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo ""
echo "  1. Configure your project:"
echo "     ${YELLOW}Edit specchain/config.yml${NC}"
echo ""
echo "  2. Set your tech stack:"
echo "     ${YELLOW}Edit specchain/standards/global/tech-stack.md${NC}"
echo ""
echo "  3. Define your agents:"
echo "     ${YELLOW}Edit specchain/roles/implementers.yml${NC}"
echo ""
echo "  4. Create your first spec:"
echo "     ${YELLOW}/new-spec [description]${NC}"
echo ""
echo -e "${BLUE}Available commands:${NC}"
echo "  /new-spec        - Initialize a new spec with requirements gathering"
echo "  /create-spec     - Generate spec.md and tasks.md from requirements"
echo "  /implement-spec  - Implement a specification"
echo "  /plan-product    - Plan product roadmap"
echo ""
