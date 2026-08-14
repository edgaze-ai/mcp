# Dist scanner findings

Evidence from published docs. Empirical confirmation is pending a live install.

## Claude Code `.mcp.json` uses `http`, not `streamable-http`

Claude Code documents MCP remote types as `http`, `sse`, and `ws`. Official `.mcp.json` examples in those docs are stdio. This repo therefore sets `.mcp.json` and `.claude-plugin/plugin.json` to `"type": "http"` for `https://mcp.edgaze.ai`.

## Agent Plugins and the official registry use `streamable-http`

Agent Plugins `mcp.json` (`https://agent-plugins.org/schemas/1.0.0/mcp.schema.json`) and official MCP registry `server.json` (`https://static.modelcontextprotocol.io/schemas/2025-12-11/server.schema.json`) both require `"type": "streamable-http"` for a remote Streamable HTTP server. This repo uses that type in `mcp.json` and `server.json`.

## Cursor reads root `plugin.json`

Cursor's plugin scanner treats a root `plugin.json` as an Agent Plugins manifest. This repo keeps the portable Agent Plugins contract at the repository root.

## Claude Code loads `.claude-plugin/plugin.json` and `marketplace.json`

Claude Code discovers a plugin from `.claude-plugin/plugin.json` and a marketplace catalog from `.claude-plugin/marketplace.json`. Both files are required here. The marketplace entry `source` is `./` (repository root).
