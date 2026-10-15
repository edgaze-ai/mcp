# Edgaze MCP

[![CI](https://github.com/edgaze-ai/mcp/actions/workflows/ci.yml/badge.svg)](https://github.com/edgaze-ai/mcp/actions/workflows/ci.yml)

Remote MCP server for the Edgaze marketplace. An agent can search published workflows, read the price and inputs, then run them.

This repository is public manifests only. The server is hosted. There is no local binary, no `npx` package, and no API key.

**Server:** [https://mcp.edgaze.ai](https://mcp.edgaze.ai)

**Docs:** [https://www.edgaze.ai/docs/mcp](https://www.edgaze.ai/docs/mcp)

## Connect

Every client connects the same way: add a remote HTTP server named `edgaze` at `https://mcp.edgaze.ai`. The client starts OAuth and opens consent on [www.edgaze.ai](https://www.edgaze.ai). Approve **Find workflows** and **Run workflows**. Do not add a `command`, a bearer token, or an `Authorization` header, and do not open `/oauth/consent` yourself.

### VS Code and GitHub Copilot

Workspace file `.vscode/mcp.json` (or Command Palette → **MCP: Open User Configuration** for a personal one). The top-level key is `servers`, and a remote server needs `"type": "http"`:

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

Or run **MCP: Add Server**, choose **HTTP**, and enter `https://mcp.edgaze.ai`. Confirm that you trust the server, then sign in to Edgaze. Switch Copilot Chat to Agent mode; **Configure Tools** shows the Edgaze tools.

### Claude Code

Install the plugin. It adds the MCP server and a skill that tells Claude how to search, inspect, run, and show results.

```text
/plugin install edgaze --marketplace edgaze-ai/mcp
```

From a shell:

```bash
claude plugin install edgaze --marketplace edgaze-ai/mcp
```

Run `/mcp`, pick `edgaze`, and sign in when the browser opens.

### Cursor, Claude app, Codex, and others

Snippets for each client: [docs/clients.md](docs/clients.md). The full playbook with troubleshooting is [Connect Edgaze MCP](https://www.edgaze.ai/docs/mcp/connect).

## Tools

After you connect, these tools are listed:

| Tool | Role |
| --- | --- |
| `edgaze_catalog` | Categories when the goal is still vague |
| `edgaze_search` | Find a workflow for a job |
| `edgaze_inspect` | Inputs, example values, price, demo availability |
| `edgaze_run` | Start a demo or a paid run |
| `edgaze_watch` | Read output until the run finishes |

A zero wallet is normal the first time. Add money at [https://www.edgaze.ai/wallet](https://www.edgaze.ai/wallet) when you want a paid run.

## Example prompts

- "What kinds of workflows can I run on Edgaze?"
- "Find an Edgaze workflow that writes a cold outreach email, and show me its price and the inputs it needs."
- "Run a free demo of that workflow for my company, Acme Analytics, if it has one."
- "Run it for real with a $2 ceiling and give me the email it writes."

## What it does with your data

The server is hosted. The Claude plugin in this repository contains one MCP server declaration and one skill; it runs no local code, installs no packages, and adds no hooks.

- **Connects to:** `https://mcp.edgaze.ai` only, over HTTPS.
- **Sends:** your search terms, the workflow you pick, and the inputs you give it. Edgaze runs the workflow on its servers.
- **Signs in:** with browser OAuth on www.edgaze.ai. Your client stores the OAuth token. Nothing in this repository reads or stores credentials.
- **Spends:** a paid run is charged to your Edgaze wallet, never above the `max_cost_usd` ceiling the agent sets. Demos never bill. The skill tells the agent to read the price first and hide nothing about it.
- **Acts elsewhere:** some workflows act on your own connected accounts, such as Slack or GitHub. `edgaze_inspect` lists these before you run.

## Troubleshooting

- **No Edgaze tools in VS Code.** The config needs the top-level `servers` key and `"type": "http"`. Check that the server is started and trusted under **MCP: List Servers**, and that Copilot Chat is in Agent mode.
- **No Edgaze tools in Claude Code.** Run `/mcp` and sign in to `edgaze`. A server you add by hand needs `"type": "http"`, or Claude Code skips it.
- **No Edgaze tools on claude.ai or Claude Desktop.** The connector is missing or off. Add it under **Customize → Connectors → + Add → Add custom connector** with the URL `https://mcp.edgaze.ai`. If it is already added, open **+ → Connectors** in the chat and turn it on.
- **Consent says it is missing a sign-in request.** The consent page was opened by hand. Use the client's Connect or Sign in control instead.
- **A run asks for money.** The install worked. Add funds at [https://www.edgaze.ai/wallet](https://www.edgaze.ai/wallet) and run again.

More fixes: [Connect Edgaze MCP](https://www.edgaze.ai/docs/mcp/connect#troubleshooting).

## After a run

Text and external actions come back in the chat. Images, video, and files come back as a link to the hosted run page: `https://www.edgaze.ai/run/{id}`.

## Privacy and security

Sign-in is browser OAuth against Edgaze. The plugin stores no credentials.

- Privacy policy: [https://www.edgaze.ai/docs/privacy-policy](https://www.edgaze.ai/docs/privacy-policy)
- Terms of service: [https://www.edgaze.ai/docs/terms-of-service](https://www.edgaze.ai/docs/terms-of-service)
- Documentation: [https://www.edgaze.ai/docs/mcp](https://www.edgaze.ai/docs/mcp)
- Support: [https://www.edgaze.ai/help](https://www.edgaze.ai/help) or `hello@edgaze.ai`

Report vulnerabilities to `security@edgaze.ai`. See [SECURITY.md](SECURITY.md).

## Repository

| File | Purpose |
| --- | --- |
| `server.json` | Official MCP registry entry (`ai.edgaze/edgaze`), published from this repository |
| `.claude-plugin/` / `.mcp.json` | Claude Code plugin, marketplace, and directory listing |
| `.cursor-plugin/` / `mcp.json` | Cursor plugin |
| `skills/edgaze/SKILL.md` | How the agent should search, inspect, run, and show results |

Implementation is not accepted here. Changes to the hosted server happen in the Edgaze product.

## License

MIT. Copyright Edge Platforms, Inc.
