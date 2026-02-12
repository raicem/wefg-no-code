# WEFG No Code

This repository helps AI agents and developers generate valid WordPress WXR files from any source system, in any programming language, and verify the result against a real WordPress importer workflow.

## Quick start

1. Fetch pinned upstream reference artifacts:

```bash
./scripts/fetch-reference-artifacts.sh
```

2. Generate your WXR file with the language/tooling of your choice.

3. Verify import against local WordPress:

```bash
./scripts/verify-import.sh path/to/generated.wxr.xml
```

## Problem framing

- Migrating content into WordPress is easy to get almost right and hard to get fully right.
- A WXR file can be well-formed XML but still fail to import correctly.
- LLMs can generate exporter code quickly, but they must validate behavior against the real importer, not only schema assumptions.
- This repo defines a practical loop: generate exporter code -> generate WXR -> import with WP-CLI -> inspect result -> fix and retry.

## WXR primer (short)

WXR is RSS 2.0 plus WordPress namespaces. At minimum, a practical file contains:

- `rss/channel` metadata (`title`, `link`, `description`, `pubDate`, `language`)
- `wp:wxr_version`, `wp:base_site_url`, `wp:base_blog_url`
- optional authors (`wp:author`)
- optional taxonomy declarations (`wp:category`, `wp:tag`, `wp:term`)
- content items (`item`) with core post fields and optional taxonomies, meta, comments, and attachments

Typical item fields:

- `title`, `dc:creator`, `content:encoded`, `excerpt:encoded`
- `wp:post_id`, `wp:post_date`, `wp:post_type`, `wp:status`, `wp:post_name`
- optional `category` tags with `domain` and `nicename`
- optional `wp:postmeta`, `wp:comment`, `wp:attachment_url`

## Gotchas

- Namespace/version mismatch breaks parser assumptions. Keep WXR version and namespace URLs aligned.
- Parent terms/categories should be declared before children to avoid inconsistent parent mapping.
- Prefer CDATA for content-like fields. Handle embedded `]]>` safely.
- Non-ASCII term names need explicit slugs to avoid mismatch from naive slug generation.
- Attachment imports require reachable URLs; local `localhost` URLs may fail in containerized setups.
- "XML parses" is not enough: always validate by importing into WordPress with WP-CLI.

## Canonical upstream references (pinned permalinks)

- WordPress export generator:
  - https://github.com/WordPress/wordpress-develop/blob/53382085c45e6330cadb081153bae06e415dc6c7/src/wp-admin/includes/export.php
- WordPress export admin screen:
  - https://github.com/WordPress/wordpress-develop/blob/53382085c45e6330cadb081153bae06e415dc6c7/src/wp-admin/export.php
- WordPress importer engine:
  - https://github.com/WordPress/wordpress-importer/blob/b37d462c0f4540d4fc4b42afb1935879a0a3ff14/src/class-wp-import.php
- WordPress importer parsers:
  - https://github.com/WordPress/wordpress-importer/blob/b37d462c0f4540d4fc4b42afb1935879a0a3ff14/src/parsers/class-wxr-parser-simplexml.php
  - https://github.com/WordPress/wordpress-importer/blob/b37d462c0f4540d4fc4b42afb1935879a0a3ff14/src/parsers/class-wxr-parser-xml.php
  - https://github.com/WordPress/wordpress-importer/blob/b37d462c0f4540d4fc4b42afb1935879a0a3ff14/src/parsers/class-wxr-parser-regex.php
- WP-CLI import command:
  - https://github.com/wp-cli/import-command/blob/028a4856fc8b57ee536a5182d90a5605045087fa/src/Import_Command.php
- Official theme test data:
  - https://github.com/WordPress/theme-test-data/blob/b47acf980696897936265182cb684dca648476c7/themeunittestdata.wordpress.xml

## Local mirrored references

Run `./scripts/fetch-reference-artifacts.sh` first, then use these local files:

- `references/upstream/theme-test-data/themeunittestdata.wordpress.xml`
- `references/upstream/wordpress-develop/wp-admin/includes/export.php`
- `references/upstream/wordpress-develop/wp-admin/export.php`
- `references/upstream/wordpress-importer/src/class-wp-import.php`
- `references/upstream/wordpress-importer/src/parsers/class-wxr-parser-simplexml.php`
- `references/upstream/wordpress-importer/src/parsers/class-wxr-parser-xml.php`
- `references/upstream/wordpress-importer/src/parsers/class-wxr-parser-regex.php`
- `references/upstream/wp-cli/import-command/src/Import_Command.php`

## Human prompt ideas

Prompt templates for humans are kept in `README.md` to make onboarding easier.
