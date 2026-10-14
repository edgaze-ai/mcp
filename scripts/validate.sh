#!/usr/bin/env bash
# Validate public manifests. No network required except the optional live check.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail() {
  echo "validate: $*" >&2
  exit 1
}

need() {
  command -v "$1" >/dev/null 2>&1 || fail "missing $1"
}

need python3
need curl

python3 - <<'PY'
import json
import pathlib
import re
import sys

root = pathlib.Path(".")
em_dash = "\u2014"
en_dash = "\u2013"

manifests = [
    root / ".cursor-plugin" / "plugin.json",
    root / "mcp.json",
    root / ".mcp.json",
    root / "server.json",
    root / ".claude-plugin" / "plugin.json",
    root / ".claude-plugin" / "marketplace.json",
]

for path in manifests:
    if not path.is_file():
        print(f"missing {path}", file=sys.stderr)
        sys.exit(1)
    try:
        json.loads(path.read_text())
    except json.JSONDecodeError as error:
        print(f"invalid JSON {path}: {error}", file=sys.stderr)
        sys.exit(1)

def fail(message):
    print(message, file=sys.stderr)
    sys.exit(1)

cursor = json.loads((root / ".cursor-plugin" / "plugin.json").read_text())
claude = json.loads((root / ".claude-plugin" / "plugin.json").read_text())
marketplace = json.loads((root / ".claude-plugin" / "marketplace.json").read_text())
server = json.loads((root / "server.json").read_text())
mcp = json.loads((root / "mcp.json").read_text())
dot_mcp = json.loads((root / ".mcp.json").read_text())

# Claude reads only .claude-plugin/plugin.json and flags a root plugin.json as ignored.
if (root / "plugin.json").exists():
    fail("root plugin.json is ignored by Claude and flagged by the plugin directory; Cursor reads .cursor-plugin/plugin.json")

version = claude.get("version")
if not version:
    fail(".claude-plugin/plugin.json is missing version")
if cursor.get("version") != version or server.get("version") != version:
    fail(f"version mismatch: claude={version} cursor={cursor.get('version')} server={server.get('version')}")

for key in ("name", "description", "author", "homepage", "repository", "license", "keywords"):
    if claude.get(key) != cursor.get(key):
        fail(f"{key} differs between .claude-plugin/plugin.json and .cursor-plugin/plugin.json")

# Claude plugin directory listing. The directory finds the listing icon at its default
# path in .claude-plugin/, so no manifest names it: a manifest that names an image, read
# by this script, holds every version for review. Every listing field in plugin.json
# raises a portal warning, and the directory takes the privacy policy URL from the
# README, so the README carries the listing links instead.
for key in ("icon", "privacyPolicyUrl", "documentationUrl", "supportUrl", "termsOfServiceUrl", "mcpServers", "metadata"):
    if key in claude:
        fail(f".claude-plugin/plugin.json must not set {key}")
if "https://www.edgaze.ai/docs/privacy-policy" not in (root / "README.md").read_text():
    fail("README.md must link https://www.edgaze.ai/docs/privacy-policy; the directory reads the privacy policy URL from it")
if not str(cursor.get("logo", "")).startswith("https://www.edgaze.ai/"):
    fail(".cursor-plugin/plugin.json logo must be an https://www.edgaze.ai/ URL, not a path in this repository")

entries = [entry for entry in marketplace.get("plugins", []) if entry.get("name") == claude.get("name")]
if len(entries) != 1 or entries[0].get("source") != "./":
    fail("marketplace.json must list the plugin once with source ./")
if entries[0].get("description") != claude.get("description"):
    fail("marketplace.json plugin description must match .claude-plugin/plugin.json")

# No text file may name a bundled image; the directory holds a version for review when one does.
image_path = re.compile(r"[\w./-]+\.(?:png|jpe?g|gif|webp|svg|ico)\b", re.I)
for path in sorted(root.rglob("*")):
    if ".git" in path.parts or "schemas" in path.parts or not path.is_file():
        continue
    if path.suffix.lower() in {".png", ".jpg", ".jpeg", ".gif", ".webp", ".svg", ".ico"}:
        continue
    for match in image_path.findall(path.read_text(errors="ignore")):
        if not match.startswith(("https://", "//")) and "://" not in match:
            fail(f"{path} names an image file ({match}); link a hosted URL instead")

if server.get("name") != "ai.edgaze/mcp":
    fail("server.json name must be ai.edgaze/mcp")
if server.get("repository", {}).get("id") != "1333920943":
    print("server.json repository.id must be the GitHub repo id 1333920943", file=sys.stderr)
    sys.exit(1)

