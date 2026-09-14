/**
 * Java Plan Extension
 *
 * Inspects a Java project (structure, build config, stubs, TODOs,
 * missing types) plus its spec.md, and generates an implementation
 * plan for completing the remaining code.
 *
 * Features:
 * - /java-plan [spec-path]  — scan project, generate plan via LLM,
 *                             write PLAN.md, show it in a dialog
 * - java_project_inspect tool — compact codebase survey the LLM can
 *                             call in any workflow (e.g. "finish the code")
 */

import { uuidv7 } from "@earendil-works/pi-ai";
import type {
  ExtensionAPI,
  ExtensionCommandContext,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import {
  DynamicBorder,
  getMarkdownTheme,
  truncateHead,
  formatSize,
  DEFAULT_MAX_BYTES,
  DEFAULT_MAX_LINES,
  withFileMutationQueue,
} from "@earendil-works/pi-coding-agent";
import { Container, Markdown, matchesKey, Text } from "@earendil-works/pi-tui";
import { Type } from "typebox";
import { writeFile } from "node:fs/promises";
import { join, resolve } from "node:path";
import { scanProject, renderSurvey, type ProjectSurvey } from "./scan.ts";

const PLAN_FILE = "PLAN.md";
const EXT_NAME = "java-plan";

// ---------------------------------------------------------------------------
// Planning prompt
// ---------------------------------------------------------------------------

function buildPlanPrompt(survey: ProjectSurvey): string {
  const projectName =
    survey.project?.artifactId ??
    survey.root.split("/").pop() ??
    "project";

  const codeSection = renderSurvey(survey, { includeSpec: false });
  const spec = survey.spec!;

  return `You are producing an implementation plan for completing a Java project.

=== PROJECT SPECIFICATION (from ${spec.path}${spec.truncated ? ", truncated" : ""}) ===
${spec.content.trimEnd()}
=== END SPECIFICATION ===

=== CODEBASE SURVEY (automated scan of the repository) ===
${codeSection}
=== END SURVEY ===

TASK
Produce a concrete, ordered implementation plan that completes the remaining code so the project satisfies the specification.

RULES
- Base the plan only on the spec and the survey above. Do not invent files or classes that are not present in the survey; if something you would expect is missing, put it under "Open questions".
- Treat "Missing types" and "Incomplete markers" (stubs, TODO/FIXME) as the primary gap signals, then cross-check every spec requirement against the existing code.
- Prefer small, reviewable steps. Order phases so the project still compiles after each phase.
- Cite exact file paths from the survey. Do not include code blocks; describe changes.
- If the survey is truncated, note assumptions under "Open questions".

OUTPUT (strict markdown, exactly these sections)
# Implementation Plan: ${projectName}

## 1. Current state
2-5 sentences: what exists and is complete.

## 2. Gaps
Bullet list. Each bullet: a spec requirement (quote the spec section) → what is missing or incomplete, with file paths.

## 3. Phased plan
### Phase 1: <name>
1. **<step>** — <what to do>. Files: \`<create|modify> <path>\`. Depends on: <step numbers or —>. Check: <how to verify>.
### Phase 2: <name>
...
Continue until every gap from section 2 is covered.

## 4. Testing & verification
- Build command(s) for this project (infer from the build system).
- Unit/integration tests to add, mapped to phases.
- How to verify end-to-end that the spec is satisfied.

## 5. Risks & open questions
- Ambiguities in the spec, design decisions that need a call, external unknowns.`;
}

// ---------------------------------------------------------------------------
// Plan dialog
// ---------------------------------------------------------------------------

async function showPlanDialog(plan: string, ctx: ExtensionContext): Promise<void> {
  await ctx.ui.custom((_tui, theme, _kb, done) => {
    const container = new Container();
    const border = new DynamicBorder((s: string) => theme.fg("accent", s));
    const mdTheme = getMarkdownTheme();

    container.addChild(border);
    container.addChild(new Text(theme.fg("accent", theme.bold(" Java Implementation Plan ")), 1, 0));
    container.addChild(new Markdown(plan, 1, 1, mdTheme));
    container.addChild(new Text(theme.fg("dim", "Press Enter or Esc to close"), 1, 0));
    container.addChild(border);

    return {
      render: (width: number) => container.render(width),
      invalidate: () => container.invalidate(),
      handleInput: (data: string) => {
        if (matchesKey(data, "enter") || matchesKey(data, "escape")) {
          done(undefined);
        }
      },
    };
  });
}

// ---------------------------------------------------------------------------
// Shared scan helper
// ---------------------------------------------------------------------------

function fail(ctx: ExtensionCommandContext, message: string): void {
  ctx.ui.setStatus(EXT_NAME, undefined);
  if (ctx.hasUI) ctx.ui.notify(message, "error");
}

// ---------------------------------------------------------------------------
// Extension
// ---------------------------------------------------------------------------

export default function (pi: ExtensionAPI): void {
  // -- Tool: compact project survey for the LLM -----------------------------
  pi.registerTool({
    name: "java_project_inspect",
    label: "Java Project Inspect",
    description:
      "Survey a Java project: build config (Maven/Gradle), package layout, per-file " +
      "class/interface summary, stub markers (UnsupportedOperationException, 'not implemented'), " +
      "TODO/FIXME markers, types that are imported but not yet defined, and the contents of " +
      "spec.md (or an explicit spec path). Returns a compact text report to use before reading " +
      "individual files when planning or completing Java work.",
    promptSnippet:
      "Survey a Java project (layout, stubs, TODOs, missing types, spec.md) before planning or completing code",
    promptGuidelines: [
      "Use java_project_inspect first when asked to plan, review, or complete a Java project — it gives a compact map of the codebase and spec.md before individual files need to be read.",
    ],
    parameters: Type.Object({
      spec_path: Type.Optional(
        Type.String({
          description:
            "Path to the spec file, relative to the project root or absolute. " +
            "Defaults to auto-discovery (spec.md, specs/spec.md, docs/spec.md, ...).",
        }),
      ),
    }),
    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      const root = ctx.cwd;
      const survey = await scanProject(root, { specPath: params.spec_path });

      if (survey.totalJavaFiles === 0 && !survey.spec) {
        throw new Error(
          `No Java source files and no spec.md found in ${root}. Are you in a Java project?`,
        );
      }

      const report = renderSurvey(survey);
      const truncation = truncateHead(report, {
        maxLines: DEFAULT_MAX_LINES,
        maxBytes: DEFAULT_MAX_BYTES,
      });
      let text = truncation.content;
      if (truncation.truncated) {
        text += `\n\n[Survey truncated: ${formatSize(truncation.outputBytes)} of ${formatSize(truncation.totalBytes)}; ${truncation.outputLines} of ${truncation.totalLines} lines. Re-run with a narrower spec_path or inspect files directly for the rest.]`;
      }

      return {
        content: [{ type: "text", text }],
        details: {
          root,
          javaFiles: survey.totalJavaFiles,
          missingTypes: survey.missingTypes.length,
          stubs: survey.stats.stubs,
          todos: survey.stats.todos,
          specPath: survey.spec?.path,
        },
      };
    },
  });

  // -- Command: /java-plan [spec-path] --------------------------------------
  pi.registerCommand("java-plan", {
    description:
      "Inspect the Java project + spec.md and generate PLAN.md (implementation plan to finish the code). Optional arg: path to spec file.",
    handler: async (args, ctx) => {
      await ctx.waitForIdle();
      const specArg = args?.trim() || undefined;

      ctx.ui.setStatus(EXT_NAME, "Scanning Java project…");
      let survey: ProjectSurvey;
      try {
        survey = await scanProject(ctx.cwd, { specPath: specArg });
      } catch (err) {
        fail(ctx, `Scan failed: ${err instanceof Error ? err.message : String(err)}`);
        return;
      }

      if (survey.totalJavaFiles === 0) {
        fail(ctx, `No Java source files found in ${ctx.cwd}`);
        return;
      }
      if (!survey.spec) {
        fail(
          ctx,
          `No spec.md found (looked in ${ctx.cwd}). Pass a path explicitly: /java-plan path/to/spec.md`,
        );
        return;
      }

      const model = ctx.model;
      if (!model) {
        fail(ctx, "No model selected for plan generation. Select a model first (/model).");
        return;
      }
      if (!ctx.modelRegistry.hasConfiguredAuth(model)) {
        fail(ctx, `No authentication configured for ${model.provider}/${model.id}. Run /login.`);
        return;
      }

      const prompt = buildPlanPrompt(survey);
      ctx.ui.setStatus(
        EXT_NAME,
        `Generating plan with ${model.provider}/${model.id} (${survey.totalJavaFiles} files, ${survey.missingTypes.length} missing types)…`,
      );

      let planText: string;
      try {
        const response = await ctx.modelRegistry.complete(
          model,
          {
            messages: [
              {
                role: "user",
                content: [{ type: "text", text: prompt }],
                timestamp: Date.now(),
              },
            ],
          },
          {
            cacheRetention: "none",
            sessionId: uuidv7(),
            ...(ctx.signal ? { signal: ctx.signal } : {}),
          },
        );
        planText = response.content
          .filter((c): c is { type: "text"; text: string } => c.type === "text")
          .map((c) => c.text)
          .join("\n")
          .trim();
      } catch (err) {
        fail(ctx, `Plan generation failed: ${err instanceof Error ? err.message : String(err)}`);
        return;
      }

      if (!planText) {
        fail(ctx, "Plan generation returned an empty response.");
        return;
      }

      const planPath = resolve(ctx.cwd, PLAN_FILE);
      try {
        await withFileMutationQueue(planPath, async () => {
          await writeFile(planPath, planText + "\n", "utf8");
        });
      } catch (err) {
        fail(ctx, `Failed to write ${PLAN_FILE}: ${err instanceof Error ? err.message : String(err)}`);
        return;
      }

      ctx.ui.setStatus(EXT_NAME, undefined);
      if (ctx.hasUI) {
        ctx.ui.notify(`${PLAN_FILE} written (${formatSize(planText.length)})`, "info");
        try {
          await showPlanDialog(planText, ctx);
        } catch {
          // Dialog is non-essential; the file is already written.
        }
      }
    },
  });
}
