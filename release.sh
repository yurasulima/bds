#! /usr/bin/env bash
set -euo pipefail

if [[ ! -f versions.txt ]]; then
    echo "versions.txt not found."
    exit 0
fi

git remote set-url origin "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"

RELEASED=0

while IFS= read -r BDS_VERSION || [[ -n "$BDS_VERSION" ]]; do
    [[ -z "$BDS_VERSION" ]] && continue

    # x.y.z.w -> x.y.z
    TAG="v$(echo "$BDS_VERSION" | cut -d. -f1-3)"

    if git rev-parse "$TAG" >/dev/null 2>&1; then
        echo "Skipping $TAG (already exists)"
        continue
    fi

    echo "Tagging $TAG ($BDS_VERSION)..."
    git tag -a "$TAG" -m "Bedrock Server $BDS_VERSION" HEAD
    RELEASED=$((RELEASED + 1))
done < versions.txt

if [[ $RELEASED -gt 0 ]]; then
    echo "Pushing $RELEASED new tag(s)..."
    git push --tags origin
else
    echo "No new tags."
fi