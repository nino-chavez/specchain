#!/bin/bash
# Validates the specchain project structure is complete and consistent

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
FAILED=0

echo "Validating project structure..."
echo ""

# Required directories
REQUIRED_DIRS=(
    "specchain"
    "specchain/state"
    "specchain/standards"
    "specchain/standards/global"
    "specchain/standards/backend"
    "specchain/standards/frontend"
    "specchain/standards/testing"
    "specchain/roles"
    "specchain/governance"
    "specchain/docs"
    ".claude/commands/specchain"
    ".claude/agents/specchain"
)

echo "  Checking directories..."
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ ! -d "$PROJECT_DIR/$dir" ]; then
        echo "    FAIL: Missing directory: $dir"
        FAILED=1
    fi
done

# Required files
REQUIRED_FILES=(
    "specchain/config.yml"
    "specchain/roles/implementers.yml"
    "specchain/roles/verifiers.yml"
    "specchain/state/context.yml"
    "specchain/state/decisions.yml"
    "specchain/state/blockers.yml"
    "specchain/state/sessions.yml"
    "specchain/state/patterns.yml"
    "specchain/state/profiles.yml"
    "specchain/governance/principles.md"
    "specchain/governance/claude-md.tmpl"
    "specchain/governance/cursorrules.tmpl"
    ".claude/commands/specchain/new-spec.md"
    ".claude/commands/specchain/create-spec.md"
    ".claude/commands/specchain/implement-spec.md"
    ".claude/commands/specchain/plan-product.md"
    ".claude/commands/specchain/spec.md"
    "setup.sh"
    "README.md"
    "LICENSE"
)

echo "  Checking required files..."
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$PROJECT_DIR/$file" ]; then
        echo "    FAIL: Missing file: $file"
        FAILED=1
    fi
done

# Check that every implementer in implementers.yml has a matching agent file
echo "  Checking implementer-agent alignment..."
if [ -f "$PROJECT_DIR/specchain/roles/implementers.yml" ]; then
    while IFS= read -r role_id; do
        if [ ! -f "$PROJECT_DIR/.claude/agents/specchain/${role_id}.md" ]; then
            echo "    FAIL: Implementer '$role_id' has no agent file at .claude/agents/specchain/${role_id}.md"
            FAILED=1
        fi
    done < <(grep '^\s*role:' "$PROJECT_DIR/specchain/roles/implementers.yml" | sed 's/.*role:\s*//;s/[" ]//g')
fi

# Check version consistency
echo "  Checking version consistency..."
SETUP_VERSION=$(grep 'SPECCHAIN_VERSION=' "$PROJECT_DIR/setup.sh" | head -1 | sed 's/.*="\(.*\)"/\1/')
CONFIG_VERSION=$(grep 'specchain_version:' "$PROJECT_DIR/specchain/config.yml" | sed 's/specchain_version: *//;s/ *#.*//;s/[" ]//g')

if [ -n "$SETUP_VERSION" ] && [ -n "$CONFIG_VERSION" ]; then
    if [ "$SETUP_VERSION" != "$CONFIG_VERSION" ]; then
        echo "    FAIL: Version mismatch — setup.sh ($SETUP_VERSION) vs config.yml ($CONFIG_VERSION)"
        FAILED=1
    fi
fi

echo ""

if [ "$FAILED" -eq 0 ]; then
    echo "All structure validations passed."
else
    echo "Some validations FAILED."
    exit 1
fi
