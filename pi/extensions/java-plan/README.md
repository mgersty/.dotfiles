# java-plan extension

Inspects a Java project and its `spec.md`, then generates an implementation
plan for completing the remaining code.

## Development

This extension is a standalone Node/TypeScript project. Its Pi packages are listed
as peer dependencies for the host runtime and as dev dependencies so TypeScript
language servers can resolve their declarations locally.

```sh
npm install
npm run typecheck
```

The extension is intentionally loaded from `index.ts` by Pi; the typecheck is
validation only and does not emit a build directory.

## Features

### `/java-plan [spec-path]`

1. Scans the current project (Maven/Gradle config, package layout, every
   `.java` file).
2. Detects incomplete work: `UnsupportedOperationException` stubs,
   "not implemented" comments, TODO/FIXME markers, and **types that are
   imported but not yet defined** (cross-referenced against the project
   root package).
3. Reads `spec.md` (auto-discovered: `spec.md`, `specs/spec.md`,
   `docs/spec.md`, …, or pass an explicit path as the argument).
4. Uses your current model to produce a phased implementation plan and
   writes it to `PLAN.md` in the project root, then shows it in a dialog.

### `java_project_inspect` tool

LLM-callable tool that returns the same compact survey (without
plan generation). Useful for follow-up work like "complete the remaining
code" — the agent gets a map of the codebase before reading individual files.

## How it works

- **Deterministic scan** (`scan.ts`): walks the tree (skipping `target`,
  `build`, `node_modules`, hidden dirs), regex-parses each Java file for
  package/types/methods/stubs/TODOs, cross-references imports against
  defined types to find missing classes, and best-effort parses
  `pom.xml` / `build.gradle(.kts)`.
- **LLM planning** (`index.ts`): one nested model call with the spec plus
  the survey, using the session's active model and its existing auth.

## Limits & heuristics

- Regex-based Java parsing: good for surveys, not a full parser.
- Missing-type detection only considers imports under the project's
  root package (longest common package prefix), so JDK/third-party imports
  are never flagged.
- Capped for large repos: 1500 files scanned, 400 listed, 60KB spec,
  50KB tool output (truncation is announced).

## Placement

Global: `~/.pi/agent/extensions/java-plan/` — available in every project.
Copy the directory into `<project>/.pi/extensions/` to make it
project-local instead.
