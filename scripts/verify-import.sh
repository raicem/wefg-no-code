#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [[ $# -ne 1 ]]; then
  echo "Usage: ./scripts/verify-import.sh path/to/generated.wxr.xml" >&2
  exit 1
fi

INPUT_WXR="$1"
if [[ ! -f "${INPUT_WXR}" ]]; then
  echo "Input file not found: ${INPUT_WXR}" >&2
  exit 1
fi

INPUT_WXR_ABS="$(realpath "${INPUT_WXR}")"
TMP_DIR="${REPO_ROOT}/tmp"
LOCAL_WXR_COPY="${TMP_DIR}/verify-input.wxr.xml"
CONTAINER_WXR_PATH="/workspace/tmp/verify-input.wxr.xml"

mkdir -p "${TMP_DIR}"
cp "${INPUT_WXR_ABS}" "${LOCAL_WXR_COPY}"

wp_cli() {
  docker compose run --rm -T wpcli --allow-root --path=/var/www/html "$@"
}

wait_for_wordpress_files() {
  local max_retries=60
  local attempt=1

  while (( attempt <= max_retries )); do
    if docker compose run --rm -T --entrypoint sh wpcli -lc "test -f /var/www/html/wp-settings.php" >/dev/null 2>&1; then
      return 0
    fi

    sleep 1
    attempt=$((attempt + 1))
  done

  echo "Timed out waiting for WordPress files in shared volume." >&2
  exit 1
}

wait_for_database() {
  local max_retries=60
  local attempt=1

  while (( attempt <= max_retries )); do
    if wp_cli db check >/dev/null 2>&1; then
      return 0
    fi

    sleep 1
    attempt=$((attempt + 1))
  done

  echo "Timed out waiting for database readiness." >&2
  exit 1
}

echo "Starting WordPress stack..."
docker compose up -d db wordpress >/dev/null

echo "Waiting for WordPress files..."
wait_for_wordpress_files

if ! docker compose run --rm -T --entrypoint sh wpcli -lc "test -f /var/www/html/wp-config.php" >/dev/null 2>&1; then
  echo "Creating wp-config.php..."
  wp_cli config create \
    --dbname=wordpress \
    --dbuser=wordpress \
    --dbpass=wordpress \
    --dbhost=db:3306 \
    --force \
    --skip-check >/dev/null
fi

echo "Waiting for database..."
wait_for_database

echo "Resetting database..."
wp_cli db reset --yes >/dev/null

echo "Installing WordPress..."
wp_cli core install \
  --url=http://localhost:8080 \
  --title="WEFG No Code" \
  --admin_user=admin \
  --admin_password=password \
  --admin_email=admin@example.com \
  --skip-email >/dev/null

echo "Installing importer plugin..."
wp_cli plugin install wordpress-importer --activate >/dev/null

echo "Importing WXR..."
wp_cli import "${CONTAINER_WXR_PATH}" --authors=create --skip=image_resize >/dev/null

post_count="$(wp_cli post list --format=count)"
user_count="$(wp_cli user list --format=count)"
category_count="$(wp_cli term list category --format=count 2>/dev/null || true)"

if [[ "${post_count}" -lt 1 ]]; then
  echo "Import check failed: no posts were imported." >&2
  exit 1
fi

echo "Import verification passed."
echo "- posts: ${post_count}"
echo "- users: ${user_count}"
echo "- categories: ${category_count:-0}"
