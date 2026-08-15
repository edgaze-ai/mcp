# Edgaze MCP

[![CI](https://github.com/edgaze-ai/mcp/actions/workflows/ci.yml/badge.svg)](https://github.com/edgaze-ai/mcp/actions/workflows/ci.yml)

Remote MCP server for the Edgaze marketplace. An agent can search published workflows, read the price and inputs, then run them.

This repository is public manifests only. The server is hosted. There is no local binary, no `npx` package, and no API key.

**Server:** [https://mcp.edgaze.ai](https://mcp.edgaze.ai)

**Docs:** [https://www.edgaze.ai/docs/mcp](https://www.edgaze.ai/docs/mcp)

## Connect

Add a remote HTTP server named `edgaze` and point it at `https://mcp.edgaze.ai`.

Do not add a `command`, a bearer token, or an `Authorization` header. The client starts OAuth and opens consent on [www.edgaze.ai](https://www.edgaze.ai). Approve **Find workflows** and **Run workflows**. Do not open `/oauth/consent` yourself. A bare consent link has no sign-in request.

After you connect, these tools should be listed:

| Tool | Role |
| --- | --- |
| `edgaze_catalog` | Categories when the goal is still vague |
| `edgaze_search` | Find a workflow for a job |
| `edgaze_inspect` | Inputs, example values, price, demo availability |
| `edgaze_run` | Start a demo or a paid run |
| `edgaze_watch` | Read output until the run finishes |

A zero wallet is normal the first time. Add money at [https://www.edgaze.ai/wallet](https://www.edgaze.ai/wallet) when you want a paid run.

Client configs: [docs/clients.md](docs/clients.md). The install playbook is [Connect Edgaze MCP](https://www.edgaze.ai/docs/mcp/connect).

## After a run

Text and external actions come back in the chat. Images, video, and files come back as a link to the hosted run page: `https://www.edgaze.ai/run/{id}`.

## Security

Sign-in is browser OAuth against Edgaze. Report vulnerabilities to `security@edgaze.ai`. See [SECURITY.md](SECURITY.md).

## Repository

| File | Purpose |
| --- | --- |
| `server.json` | Official MCP registry entry (`ai.edgaze/mcp`) |
| `plugin.json` / `mcp.json` | Agent Plugins (Cursor and other plugin hosts) |
| `.claude-plugin/` / `.mcp.json` | Claude Code plugin and marketplace files |
| `skills/edgaze/SKILL.md` | How the agent should search, inspect, run, and show results |

Implementation is not accepted here. Changes to the hosted server happen in the Edgaze product.

## License

MIT. Copyright Edge Platforms, Inc.
