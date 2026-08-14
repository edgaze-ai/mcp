#!/usr/bin/env bash
# Prepare-only. Does not submit.

set -euo pipefail

echo "Prepare Cursor marketplace submit (does not submit)"
echo
echo "1. Confirm https://github.com/edgaze-ai/mcp is public and contains a valid root plugin.json"
echo "2. Open https://cursor.com/marketplace/publish while signed into Cursor"
echo "3. Submit the repository URL: https://github.com/edgaze-ai/mcp"
echo
echo "Stop here. Do not submit the form from this script."
