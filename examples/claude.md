# Claude Code

```bash
claude mcp add --transport http edgaze https://mcp.edgaze.ai --scope user
```

Claude Code needs `"type": "http"` in a file. The client starts OAuth. Do not open `/oauth/consent` yourself. Full playbook: [docs/clients.md](../docs/clients.md).
