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

The plugin is the repository root. `.claude-plugin/plugin.json` sets no listing fields, and `.mcp.json` is the only MCP server declaration. Every listing field in `plugin.json` (`privacyPolicyUrl` included) adds an unrecognized-field warning in the portal. The directory takes the privacy policy URL from the README, so keep the privacy policy link there, along with the terms, support, and documentation links. Do not add `mcpServers` to `plugin.json`. Claude Code loads `.mcp.json` first and then merges the manifest's servers, and a manifest entry with the same server name silently replaces the `.mcp.json` entry.

The listing icon is the PNG at the directory's default location in `.claude-plugin/`: square, 512 to 2048 px, under 2 MB. The directory reads it once, the first time the plugin is saved or submitted. Replacing the file later does not change the listing.

Never name the icon, or any bundled image, in a manifest, script, or doc. The directory holds a version for review when anything it can follow from a script reaches an image file. The Cursor manifest uses the hosted logo on www.edgaze.ai for the same reason. `scripts/validate.sh` fails on a bundled image path in any text file.

```bash
claude plugin validate --strict .
```

Then use **Validate** in the developer portal at claude.ai/directory/manage before submitting.

## Cursor marketplace

The listing URL is this repository: `https://github.com/edgaze-ai/mcp`. Submit from [cursor.com/marketplace/publish](https://cursor.com/marketplace/publish) only after `scripts/validate.sh` passes and the stranger check in the product repo is done.
