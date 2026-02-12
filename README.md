# wefg-no-code

A language-agnostic playbook for generating **valid WordPress WXR** files with AI and verifying them against a **real WordPress importer workflow**.

## Goal

Most WXR exporters fail in subtle ways: XML may be well-formed, but import behavior still breaks.

This repo gives you a repeatable loop:

1. Generate exporter code in any language (JS, Python, Ruby, etc.).
2. Produce a WXR file.
3. Import it with WP-CLI in a local WordPress instance.
4. Inspect failures and iterate until import checks pass.

## Quick start

```bash
./scripts/fetch-reference-artifacts.sh
./scripts/verify-import.sh path/to/generated.wxr.xml
```

`fetch-reference-artifacts.sh` downloads pinned upstream references (theme test data + exporter/importer source snapshots) into `references/upstream/`.

## Prompt ideas

### 1) Generate exporter code

```text
You are implementing a WXR exporter in <LANGUAGE>.

Goal:
- Convert input data into a valid WXR 1.2 XML file importable by WordPress Importer.

Use these references first:
- Local: references/upstream/... (if present)
- Then pinned permalinks listed in AGENTS.md

Requirements:
- Produce valid XML with required namespaces and channel fields.
- Support posts with title/content/excerpt/author/date/slug/status/type.
- Support categories, tags, custom taxonomy terms, post meta, comments.
- Keep behavior deterministic (stable IDs/slugs where possible).

Deliverables:
1) Exporter source code.
2) Command to generate `generated.wxr.xml`.
3) Brief note on assumptions.
```

### 2) Self-check and fix loop

```text
Now verify and fix your generated WXR end-to-end.

Steps:
1) Run `./scripts/verify-import.sh generated.wxr.xml`.
2) If import or assertions fail, inspect errors and update exporter code.
3) Regenerate XML and rerun verification.
4) Repeat until verification passes.

Rules:
- Do not stop at XML validity checks.
- Success means WordPress import succeeds and sanity checks pass.
- Report final command outputs briefly and list key fixes made.
```

## More detail

For WXR primer, gotchas, and pinned reference permalinks, see `AGENTS.md`.
