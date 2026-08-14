# Edgaze MCP

Public manifests for the Edgaze MCP server. This repository ships plugin and registry files only. The server itself runs at `https://mcp.edgaze.ai`.

Find and run Edgaze marketplace workflows from chat. Paste the URL, sign in, then search and run.

## Connect

Paste this server address in Cursor, Claude, or VS Code:

```
https://mcp.edgaze.ai
```

Your app will send you to [www.edgaze.ai/oauth/consent](https://www.edgaze.ai/oauth/consent) to approve access. Use that exact page.

Short install notes:

- [Cursor](examples/cursor.md)
- [Claude](examples/claude.md)
- [VS Code](examples/vscode.md)

Docs: [www.edgaze.ai/docs/mcp](https://www.edgaze.ai/docs/mcp)

## What this repo contains

| File | Purpose |
| --- | --- |
| `plugin.json` | Agent Plugins root manifest (Cursor reads this) |
| `mcp.json` | Agent Plugins MCP config (`streamable-http`) |
| `.claude-plugin/plugin.json` | Claude Code plugin manifest |
| `.claude-plugin/marketplace.json` | Claude Code marketplace catalog |
| `.mcp.json` | Claude Code MCP definition (`type: http`) |
| `server.json` | Official MCP registry entry |
| `skills/edgaze/SKILL.md` | Skill that tells the agent how to search, inspect, run, and watch |

## License

MIT © Edge Platforms, Inc.
