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

## Claude Desktop

`~/Library/Application Support/Claude/claude_desktop_config.json` on macOS:

```json
{
  "mcpServers": {
    "edgaze": {
      "url": "https://mcp.edgaze.ai"
    }
  }
}
```

For claude.ai, Cowork, and mobile, add a custom connector at `https://mcp.edgaze.ai`. Leave client id and secret empty.

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
