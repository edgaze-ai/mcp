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

The entry is `ai.edgaze/edgaze` on registry.modelcontextprotocol.io, and this repository's `server.json` is its only source. Registry names are permanent, and each version can be published once. Keep the `repository` block: GitHub's MCP Registry and other consumers read the repository from the entry.

Authentication is a DNS TXT record on the apex of `edgaze.ai` (`v=MCPv1; k=ed25519; p=<base64 public key>`). The matching Ed25519 private key is kept outside this repository, with Edgaze's other secrets. To set up or rotate the key (OpenSSL 3.0 or later):

```bash
openssl genpkey -algorithm Ed25519 -out mcp-registry-key.pem
openssl pkey -in mcp-registry-key.pem -pubout -outform DER | tail -c 32 | base64
openssl pkey -in mcp-registry-key.pem -outform DER | tail -c 32 | xxd -p -c 64
```

The second command prints the public key for the TXT record's `p=` value. The third prints the hex private key for `--private-key`. Publish the TXT record before you log in, and never commit the key.

To publish a new version, merge the version bump first, then from a clean `main`:

```bash
mcp-publisher validate
mcp-publisher login dns --domain=edgaze.ai --private-key=<hex>
mcp-publisher publish
```

Confirm the entry at `https://registry.modelcontextprotocol.io/v0/servers?search=edgaze`.

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
