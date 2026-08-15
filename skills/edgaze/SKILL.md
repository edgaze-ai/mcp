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
5. Call `edgaze_watch` with the returned `run_id` and `cursor`. Wait `poll_after_ms` between empty reads. Repeat until `terminal` is true. Then follow `present` and `how_to_show`.

`edgaze_run` and a finished `edgaze_watch` include `url`: `https://www.edgaze.ai/run/{id}`. That is the hosted run page.

- `present=chat`: deliver the result in this conversation. Paste usable text. If the workflow did something external, say what happened and include confirmations or links from the output. Do not dump raw JSON when a readable answer exists. Offer `url` if they want the full run page.
- `present=edgaze_page`: this chat cannot show the result well (images, video, files, large media). Give the user `url` so they can view and download it on Edgaze. A short caption is fine. Do not paste base64, data URIs, or binary.

A zero wallet is normal on first connect. Send the user to https://www.edgaze.ai/wallet, then retry the paid run. Do not invent inputs that the schema rejects.
