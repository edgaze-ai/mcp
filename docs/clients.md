# Client configs

Use these snippets as-is. Name the server `edgaze`. Do not add an API key. The client starts OAuth. Do not open `/oauth/consent` yourself.

The full playbook, including ChatGPT, Claude app, Windsurf, OpenCode, and troubleshooting, is [Connect Edgaze MCP](https://www.edgaze.ai/docs/mcp/connect).

## Cursor

`.cursor/mcp.json` or `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "edgaze": {
      "url": "https://mcp.edgaze.ai"
    }
  }
}
```

You can also use **Cursor Settings → Tools & MCP → New MCP Server** and enter `https://mcp.edgaze.ai`.

## Claude Code

```bash
claude mcp add --transport http edgaze https://mcp.edgaze.ai --scope user
```

Or `.mcp.json` at the repository root:

```json
{
  "mcpServers": {
    "edgaze": {
      "type": "http",
      "url": "https://mcp.edgaze.ai"
    }
  }
}
```

Claude Code skips a remote server that has a `url` and no `type`.

## Claude app (claude.ai and Claude Desktop)

Open **Customize → Connectors**, click **+ Add**, then **Add custom connector**. Name it `Edgaze` and enter `https://mcp.edgaze.ai`. Leave client id and secret empty. `claude_desktop_config.json` does not configure remote servers. If the tools are missing in a chat, open **+ → Connectors** and turn Edgaze on.

On mobile, add the connector on claude.ai or Claude Desktop first. It then appears in the mobile app, where you turn it on per chat.

## Codex

`~/.codex/config.toml`:

```toml
[mcp_servers.edgaze]
url = "https://mcp.edgaze.ai"
```

Or:

```bash
codex mcp add edgaze --url https://mcp.edgaze.ai
```

## VS Code

`.vscode/mcp.json`. The top-level key is `servers`, not `mcpServers`:

```json
{
  "servers": {
    "edgaze": {
      "type": "http",
      "url": "https://mcp.edgaze.ai"
    }
  }
}
```

Switch Copilot Chat to Agent mode.
