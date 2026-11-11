#!/usr/bin/env bash
# Regenerate api-contract/xopti.api.v1.json from a live xOpti.Api instance.
# Requires the API running (e.g. `dotnet run --project src/xOpti.Api`) and
# ConnectionStrings:XOptiDatabase pointing at the dev/migrated database.
set -euo pipefail
cd "$(dirname "$0")/.."

API_URL="${1:-http://127.0.0.1:5199}"

curl -fsS "${API_URL}/openapi/v1.json" > api-contract/xopti.api.v1.json
npx -y openapi-typescript@7 api-contract/xopti.api.v1.json -o api-contract/generated/xopti-client.ts

echo "Exported contract from ${API_URL} and regenerated the TypeScript client."
