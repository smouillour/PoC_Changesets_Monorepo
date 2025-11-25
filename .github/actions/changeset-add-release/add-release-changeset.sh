#!/usr/bin/env bash
set -euo pipefail

# ==== External Parameters ====
# RELEASE_TYPE must be provided via the environment (patch / minor / major)
RELEASE_TYPE="${RELEASE_TYPE:?RELEASE_TYPE must be set (patch|minor|major)}"

# SUMMARY is optional (often the name of the release branch)
SUMMARY="${SUMMARY:-}"

# Packages to add to the changeset
PACKAGES=(
  "@smouillour/poc-changeset-app"
  "@smouillour/poc-changeset-parcel-app"
  "@smouillour/poc-changeset-webapp-frontend"
  "@smouillour/poc-changeset-webapp-microfrontend"
)

echo "📦 Generating an empty changeset…"

# List .changeset/*.md files BEFORE
before=$(git ls-files --others --exclude-standard .changeset -- '*.md' || true)
before=$(printf '%s\n' "$before" | sed '/^$/d' | sort -u)

# Create the empty changeset (non-interactive)
pnpm changeset add --empty >/dev/null

# List .changeset/*.md files AFTER
after=$(git ls-files --others --exclude-standard .changeset -- '*.md' || true)
after=$(printf '%s\n' "$after" | sed '/^$/d' | sort -u)

# New files = after - before
new_files=$(comm -13 <(printf '%s\n' "$before") <(printf '%s\n' "$after"))

# We take the first one (there should only be one)
FILE=$(printf '%s\n' "$new_files" | head -n1)

if [ -z "${FILE:-}" ]; then
  echo "❌ Impossible to find the created changeset file."
  exit 1
fi

echo "→ Created file : $FILE"
echo "📝 Updating the changeset with packages + summary…"

# We completely rewrite the file with the YAML + optional summary
{
  echo '---'
  for pkg in "${PACKAGES[@]}"; do
    echo "\"${pkg}\": ${RELEASE_TYPE}"
  done
  echo '---'
  if [ -n "$SUMMARY" ]; then
    echo
    echo "$SUMMARY"
  fi
} > "$FILE"

echo "✅ Final Changeset :"
cat "$FILE"

echo "💾 Commit changeset…"

# Default commit message
COMMIT_MSG="chore: add release changeset"

# Add only the .changeset folder
git add .changeset

# If nothing has changed (for safety), do not commit
if git diff --cached --quiet; then
  echo "ℹ️ No changes to commit."
  exit 0
fi

git commit -m "$COMMIT_MSG"
git push origin HEAD

echo "✅ Commit created and pushed"
