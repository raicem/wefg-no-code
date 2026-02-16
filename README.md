# WEFG No Code

A language-agnostic library for generating code that produces **valid WordPress WXR** files with AI and verifying them against a **real WordPress importer workflow**.

## Goal

If you are migrating content to WordPress, this library helps you generate exporter code (in any language) that produces valid WXR files WordPress can import.

It combines prompt examples, reference artifacts, and import verification scripts so you can move from source data to a valid WXR file with confidence.

## How to use this library

1. Clone this repository.
2. Open the folder in your AI coding agent of choice.
3. Start with the prompt examples in this README.
4. Put implementation code in `src/`, tests in `tests/`, and generated WXR output in `tmp/`.
5. Run the verification workflow and iterate until import checks pass.

Note: let your AI agent pull any needed reference artifacts and dependencies as part of its setup workflow.

If you want to adopt this as your own project template, you can remove `.git/` and reinitialize version control.

## Prompt examples

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
```
