#!/bin/bash
# Validates all agent .md files have required frontmatter fields
# and that file references in agent prompts point to existing files

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
AGENTS_DIR="$PROJECT_DIR/.claude/agents/specchain"
FAILED=0

echo "Validating agent files in $AGENTS_DIR..."
echo ""

# Required frontmatter fields
REQUIRED_FIELDS=("name" "description" "tools" "color" "model")

for agent in "$AGENTS_DIR"/*.md; do
    filename=$(basename "$agent")
    echo "  Checking $filename..."

    # Check required frontmatter fields
    for field in "${REQUIRED_FIELDS[@]}"; do
        if ! grep -q "^${field}:" "$agent"; then
            echo "    FAIL: Missing required field: $field"
            FAILED=1
        fi
    done

    # Check that @file references exist (strip trailing backticks/punctuation)
    while IFS= read -r line; do
        ref_path=$(echo "$line" | sed 's/^@//;s/[`"'"'"' ]//g')
        if [ ! -f "$PROJECT_DIR/$ref_path" ]; then
            echo "    FAIL: @reference to non-existent file: $ref_path"
            FAILED=1
        fi
    done < <(grep -oE '@specchain/[^ `"]+' "$agent" 2>/dev/null || true)
done

echo ""

if [ "$FAILED" -eq 0 ]; then
    echo "All agent validations passed."
else
    echo "Some validations FAILED."
    exit 1
fi
