#!/usr/bin/env bash
# Writes .env.production (and a copy as .env.development) for store builds.
#
# BASE_URL comes from the PROD_BASE_URL environment variable (the workflows
# pass the repository variable of that name, or the production API by
# default), never from the ENV_PRODUCTION secret, so a stale or malformed
# secret can't ship a build that talks to the wrong server. ENV_PRODUCTION is
# optional and only adds the other keys (SUPPORT_EMAIL, PRIVACY_POLICY_URL).
set -euo pipefail

base_url="${PROD_BASE_URL%/}"
case "$base_url" in
  https://*) ;;
  *)
    echo "::error::PROD_BASE_URL must be an https:// URL (got '${base_url}')."
    exit 1
    ;;
esac
host="${base_url#https://}"
host="${host%%/*}"
case "$host" in
  localhost* | 127.* | 10.* | 192.168.* | 0.0.0.0*)
    echo "::error::PROD_BASE_URL points at a local address (${host})."
    exit 1
    ;;
esac

{
  # Drop Windows line endings and any BASE_URL from the secret.
  printf '%s\n' "${ENV_PRODUCTION:-}" | tr -d '\r' | grep -v -E '^[[:space:]]*(export[[:space:]]+)?BASE_URL[[:space:]]*=' || true
  echo "BASE_URL=${base_url}"
} > .env.production
# main.dart loads .env.production in release builds; this one only has to exist.
cp .env.production .env.development

echo "Store build uses BASE_URL=${base_url}"
echo "Keys in .env.production: $(grep -oE '^[A-Z_]+' .env.production | sort -u | tr '\n' ' ')"

# A warning only: the build shouldn't depend on the server being up.
status=$(curl -sS -m 20 -o /dev/null -w '%{http_code}' -X POST \
  -H 'Accept: application/json' "${base_url}/login" || true)
case "$status" in
  401 | 403 | 422) echo "API answered POST /login with HTTP ${status}, as expected." ;;
  *) echo "::warning::${base_url}/login answered HTTP ${status:-none}; check the server is up and BASE_URL is the API root." ;;
esac
