#! /usr/bin/env bash
set -euo pipefail

touch versions.txt

download_url=$(curl \
  -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0' \
  -s "https://net-secondary.web.minecraft-services.net/api/v1.0/download/links" | \
  grep -oP '"downloadType":\s*"serverBedrockWindows".*?"downloadUrl":\s*"\K[^"]+')

if [[ -z "$download_url" ]]; then
    echo "Failed to fetch downloadUrl."
    exit 1
fi

echo "Download URL: $download_url"

if [[ $download_url =~ [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ ]]; then
    version="${BASH_REMATCH[0]}"
    echo "Parsed version: $version"
else
    echo "Failed to extract version from URL."
    exit 1
fi

last=$(tail -n 1 versions.txt 2>/dev/null || echo "")
echo "Last recorded: $last"

if [[ "$last" == "$version" ]]; then
    echo "Already up to date."
    exit 0
fi

echo "$version" >> versions.txt

git remote set-url origin "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
git add versions.txt
git commit -m "Add version: $version"
git push origin main