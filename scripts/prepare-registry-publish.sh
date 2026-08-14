#!/usr/bin/env bash
# Prepare-only. Does not publish.
# Run this ONLY after stranger check.

set -euo pipefail

echo "Prepare MCP registry publish (does not publish)"
echo
echo "1. Generate an Ed25519 keypair (OpenSSL 3+; on macOS use brew openssl@3):"
echo "   openssl genpkey -algorithm Ed25519 -out key.pem"
echo
echo "2. Extract the public key (base64):"
echo "   openssl pkey -in key.pem -pubout -outform DER | tail -c 32 | base64"
echo
echo "3. Add a DNS TXT record on the apex of edgaze.ai (not a selector):"
echo "   v=MCPv1; k=ed25519; p=<base64>"
echo
echo "4. Log in with DNS auth (does not publish):"
echo "   mcp-publisher login dns --domain=edgaze.ai --private-key=<hex>"
echo
echo "5. Validate server.json (does not publish):"
echo "   mcp-publisher validate"
echo
echo "Stop here. Do not run mcp-publisher publish."
