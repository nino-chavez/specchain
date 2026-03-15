#!/bin/bash

# Specchain Setup Script
# Usage: ./setup.sh [--upgrade] /path/to/your/project

set -e

SPECCHAIN_VERSION="1.1.0"

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
echo "Spec-driven development workflow for Claude Code (v${SPECCHAIN_VERSION})"
echo ""

# --- Parse flags ---
UPGRADE_MODE=false
if [ "$1" = "--upgrade" ]; then
    UPGRADE_MODE=true
    shift
fi

# Check if target directory is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Please provide the target project directory${NC}"
    echo ""
    echo "Usage: ./setup.sh /path/to/your/project"
    echo "       ./setup.sh --upgrade /path/to/your/project"
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

# --- Upgrade mode: check manifest ---
if [ "$UPGRADE_MODE" = true ]; then
    MANIFEST="$TARGET_DIR/.specchain-manifest"
    if [ ! -f "$MANIFEST" ]; then
        echo -e "${RED}Error: No .specchain-manifest found. Run a full install first.${NC}"
        echo "  ./setup.sh $TARGET_DIR"
        exit 1
    fi
    echo -e "${BLUE}Upgrade mode: checking for locally modified files...${NC}"
    MODIFIED_FILES=()
    while IFS=: read -r filepath checksum; do
        [[ "$filepath" =~ ^#.* ]] && continue
        [[ -z "$filepath" ]] && continue
        if [ -f "$TARGET_DIR/$filepath" ]; then
            current_checksum=$(shasum -a 256 "$TARGET_DIR/$filepath" | cut -d' ' -f1)
            if [ "$current_checksum" != "$checksum" ]; then
                MODIFIED_FILES+=("$filepath")
            fi
        fi
    done < "$MANIFEST"

    if [ ${#MODIFIED_FILES[@]} -gt 0 ]; then
        echo -e "${YELLOW}The following files have been locally modified:${NC}"
        for f in "${MODIFIED_FILES[@]}"; do
            echo "  - $f"
        done
        echo ""
        read -p "Overwrite modified files? (y/n/list) " -r
        if [[ $REPLY =~ ^[Ll] ]]; then
            for f in "${MODIFIED_FILES[@]}"; do
                echo ""
                echo -e "${YELLOW}--- $f ---${NC}"
                diff "$TARGET_DIR/$f" "$SCRIPT_DIR/$f" 2>/dev/null || echo "(new file in source)"
            done
            echo ""
            read -p "Overwrite modified files? (y/n) " -r
        fi
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Skipping modified files. Upgrading only unmodified files.${NC}"
        fi
    fi
    echo ""
fi

# --- Collect all overwrite decisions upfront (non-upgrade mode) ---
OVERWRITE_SPECCHAIN=false
OVERWRITE_COMMANDS=false
OVERWRITE_AGENTS=false

if [ "$UPGRADE_MODE" = false ]; then
    if [ -d "$TARGET_DIR/specchain" ]; then
        echo -e "${YELLOW}Warning: specchain directory already exists${NC}"
        read -p "Overwrite? (y/n) " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] && OVERWRITE_SPECCHAIN=true || echo "  Will preserve existing specchain/"
    fi

    if [ -d "$TARGET_DIR/.claude/commands/specchain" ]; then
        echo -e "${YELLOW}Warning: .claude/commands/specchain already exists${NC}"
        read -p "Overwrite? (y/n) " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] && OVERWRITE_COMMANDS=true || echo "  Will preserve existing commands/"
    fi

    if [ -d "$TARGET_DIR/.claude/agents/specchain" ]; then
        echo -e "${YELLOW}Warning: .claude/agents/specchain already exists${NC}"
        read -p "Overwrite? (y/n) " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] && OVERWRITE_AGENTS=true || echo "  Will preserve existing agents/"
    fi

    # Abort if nothing to install
    if [ -d "$TARGET_DIR/specchain" ] && [ "$OVERWRITE_SPECCHAIN" = false ] && \
       [ -d "$TARGET_DIR/.claude/commands/specchain" ] && [ "$OVERWRITE_COMMANDS" = false ] && \
       [ -d "$TARGET_DIR/.claude/agents/specchain" ] && [ "$OVERWRITE_AGENTS" = false ]; then
        echo ""
        echo -e "${YELLOW}Nothing to install. All components preserved.${NC}"
        exit 0
    fi
fi

# --- Execute collected decisions ---
echo ""
echo "Installing specchain..."

if [ "$UPGRADE_MODE" = true ] || [ "$OVERWRITE_SPECCHAIN" = true ]; then
    rm -rf "$TARGET_DIR/specchain"
    cp -r "$SCRIPT_DIR/specchain" "$TARGET_DIR/"
elif [ ! -d "$TARGET_DIR/specchain" ]; then
    cp -r "$SCRIPT_DIR/specchain" "$TARGET_DIR/"
fi

mkdir -p "$TARGET_DIR/.claude/commands" "$TARGET_DIR/.claude/agents"

if [ "$UPGRADE_MODE" = true ] || [ "$OVERWRITE_COMMANDS" = true ]; then
    rm -rf "$TARGET_DIR/.claude/commands/specchain"
    cp -r "$SCRIPT_DIR/.claude/commands/specchain" "$TARGET_DIR/.claude/commands/"
elif [ ! -d "$TARGET_DIR/.claude/commands/specchain" ]; then
    cp -r "$SCRIPT_DIR/.claude/commands/specchain" "$TARGET_DIR/.claude/commands/"
fi

if [ "$UPGRADE_MODE" = true ] || [ "$OVERWRITE_AGENTS" = true ]; then
    rm -rf "$TARGET_DIR/.claude/agents/specchain"
    cp -r "$SCRIPT_DIR/.claude/agents/specchain" "$TARGET_DIR/.claude/agents/"
elif [ ! -d "$TARGET_DIR/.claude/agents/specchain" ]; then
    cp -r "$SCRIPT_DIR/.claude/agents/specchain" "$TARGET_DIR/.claude/agents/"
fi

# Create specs and state directories
mkdir -p "$TARGET_DIR/specchain/specs"
mkdir -p "$TARGET_DIR/specchain/state"

echo ""

# --- .gitignore guidance (F3) ---
GITIGNORE_ENTRIES="
# Specchain — session state and implementation artifacts
specchain/state/
specchain/specs/*/implementation/
specchain/specs/*/verification/screenshots/
specchain/specs/*/planning/progress.yml
.specchain-manifest"

if [ -f "$TARGET_DIR/.gitignore" ]; then
    if ! grep -q "# Specchain" "$TARGET_DIR/.gitignore" 2>/dev/null; then
        read -p "Append specchain patterns to .gitignore? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "$GITIGNORE_ENTRIES" >> "$TARGET_DIR/.gitignore"
            echo -e "${GREEN}Updated .gitignore${NC}"
        fi
    fi
elif [ -d "$TARGET_DIR/.git" ]; then
    read -p "Create .gitignore with specchain patterns? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "$GITIGNORE_ENTRIES" > "$TARGET_DIR/.gitignore"
        echo -e "${GREEN}Created .gitignore${NC}"
    fi
fi

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

    # Export for envsubst
    export GOV_PROJECT_NAME GOV_DESCRIPTION GOV_LANGUAGE GOV_FRAMEWORK
    export GOV_CMD_INSTALL GOV_CMD_DEV GOV_CMD_BUILD GOV_CMD_TEST GOV_CMD_TYPECHECK
    export GOV_DATE

    # Generate CLAUDE.md and .cursorrules using envsubst (safe from injection)
    if command -v envsubst &> /dev/null; then
        echo "Generating CLAUDE.md..."
        envsubst < "$TARGET_DIR/specchain/governance/claude-md.tmpl" > "$TARGET_DIR/CLAUDE.md"

        echo "Generating .cursorrules..."
        envsubst < "$TARGET_DIR/specchain/governance/cursorrules.tmpl" > "$TARGET_DIR/.cursorrules"

        echo "Generating .windsurfrules..."
        envsubst < "$TARGET_DIR/specchain/governance/windsurfrules.tmpl" > "$TARGET_DIR/.windsurfrules"
    else
        echo -e "${YELLOW}Note: envsubst not found, using escaped sed fallback${NC}"
        # Escape sed special characters in user inputs
        escape_sed() { printf '%s\n' "$1" | sed 's/[&/\]/\\&/g'; }

        echo "Generating CLAUDE.md..."
        sed -e "s|\${GOV_PROJECT_NAME}|$(escape_sed "$GOV_PROJECT_NAME")|g" \
            -e "s|\${GOV_DESCRIPTION}|$(escape_sed "$GOV_DESCRIPTION")|g" \
            -e "s|\${GOV_LANGUAGE}|$(escape_sed "$GOV_LANGUAGE")|g" \
            -e "s|\${GOV_FRAMEWORK}|$(escape_sed "$GOV_FRAMEWORK")|g" \
            -e "s|\${GOV_CMD_INSTALL}|$(escape_sed "$GOV_CMD_INSTALL")|g" \
            -e "s|\${GOV_CMD_DEV}|$(escape_sed "$GOV_CMD_DEV")|g" \
            -e "s|\${GOV_CMD_BUILD}|$(escape_sed "$GOV_CMD_BUILD")|g" \
            -e "s|\${GOV_CMD_TEST}|$(escape_sed "$GOV_CMD_TEST")|g" \
            -e "s|\${GOV_CMD_TYPECHECK}|$(escape_sed "$GOV_CMD_TYPECHECK")|g" \
            "$TARGET_DIR/specchain/governance/claude-md.tmpl" > "$TARGET_DIR/CLAUDE.md"

        echo "Generating .cursorrules..."
        sed -e "s|\${GOV_PROJECT_NAME}|$(escape_sed "$GOV_PROJECT_NAME")|g" \
            -e "s|\${GOV_DESCRIPTION}|$(escape_sed "$GOV_DESCRIPTION")|g" \
            -e "s|\${GOV_LANGUAGE}|$(escape_sed "$GOV_LANGUAGE")|g" \
            -e "s|\${GOV_FRAMEWORK}|$(escape_sed "$GOV_FRAMEWORK")|g" \
            -e "s|\${GOV_CMD_INSTALL}|$(escape_sed "$GOV_CMD_INSTALL")|g" \
            -e "s|\${GOV_CMD_DEV}|$(escape_sed "$GOV_CMD_DEV")|g" \
            -e "s|\${GOV_CMD_BUILD}|$(escape_sed "$GOV_CMD_BUILD")|g" \
            -e "s|\${GOV_CMD_TEST}|$(escape_sed "$GOV_CMD_TEST")|g" \
            -e "s|\${GOV_CMD_TYPECHECK}|$(escape_sed "$GOV_CMD_TYPECHECK")|g" \
            -e "s|\${GOV_DATE}|$(escape_sed "$GOV_DATE")|g" \
            "$TARGET_DIR/specchain/governance/cursorrules.tmpl" > "$TARGET_DIR/.cursorrules"

        echo "Generating .windsurfrules..."
        sed -e "s|\${GOV_PROJECT_NAME}|$(escape_sed "$GOV_PROJECT_NAME")|g" \
            -e "s|\${GOV_DESCRIPTION}|$(escape_sed "$GOV_DESCRIPTION")|g" \
            -e "s|\${GOV_LANGUAGE}|$(escape_sed "$GOV_LANGUAGE")|g" \
            -e "s|\${GOV_FRAMEWORK}|$(escape_sed "$GOV_FRAMEWORK")|g" \
            -e "s|\${GOV_CMD_INSTALL}|$(escape_sed "$GOV_CMD_INSTALL")|g" \
            -e "s|\${GOV_CMD_DEV}|$(escape_sed "$GOV_CMD_DEV")|g" \
            -e "s|\${GOV_CMD_BUILD}|$(escape_sed "$GOV_CMD_BUILD")|g" \
            -e "s|\${GOV_CMD_TEST}|$(escape_sed "$GOV_CMD_TEST")|g" \
            -e "s|\${GOV_CMD_TYPECHECK}|$(escape_sed "$GOV_CMD_TYPECHECK")|g" \
            "$TARGET_DIR/specchain/governance/windsurfrules.tmpl" > "$TARGET_DIR/.windsurfrules"
    fi

    echo -e "${GREEN}Generated CLAUDE.md, .cursorrules, and .windsurfrules${NC}"
else
    echo -e "Skipped. Raw templates available at:"
    echo "  ${YELLOW}specchain/governance/claude-md.tmpl${NC}"
    echo "  ${YELLOW}specchain/governance/cursorrules.tmpl${NC}"
    echo "  ${YELLOW}specchain/governance/windsurfrules.tmpl${NC}"
fi

# --- Generate manifest (F15) ---
MANIFEST="$TARGET_DIR/.specchain-manifest"
echo "# Specchain install manifest — do not edit" > "$MANIFEST"
echo "# version:${SPECCHAIN_VERSION} date:$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$MANIFEST"

generate_manifest() {
    local dir="$1"
    if [ -d "$dir" ]; then
        find "$dir" -type f ! -name '.DS_Store' | sort | while read -r file; do
            local rel_path="${file#$TARGET_DIR/}"
            local checksum
            checksum=$(shasum -a 256 "$file" | cut -d' ' -f1)
            echo "${rel_path}:${checksum}" >> "$MANIFEST"
        done
    fi
}

generate_manifest "$TARGET_DIR/specchain/standards"
generate_manifest "$TARGET_DIR/specchain/roles"
generate_manifest "$TARGET_DIR/specchain/governance"
generate_manifest "$TARGET_DIR/specchain/docs"
generate_manifest "$TARGET_DIR/.claude/commands/specchain"
generate_manifest "$TARGET_DIR/.claude/agents/specchain"

echo ""
echo -e "${GREEN}Specchain v${SPECCHAIN_VERSION} installed successfully!${NC}"
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
