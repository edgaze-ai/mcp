# VS Code

`.vscode/mcp.json`. The top-level key is `servers`:

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

Switch Copilot Chat to Agent mode. The client starts OAuth. Do not open `/oauth/consent` yourself. Full playbook: [docs/clients.md](../docs/clients.md).
