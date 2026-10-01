#!/usr/bin/env bash
# Apply m86-operations-db schema to a MariaDB instance.
#
#   ./deploy.sh <env> [--apply]
#
# <env> selects a connection file: ~/.m86-operations/<env>.cnf (mysql option file with
# host/port/user/password/database). Without --apply this is a dry run that lists
# the pending migrations and seed files.
#
# Order: migrations/NNN_*.sql (each recorded in schema_migrations, applied once),
# then data/*.sql (idempotent seeds, always re-applied).
set -euo pipefail

ENV_NAME="${1:-}"
APPLY="${2:-}"
if [[ -z "$ENV_NAME" ]]; then
  echo "usage: $0 <env> [--apply]" >&2
  exit 2
fi

CNF="${M86_OPS_DB_CNF:-$HOME/.m86-operations/${ENV_NAME}.cnf}"
if [[ ! -f "$CNF" ]]; then
  echo "missing connection file: $CNF" >&2
  exit 2
fi

HERE="$(cd "$(dirname "$0")" && pwd)"
MYSQL=(mariadb --defaults-extra-file="$CNF" --batch --skip-column-names)
command -v mariadb >/dev/null || MYSQL[0]=mysql

"${MYSQL[@]}" -e "CREATE TABLE IF NOT EXISTS schema_migrations (version varchar(100) NOT NULL PRIMARY KEY, applied_ts datetime NOT NULL DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" \
  || { echo "cannot reach database for env '$ENV_NAME'" >&2; exit 1; }

applied="$("${MYSQL[@]}" -e "SELECT version FROM schema_migrations")"

pending=()
for f in "$HERE"/migrations/[0-9][0-9][0-9]_*.sql; do
  v="$(basename "$f" .sql)"
  grep -qx "$v" <<<"$applied" || pending+=("$f")
done

echo "env: $ENV_NAME"
echo "pending migrations: ${#pending[@]}"
for f in "${pending[@]}"; do echo "  $(basename "$f")"; done
echo "seed files:"
for f in "$HERE"/data/*.sql; do echo "  $(basename "$f")"; done

if [[ "$APPLY" != "--apply" ]]; then
  echo "dry run - re-run with --apply to execute"
  exit 0
fi

for f in "${pending[@]}"; do
  v="$(basename "$f" .sql)"
  echo "applying $v"
  "${MYSQL[@]}" < "$f"
  "${MYSQL[@]}" -e "INSERT INTO schema_migrations (version) VALUES ('$v')"
done

for f in "$HERE"/data/*.sql; do
  echo "seeding $(basename "$f")"
  "${MYSQL[@]}" < "$f"
done

echo "done"
