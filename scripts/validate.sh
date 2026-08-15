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
    root / "plugin.json",
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

plugin = json.loads((root / "plugin.json").read_text())
claude = json.loads((root / ".claude-plugin" / "plugin.json").read_text())
server = json.loads((root / "server.json").read_text())
mcp = json.loads((root / "mcp.json").read_text())
dot_mcp = json.loads((root / ".mcp.json").read_text())

version = plugin.get("version")
if not version:
    print("plugin.json is missing version", file=sys.stderr)
    sys.exit(1)
if claude.get("version") != version or server.get("version") != version:
    print(
        f"version mismatch: plugin={version} claude={claude.get('version')} server={server.get('version')}",
        file=sys.stderr,
    )
    sys.exit(1)

if server.get("name") != "ai.edgaze/mcp":
    print("server.json name must be ai.edgaze/mcp", file=sys.stderr)
    sys.exit(1)
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
if claude.get("mcpServers", {}).get("edgaze", {}).get("url") != "https://mcp.edgaze.ai":
    print(".claude-plugin/plugin.json must point at https://mcp.edgaze.ai", file=sys.stderr)
    sys.exit(1)

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

forbidden_url = re.compile(r"https?://(?!www\.edgaze\.ai|mcp\.edgaze\.ai|github\.com/edgaze-ai|agent-plugins\.org|static\.modelcontextprotocol\.io|cursor\.com|chatgpt\.com)[^\s)\"']+", re.I)
text_roots = [
    root / "README.md",
    root / "SECURITY.md",
    root / "CONTRIBUTING.md",
    root / "CHANGELOG.md",
    root / "docs",
    root / "examples",
    root / "skills",
    root / "plugin.json",
    root / "mcp.json",
    root / ".mcp.json",
    root / "server.json",
    root / ".claude-plugin",
]
checked = []
for item in text_roots:
    if item.is_file():
        checked.append(item)
    elif item.is_dir():
        checked.extend(p for p in item.rglob("*") if p.is_file() and p.suffix in {".md", ".json"})

for path in checked:
    text = path.read_text()
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

ajv validate --spec=draft2020 -c ajv-formats -s schemas/plugin.schema.json -d plugin.json
ajv validate --spec=draft2020 -c ajv-formats -s schemas/mcp.schema.json -d mcp.json
ajv validate --spec=draft7 --strict=false -c ajv-formats -s schemas/server.schema.json -d server.json

if [[ "${SKIP_LIVE_CHECK:-}" != "1" ]]; then
  headers="$(curl -sI --max-time 20 https://mcp.edgaze.ai || true)"
  echo "$headers" | grep -qi 'www-authenticate: Bearer' || fail "https://mcp.edgaze.ai did not advertise Bearer WWW-Authenticate"
  echo "$headers" | grep -qi 'oauth-protected-resource' || fail "https://mcp.edgaze.ai is missing OAuth protected-resource metadata"
  echo "live endpoint check passed"
fi

echo "validate: ok"
