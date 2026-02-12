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

## Workspace conventions

- Put generated/exporter source code under `src/`.
- Put tests under `tests/`.
- Write generated WXR outputs to `tmp/` (already gitignored), e.g. `tmp/generated.wxr.xml`.
- Save WXR to a file path inside this repo (do not leave output only on stdout).

These conventions keep generated work contained so users can own and iterate on the same folders.

## Prompt ideas

### 1) Generate exporter code

```text
You are implementing a WXR exporter in <LANGUAGE>.

Goal:
- Convert input data into a valid WXR 1.2 XML file importable by WordPress Importer.

Use these references first:
- Local: references/upstream/... (if present)
- Then pinned permalinks listed in AGENTS.md

Repository conventions:
- Write implementation code only in `src/`.
- Write tests only in `tests/`.
- Write generated WXR output to `tmp/generated.wxr.xml`.
- Save the WXR file to disk in this repository and print the final file path.

Requirements:
- Produce valid XML with required namespaces and channel fields.
- Support posts with title/content/excerpt/author/date/slug/status/type.
- Support categories, tags, custom taxonomy terms, post meta, comments.
- Keep behavior deterministic (stable IDs/slugs where possible).

Deliverables:
1) Exporter source code.
2) Tests under `tests/` plus command to run them.
3) Command to generate `tmp/generated.wxr.xml`.
4) Brief note on assumptions.
```

### 2) Self-check and fix loop

```text
Now verify and fix your generated WXR end-to-end.

Steps:
1) Run tests from `tests/`.
2) Run `./scripts/verify-import.sh tmp/generated.wxr.xml`.
3) If import or assertions fail, inspect errors and update code/tests.
4) Regenerate XML and rerun verification.
5) Repeat until verification passes.

Rules:
- Do not stop at XML validity checks.
- Success means WordPress import succeeds and sanity checks pass.
- Report final command outputs briefly and list key fixes made.
```

## More detail

For WXR primer, gotchas, and pinned reference permalinks, see `AGENTS.md`.

## JS simulation workflow

This repo includes a small JavaScript exporter simulation in `src/` and tests in `tests/`:

```bash
node --test tests/export-wxr.test.mjs
node src/export-wxr.mjs tests/fixtures/sample-input.json tmp/generated.wxr.xml
./scripts/verify-import.sh tmp/generated.wxr.xml
```
