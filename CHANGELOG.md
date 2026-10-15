# Changelog

## 1.2.3 - 2026-10-15

Publish the official MCP registry entry `ai.edgaze/edgaze` from this repository, with the GitHub `repository` field that GitHub's MCP Registry requires. `server.json` takes the published name and description and adds a 512 px icon. CI checks the registry name and repository.

## 1.2.2 - 2026-10-14

Remove `privacyPolicyUrl` from `plugin.json`. The plugin directory reads the privacy policy URL from the README, so the field only added a warning. Directory validation now reports no warnings.

## 1.2.1 - 2026-10-14

Clear the plugin directory's lint warnings and policy hold. The listing icon is found at its default path, so no manifest names an image file, and the Cursor manifest uses the hosted logo. `plugin.json` sets only `privacyPolicyUrl` among the listing fields; terms, support, and documentation links are in the README. The README adds example prompts and troubleshooting. The Claude app section of the client docs uses a custom connector, since `claude_desktop_config.json` does not configure remote servers.

## 1.2.0 - 2026-10-14

Prepare the Claude plugin directory listing. Add a 1024 px listing icon (the mark on white) and the privacy policy, terms, support, and documentation URLs. Load the MCP server from `.mcp.json` only. Move the Cursor manifest to `.cursor-plugin/plugin.json` so Claude no longer finds an unused root `plugin.json`. Add the plugin install line to the README. CI runs `claude plugin validate --strict`.

## 1.1.0 - 2026-08-15

Add registry icons and the GitHub repository id. Sync the agent skill with hosted run presentation. Validate manifests in CI from vendored schemas.

## 1.0.0 - 2026-08-14

Initial public manifests for Agent Plugins, Claude Code, and the official MCP registry.
