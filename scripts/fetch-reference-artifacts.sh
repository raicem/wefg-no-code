#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

FORCE=0
if [[ "${1:-}" == "--force" ]]; then
  FORCE=1
fi

download_artifact() {
  local rel_path="$1"
  local url="$2"
  local expected_sha="$3"

  local destination="${REPO_ROOT}/${rel_path}"
  local destination_dir
  destination_dir="$(dirname "${destination}")"

  mkdir -p "${destination_dir}"

  if [[ -f "${destination}" && "${FORCE}" -eq 0 ]]; then
    local existing_sha
    existing_sha="$(sha256sum "${destination}" | cut -d ' ' -f 1)"
    if [[ "${existing_sha}" == "${expected_sha}" ]]; then
      echo "OK    ${rel_path}"
      return 0
    fi
  fi

  local temp_file
  temp_file="$(mktemp)"

  echo "GET   ${url}"
  curl -fsSL "${url}" -o "${temp_file}"

  local actual_sha
  actual_sha="$(sha256sum "${temp_file}" | cut -d ' ' -f 1)"
  if [[ "${actual_sha}" != "${expected_sha}" ]]; then
    rm -f "${temp_file}"
    echo "ERROR checksum mismatch for ${rel_path}" >&2
    echo "      expected ${expected_sha}" >&2
    echo "      actual   ${actual_sha}" >&2
    exit 1
  fi

  mv "${temp_file}" "${destination}"
  echo "SAVE  ${rel_path}"
}

echo "Fetching pinned upstream reference artifacts..."

download_artifact \
  "references/upstream/theme-test-data/themeunittestdata.wordpress.xml" \
  "https://raw.githubusercontent.com/WordPress/theme-test-data/b47acf980696897936265182cb684dca648476c7/themeunittestdata.wordpress.xml" \
  "457aace6ec93cf77369bbcc6158996e52da8798bd5e39c83d58dfab9b50d64fa"

download_artifact \
  "references/upstream/wordpress-develop/wp-admin/includes/export.php" \
  "https://raw.githubusercontent.com/WordPress/wordpress-develop/53382085c45e6330cadb081153bae06e415dc6c7/src/wp-admin/includes/export.php" \
  "897111daa379171a5210e21a055a50841eb3884e99508367f3673f33f5a5a18a"

download_artifact \
  "references/upstream/wordpress-develop/wp-admin/export.php" \
  "https://raw.githubusercontent.com/WordPress/wordpress-develop/53382085c45e6330cadb081153bae06e415dc6c7/src/wp-admin/export.php" \
  "956911bb9f675c93be60439b84490be4b67571eedecf4224bcfe064c8340b343"

download_artifact \
  "references/upstream/wordpress-importer/src/class-wp-import.php" \
  "https://raw.githubusercontent.com/WordPress/wordpress-importer/b37d462c0f4540d4fc4b42afb1935879a0a3ff14/src/class-wp-import.php" \
  "888a88536a4121216f9aecd463d01e503874f8a72619784f7689282d13692e50"

download_artifact \
  "references/upstream/wordpress-importer/src/parsers/class-wxr-parser-simplexml.php" \
  "https://raw.githubusercontent.com/WordPress/wordpress-importer/b37d462c0f4540d4fc4b42afb1935879a0a3ff14/src/parsers/class-wxr-parser-simplexml.php" \
  "fa29e0255f92ae65f040e88d6a53abe14601a535040de3434a23d6f6d1c35ecd"

download_artifact \
  "references/upstream/wordpress-importer/src/parsers/class-wxr-parser-xml.php" \
  "https://raw.githubusercontent.com/WordPress/wordpress-importer/b37d462c0f4540d4fc4b42afb1935879a0a3ff14/src/parsers/class-wxr-parser-xml.php" \
  "e12099a61edfae070741b2304d54d928cb6b8135bf19f9118e28b97874655f9c"

download_artifact \
  "references/upstream/wordpress-importer/src/parsers/class-wxr-parser-regex.php" \
  "https://raw.githubusercontent.com/WordPress/wordpress-importer/b37d462c0f4540d4fc4b42afb1935879a0a3ff14/src/parsers/class-wxr-parser-regex.php" \
  "2c86ec75bfda063c4d1b4e41d217f965c3532983e3db08c3a69c8715e6db56d1"

download_artifact \
  "references/upstream/wp-cli/import-command/src/Import_Command.php" \
  "https://raw.githubusercontent.com/wp-cli/import-command/028a4856fc8b57ee536a5182d90a5605045087fa/src/Import_Command.php" \
  "09af8a9f4a7ca925241e8485e06ef7b136f9f4a2bdef7a397f8fbd892498bae3"

echo "Done."
