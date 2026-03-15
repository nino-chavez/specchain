#!/bin/bash
# Validates that all template placeholders have matching substitutions in setup.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
FAILED=0

echo "Validating template placeholders..."
echo ""

# Extract all ${VAR} placeholders from templates
TEMPLATES=(
    "$PROJECT_DIR/specchain/governance/claude-md.tmpl"
    "$PROJECT_DIR/specchain/governance/cursorrules.tmpl"
)

SETUP="$PROJECT_DIR/setup.sh"

for tmpl in "${TEMPLATES[@]}"; do
    filename=$(basename "$tmpl")
    echo "  Checking $filename..."

    # Find all ${VAR} placeholders
    while IFS= read -r var; do
        # Check if setup.sh exports or assigns this variable
        if ! grep -q "$var" "$SETUP"; then
            echo "    FAIL: Placeholder \${$var} has no matching variable in setup.sh"
            FAILED=1
        fi
    done < <(grep -oE '\$\{[A-Z_]+\}' "$tmpl" | sed 's/\${//;s/}//' | sort -u)
done

echo ""

if [ "$FAILED" -eq 0 ]; then
    echo "All template validations passed."
else
    echo "Some validations FAILED."
    exit 1
fi
