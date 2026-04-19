#!/usr/bin/env bash

set -euo pipefail

TARGET_DIR="${1:-.}"

echo "Scanning for Eclipse project files in: $TARGET_DIR"

PATTERNS=(
  ".classpath"
  ".project"
  ".settings"
  ".factorypath"
  ".buildpath"
  ".apt_generated"
)

# Collect matches
MATCHES=()

for pattern in "${PATTERNS[@]}"; do
  while IFS= read -r -d '' file; do
    MATCHES+=("$file")
  done < <(find "$TARGET_DIR" -path "*/.git" -prune -o -name "$pattern" -print0)
done

# Show results
if [ ${#MATCHES[@]} -eq 0 ]; then
  echo "No Eclipse files found."
  exit 0
fi

echo "The following files/directories will be removed:"
for f in "${MATCHES[@]}"; do
  echo "  $f"
done

echo
read -p "Proceed with deletion? (y/N): " CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

# Perform deletion
for f in "${MATCHES[@]}"; do
  rm -rf "$f"
done

echo "Cleanup complete."
