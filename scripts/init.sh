#!/bin/sh
set -e

echo ">> Rendering credentials from environment"
node /scripts/render-credentials.js

echo ">> Importing credentials"
n8n import:credentials --input=/tmp/credentials.json
rm -f /tmp/credentials.json

if ls /workflows/*.json >/dev/null 2>&1; then
  echo ">> Importing workflows"
  n8n import:workflow --separate --input=/workflows

  # Activate (CLI differs between n8n versions; failure here is non-fatal)
  for f in /workflows/*.json; do
    id=$(node -e "console.log(require('$f').id||'')")
    [ -z "$id" ] && continue
    n8n publish:workflow --id="$id" 2>/dev/null \
      || n8n update:workflow --id="$id" --active=true 2>/dev/null \
      || echo "   (could not auto-activate $id, activate it in the UI)"
  done
else
  echo ">> No workflow JSON found in /workflows, skipping"
fi
echo ">> Init done"
