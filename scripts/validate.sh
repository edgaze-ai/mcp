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

# Claude plugin directory listing fields.
for key in ("privacyPolicyUrl", "termsOfServiceUrl", "supportUrl", "documentationUrl"):
    if not str(claude.get(key, "")).startswith("https://www.edgaze.ai/"):
        fail(f".claude-plugin/plugin.json {key} must be an https://www.edgaze.ai/ URL")
if "mcpServers" in claude:
    fail(".claude-plugin/plugin.json must not declare mcpServers; .mcp.json is the only declaration")

entries = [entry for entry in marketplace.get("plugins", []) if entry.get("name") == claude.get("name")]
if len(entries) != 1 or entries[0].get("source") != "./":
    fail("marketplace.json must list the plugin once with source ./")
if entries[0].get("description") != claude.get("description"):
    fail("marketplace.json plugin description must match .claude-plugin/plugin.json")

def png_size(path):
    data = path.read_bytes()
    if data[:8] != b"\x89PNG\r\n\x1a\n" or data[12:16] != b"IHDR":
        fail(f"{path} is not a PNG")
    return int.from_bytes(data[16:20], "big"), int.from_bytes(data[20:24], "big"), len(data)

icon = (root / claude.get("icon", "")).resolve()
if not claude.get("icon") or icon.parent != (root / ".claude-plugin").resolve() or not icon.is_file():
    fail(".claude-plugin/plugin.json icon must name a file inside .claude-plugin/")
width, height, size = png_size(icon)
if width != height or not (512 <= width <= 2048) or size >= 2 * 1024 * 1024:
    fail(f"icon must be a square PNG, 512 to 2048 px, under 2 MB (got {width}x{height}, {size} bytes)")
if (root / cursor.get("logo", "")).resolve() != icon:
    fail(".cursor-plugin/plugin.json logo must be the same file as the Claude icon")

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

forbidden_url = re.compile(r"https?://(?!www\.edgaze\.ai|mcp\.edgaze\.ai|github\.com/edgaze-ai|static\.modelcontextprotocol\.io|cursor\.com|chatgpt\.com|claude\.ai|claude\.com|code\.claude\.com)[^\s)\"']+", re.I)
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