description = server.get("description", "")
if not (1 <= len(description) <= 100):
    print("server.json description must be 1-100 characters", file=sys.stderr)
    sys.exit(1)

remotes = server.get("remotes") or []
if remotes != [{"type": "streamable-http", "url": "https://mcp.edgaze.ai"}]:
    print("server.json remotes must be streamable-http https://mcp.edgaze.ai", file=sys.stderr)
    sys.exit(1)

if mcp.get("mcpServers", {}).get("edgaze", {}).get("url") != "https://mcp.edgaze.ai":
    print("mcp.json must point at https://mcp.edgaze.ai", file=sys.stderr)
    sys.exit(1)
if dot_mcp.get("mcpServers", {}).get("edgaze", {}).get("url") != "https://mcp.edgaze.ai":
    print(".mcp.json must point at https://mcp.edgaze.ai", file=sys.stderr)
    sys.exit(1)
if dot_mcp["mcpServers"]["edgaze"].get("type") != "http":
    fail('.mcp.json needs "type": "http"; Claude Code skips a remote server without it')

skill = (root / "skills" / "edgaze" / "SKILL.md").read_text()
for name in (
    "edgaze_catalog",
    "edgaze_search",
    "edgaze_inspect",
    "edgaze_run",
    "edgaze_watch",
    "present=chat",
    "present=edgaze_page",
    "https://www.edgaze.ai/run/{id}",
):
    if name not in skill:
        print(f"skills/edgaze/SKILL.md is missing {name}", file=sys.stderr)
        sys.exit(1)

allowed_hosts = r"www\.edgaze\.ai|mcp\.edgaze\.ai|github\.com/edgaze-ai|static\.modelcontextprotocol\.io|cursor\.com|chatgpt\.com|claude\.ai|claude\.com|code\.claude\.com"
# The boundary after the host stops look-alikes such as www.edgaze.ai.evil.com from passing.
forbidden_url = re.compile(rf"https?://(?!(?:{allowed_hosts})(?:[/:?#)\]`\"'\s]|$))[^\s)\"']+", re.I)
text_roots = [
    root / "README.md",
    root / "SECURITY.md",
    root / "CONTRIBUTING.md",
    root / "CHANGELOG.md",
    root / "docs",
    root / "examples",
    root / "skills",
    root / "mcp.json",
    root / ".mcp.json",
    root / "server.json",
    root / ".claude-plugin",
    root / ".cursor-plugin",
]
checked = []
for item in text_roots:
    if item.is_file():
        checked.append(item)
    elif item.is_dir():
        checked.extend(p for p in item.rglob("*") if p.is_file() and p.suffix in {".md", ".json"})

for path in checked:
    text = path.read_text()
    if path.suffix == ".md":
        for match in forbidden_url.findall(text):
            fail(f"{path} links to an unexpected host: {match}")
    if em_dash in text or en_dash in text:
        print(f"em/en dash in {path}", file=sys.stderr)
        sys.exit(1)
    if "oauth/consent" in text and "Do not open" not in text and "do not open" not in text.lower():
        if path.name not in {"plugin.json", "mcp.json", "server.json"}:
            print(f"{path} mentions /oauth/consent without telling people not to open it", file=sys.stderr)
            sys.exit(1)

print("json and policy checks passed")
PY

if ! command -v ajv >/dev/null 2>&1; then
  echo "validate: installing ajv-cli for this run"
  npm install --global ajv-cli@5.0.0 ajv-formats@3.0.1 >/dev/null
fi

ajv validate --spec=draft7 --strict=false -c ajv-formats -s schemas/server.schema.json -d server.json

if command -v claude >/dev/null 2>&1; then
  claude plugin validate --strict .
  claude plugin validate --strict .claude-plugin/plugin.json
elif [[ -n "${CI:-}" ]]; then
  fail "claude is required in CI for claude plugin validate --strict"
else
  echo "validate: claude not installed, skipping claude plugin validate"
fi

if [[ "${SKIP_LIVE_CHECK:-}" != "1" ]]; then
  headers="$(curl -sI --max-time 20 https://mcp.edgaze.ai || true)"
  echo "$headers" | grep -qi 'www-authenticate: Bearer' || fail "https://mcp.edgaze.ai did not advertise Bearer WWW-Authenticate"
  echo "$headers" | grep -qi 'oauth-protected-resource' || fail "https://mcp.edgaze.ai is missing OAuth protected-resource metadata"
  echo "live endpoint check passed"
fi

echo "validate: ok"
