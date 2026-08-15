# Contributing

This repository is public manifests for a hosted MCP server. It is not the server implementation.

1. Open a pull request against `main`. Direct pushes are blocked.
2. Run `scripts/validate.sh` and keep CI green.
3. Keep the only server URL `https://mcp.edgaze.ai`.
4. Do not add implementation code, API keys, or a local `command`.
5. Do not open `/oauth/consent` by hand, and do not tell people to.

Client install steps that belong in product docs should go to [https://www.edgaze.ai/docs/mcp/connect](https://www.edgaze.ai/docs/mcp/connect) first, then a short pointer here.
