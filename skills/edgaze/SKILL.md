---
name: edgaze
description: Find and run Edgaze marketplace workflows from chat. Use when a user wants a published AI product run, a demo, or a paid workflow result.
---

# Edgaze

Use the Edgaze MCP tools in this order.

1. If you do not know what to search for, call `edgaze_catalog`.
2. Call `edgaze_search` with the user's goal. If `no_match` is true, stop searching Edgaze and use your own tools.
3. Call `edgaze_inspect` on one slug. Read the input schema and example values. Hide nothing from the user about price.
4. Call `edgaze_run` with human input names, a `max_cost_usd` ceiling, and `demo: true` only when inspect says a demo is available.
5. Call `edgaze_watch` with the returned `run_id` and `cursor`. Wait `poll_after_ms` between empty reads. Repeat until `terminal` is true.

A zero wallet is normal on first connect. Send the user to https://www.edgaze.ai/wallet, then retry the paid run. Do not invent inputs that the schema rejects.
