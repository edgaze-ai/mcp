# Edgaze MCP

[![CI](https://github.com/edgaze-ai/mcp/actions/workflows/ci.yml/badge.svg)](https://github.com/edgaze-ai/mcp/actions/workflows/ci.yml)

Remote MCP server for the Edgaze marketplace. An agent can search published workflows, read the price and inputs, then run them.

This repository is public manifests only. The server is hosted. There is no local binary, no `npx` package, and no API key.

**Server:** [https://mcp.edgaze.ai](https://mcp.edgaze.ai)

**Docs:** [https://www.edgaze.ai/docs/mcp](https://www.edgaze.ai/docs/mcp)

## Install in Claude Code

Install the plugin. It adds the MCP server and a skill that tells Claude how to search, inspect, run, and show results.

```text
/plugin install edgaze --marketplace edgaze-ai/mcp
```

From a shell:

```bash
claude plugin install edgaze --marketplace edgaze-ai/mcp
```

Run `/mcp`, pick `edgaze`, and sign in when the browser opens.

## Connect another client

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

## What the plugin does

The plugin contains one MCP server declaration and one skill. It runs no local code, installs no packages, and adds no hooks.

- **Connects to:** `https://mcp.edgaze.ai` only, over HTTPS.
- **Sends:** your search terms, the workflow you pick, and the inputs you give it. Edgaze runs the workflow on its servers.
- **Signs in:** with browser OAuth on www.edgaze.ai. Claude Code stores the OAuth token. The plugin never reads or stores credentials.
- **Spends:** a paid run is charged to your Edgaze wallet, never above the `max_cost_usd` ceiling the agent sets. Demos never bill. The skill tells the agent to read the price first and hide nothing about it.
- **Acts elsewhere:** some workflows act on your own connected accounts, such as Slack or GitHub. `edgaze_inspect` lists these before you run.

## After a run

Text and external actions come back in the chat. Images, video, and files come back as a link to the hosted run page: `https://www.edgaze.ai/run/{id}`.

## Privacy and security

Sign-in is browser OAuth against Edgaze. The plugin stores no credentials. Privacy policy: [https://www.edgaze.ai/docs/privacy-policy](https://www.edgaze.ai/docs/privacy-policy). Terms: [https://www.edgaze.ai/docs/terms-of-service](https://www.edgaze.ai/docs/terms-of-service). Support: [https://www.edgaze.ai/help](https://www.edgaze.ai/help).

Report vulnerabilities to `security@edgaze.ai`. See [SECURITY.md](SECURITY.md).

## Repository

| File | Purpose |
| --- | --- |
| `server.json` | Official MCP registry entry (`ai.edgaze/mcp`) |
| `.claude-plugin/` / `.mcp.json` | Claude Code plugin, marketplace, and listing icon |
| `.cursor-plugin/` / `mcp.json` | Cursor plugin |
| `skills/edgaze/SKILL.md` | How the agent should search, inspect, run, and show results |

Implementation is not accepted here. Changes to the hosted server happen in the Edgaze product.

## License

MIT. Copyright Edge Platforms, Inc.
