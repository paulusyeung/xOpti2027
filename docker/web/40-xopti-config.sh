#!/bin/sh
# Runs from the nginx image's /docker-entrypoint.d hook before nginx starts.
# Writes /config.json (runtime configuration) from container environment.
# Missing or invalid values disable the optional feature; the licence key is never logged.
set -eu

target="/usr/share/nginx/html/config.json"

case "$(printf '%s' "${XOPTI_ANALYTICS_ENABLED:-false}" | tr '[:upper:]' '[:lower:]')" in
  1|true|yes|on) enabled=true ;;
  *) enabled=false ;;
esac

key="${XOPTI_WPT_LICENSE_KEY:-}"
if [ -n "$key" ] && printf '%s' "$key" | grep -q '[[:cntrl:]]'; then
  echo "xopti: XOPTI_WPT_LICENSE_KEY contains control characters and is ignored" >&2
  key=""
fi

if [ -n "$key" ]; then
  escaped=$(printf '%s' "$key" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')
  key_json="\"${escaped}\""
else
  key_json="null"
fi

printf '{"analyticsEnabled": %s, "wptLicenseKey": %s}\n' "$enabled" "$key_json" > "$target"
chmod 0644 "$target"
echo "xopti: wrote runtime config (analyticsEnabled=${enabled}, licenceKey=$([ -n "$key" ] && echo set || echo unset))"
