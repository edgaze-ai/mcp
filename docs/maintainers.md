# Maintainers

Public install docs live at [https://www.edgaze.ai/docs/mcp](https://www.edgaze.ai/docs/mcp). This file is for people who edit the manifests.

## Versions

`.claude-plugin/plugin.json`, `.cursor-plugin/plugin.json`, and `server.json` share one version. Bump it when a published manifest changes.

## Validate

```bash
scripts/validate.sh
```

CI runs the same script. Schemas are vendored under `schemas/`. Refresh them only when the published schema URL changes.

## Official MCP registry

Prepare only. Do not publish from a script.

1. Generate an Ed25519 keypair with OpenSSL 3.
2. Publish a DNS TXT record on the apex of `edgaze.ai`: `v=MCPv1; k=ed25519; p=<base64>`.
3. `mcp-publisher login dns --domain=edgaze.ai --private-key=<hex>`
4. `mcp-publisher validate`

Stop there unless you intend to publish a new immutable version.

## Claude plugin directory

The plugin is the repository root. `.claude-plugin/plugin.json` holds the listing fields (`icon`, `privacyPolicyUrl`, `termsOfServiceUrl`, `supportUrl`, `documentationUrl`), and `.mcp.json` is the only MCP server declaration. Do not add `mcpServers` to `plugin.json`: a second declaration silently replaces the first.

`.claude-plugin/icon.png` is the listing icon: a square PNG, 512 to 2048 px, under 2 MB. The directory reads it once, the first time the plugin is saved or submitted. Replacing the file later does not change the listing.

```bash
claude plugin validate --strict .
```

Then use **Validate** in the developer portal at claude.ai/directory/manage before submitting.

## Cursor marketplace

The listing URL is this repository: `https://github.com/edgaze-ai/mcp`. Submit from [cursor.com/marketplace/publish](https://cursor.com/marketplace/publish) only after `scripts/validate.sh` passes and the stranger check in the product repo is done.
