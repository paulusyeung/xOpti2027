#!/usr/bin/env bash
# Secret scan for the repository and, optionally, a built image (task 7.2).
#
#   scripts/scan-secrets.sh                 # tracked files only
#   scripts/scan-secrets.sh --image NAME    # also scan a built container image
#
# Fails when a database password, private key, or analytics licence key is
# committed. Disposable test/smoke credentials are excluded by path.
set -euo pipefail
cd "$(dirname "$0")/.."

IMAGE=""
if [ "${1:-}" = "--image" ]; then
  IMAGE="${2:?usage: $0 [--image NAME]}"
fi

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
findings="$work/findings"
: >"$findings"

report() {
  echo "SECRET: $*" >&2
  echo "$*" >>"$findings"
}

# Literal secrets: URI credentials, key=value passwords, private keys, cloud keys.
# Placeholders (xopti, postgres, change-me, ${...}, %-encoded password markers,
# masked values) are allowed.
scan_stream() {
  local source="$1"
  {
    grep -InE 'postgres(ql)?://[^:/@[:space:]]+:[^@[:space:]]+@' "$source" 2>/dev/null \
      | grep -vE '://[^:]+:(xopti|postgres|change-me|\.\.\.)[^@]*@|://[^:]+:(\$|\{)' || true
    grep -InE '(^|[^A-Za-z_])[Pp]assword=[^;"[:space:]]{1,}' "$source" 2>/dev/null \
      | grep -vE '[Pp]assword=(xopti|postgres|\$|%|\*|<|\{)' || true
    grep -InE 'SECRET_KEY=[^[:space:]]{8,}' "$source" 2>/dev/null \
      | grep -vE 'SECRET_KEY=(\$|<|\{|\*)' || true
    grep -InE 'XOPTI_WPT_LICENSE_KEY=[^$[:space:]]{8,}' "$source" 2>/dev/null \
      | grep -vE 'XOPTI_WPT_LICENSE_KEY=(\$|\{|$)' || true
    grep -InE 'BEGIN (RSA |EC |OPENSSH |DSA )?PRIVATE KEY' "$source" 2>/dev/null || true
    grep -InE 'AKIA[0-9A-Z]{16}' "$source" 2>/dev/null || true
  } | while IFS= read -r line; do report "$line"; done
}

echo "Scanning tracked files for committed secrets..."
# Exclude documentation and disposable test fixtures: they contain example
# credentials and placeholder URIs by design.
while IFS= read -r -d '' file; do
  [ -f "$file" ] || continue
  # Binary assets cannot be reviewed as text and make grep buffer whole files.
  case "${file,,}" in
    *.mdb|*.rpt|*.rar|*.7z|*.zip|*.msi|*.exe|*.dll|*.xls|*.xlsx|*.ttf|*.ttc|*.otf|\
    *.png|*.jpg|*.jpeg|*.gif|*.bmp|*.ico|*.frx|*.cub|*.pdf|*.woff|*.woff2|*.eot|\
    *.chm|*.hlp|*.cab|*.msp|*.dat|*.bin|*.iso) continue ;;
  esac
  scan_stream "$file"
done < <(
  git ls-files -z \
    | grep -zvE '^(tests/|web/xOpti.Web/tests/|docs/|openspec/|scripts/scan-secrets\.sh$|.*\.md$|.*\.example$)'
)

if [ -n "$IMAGE" ]; then
  echo "Scanning image $IMAGE..."
  if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
    echo "image not found: $IMAGE" >&2
    exit 1
  fi

  # A development settings file must never ship.
  if docker run --rm --entrypoint sh "$IMAGE" -c 'test -e /app/appsettings.Development.json'; then
    report "image $IMAGE contains appsettings.Development.json"
  fi

  found="$(docker run --rm --entrypoint sh "$IMAGE" -c \
    'grep -RIlE "postgres(ql)?://[^:/@ ]+:[^@ ]+@|BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY|XOPTI_WPT_LICENSE_KEY=[^\$ ]{8,}" /app 2>/dev/null || true')"
  if [ -n "$found" ]; then
    while IFS= read -r line; do report "image $IMAGE: $line"; done <<<"$found"
  fi
fi

failures="$(wc -l <"$findings")"
if [ "$failures" -gt 0 ]; then
  echo "$failures secret finding(s)." >&2
  exit 1
fi

echo "Secret scan passed: no committed database password, private key, or analytics licence key."
