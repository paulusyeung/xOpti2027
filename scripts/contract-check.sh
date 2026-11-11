#!/usr/bin/env bash
# CI contract check: the committed TypeScript client must be exactly what the
# committed OpenAPI document generates. Any breaking document change without a
# regenerated client fails here. (Document-vs-live drift is covered by the
# xOpti.Api.IntegrationTests OpenApiDocument tests.)
set -euo pipefail
cd "$(dirname "$0")/.."

TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT

npx -y openapi-typescript@7 api-contract/xopti.api.v1.json -o "${TMP}/xopti-client.ts"

if ! diff -q "${TMP}/xopti-client.ts" api-contract/generated/xopti-client.ts > /dev/null; then
    echo "CONTRACT DRIFT: api-contract/generated/xopti-client.ts is out of sync with api-contract/xopti.api.v1.json" >&2
    diff -u "${TMP}/xopti-client.ts" api-contract/generated/xopti-client.ts | head -40 >&2 || true
    exit 1
fi

echo "Contract check passed."
