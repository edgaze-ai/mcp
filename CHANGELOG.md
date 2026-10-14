# Changelog

## 1.2.0 - 2026-10-14

Prepare the Claude plugin directory listing. Add a 1024 px listing icon (the mark on white) and the privacy policy, terms, support, and documentation URLs. Load the MCP server from `.mcp.json` only. Move the Cursor manifest to `.cursor-plugin/plugin.json` so Claude no longer finds an unused root `plugin.json`. Add the plugin install line to the README. CI runs `claude plugin validate --strict`.

## 1.1.0 - 2026-08-15

Add registry icons and the GitHub repository id. Sync the agent skill with hosted run presentation. Validate manifests in CI from vendored schemas.

## 1.0.0 - 2026-08-14

Initial public manifests for Agent Plugins, Claude Code, and the official MCP registry.
