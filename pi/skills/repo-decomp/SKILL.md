---
name: repo-decomp
description: Ask the user what they would like to know about the code repository.
---

- Ask the user what they would like to know about the repository.
- Based on their question:
    1. Find all relevant files.
    2. Understand how they relate — data flow, dependencies, entry points.
    3. Create a summary markdown file in the same directory.

## Report structure

Write the report so it reads as one connected story, not a list of file notes. Order matters:

1. **TLDR** — 2-3 short paragraphs answering the question directly. End with 3-5 bullet
   "key ideas" that capture the design in one line each (e.g. naming the core abstractions,
   the data model, the extension model).
2. **Architecture diagram** — one ASCII diagram showing the main layers/modules and how the question's subject flows through them. This is the map the rest of the report follows.
3. **Key logical flow** — one ASCII diagram of the primary flow the question is about (e.g. "one prompt, one turn"), so readers see the system in motion.
4. **Important modules and files** — a table (path → one-line role) covering everything the
   sections below will discuss, ordered so the table itself reads top-to-bottom like the
   narrative.
5. **Per-file sections** — one section per relevant file, in *narrative order* (how a reader
   would naturally traverse the system: entry point → core → supporting pieces), not
   alphabetical. Each section:
   - a 1-2 sentence lead saying what this file is and why it matters for the question
     (connect it to the previous section: "this is where X from above is implemented").
   - a short code snippet reinforcing the answer, **with the file path and line numbers
     referenced** (see guardrails).
   - a 1-2 sentence "why it matters" tying the snippet back to the big picture.
   - a small ASCII diagram only when it adds clarity beyond the text (a call graph, a data
     layout, a state machine) — skip it when prose suffices.
6. **End-to-end sequence** — one final ASCII sequence diagram tracing the whole scenario
   across all major components, closing the loop from the opening diagram.

## Voice and concision

- Every section should earn its place: if a detail doesn't serve the user's question, cut it.
- Prefer "why this design" over "what this code does" — the code is visible; the report's job
  is the reasoning a reader can't get by skimming files.
- Cross-reference between sections ("as shown in the diagram above", "this fills in the hook
  from section 2") so the pieces visibly connect.
- Keep code snippets minimal — just the lines that prove the point, not whole functions.

## Delivery

- Send the report to $PERSONAL_NOTES_HOME/learning with the tags `learning` and the name of
  the code base, plus frontmatter tags that reflect the code base's domain.

## Guardrails
- All code blocks that have code snippets need to reference the file and the lines within
  that snippet (e.g. `// agent-loop.ts:120-145` in the block or immediately above it).
- within text sections only the end of a sentance should carry a new line
