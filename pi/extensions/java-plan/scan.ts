/**
 * Java project scanner — pure Node logic, no pi imports.
 *
 * Walks a Java project, parses Java sources with regex heuristics,
 * cross-references imports against defined types, parses Maven/Gradle
 * build files, and locates spec.md. Produces a compact ProjectSurvey
 * plus a rendered text report.
 */

import { readdir, readFile, stat } from "node:fs/promises";
import { isAbsolute, join, relative, sep } from "node:path";

export type TypeKind = "class" | "interface" | "enum" | "record" | "annotation";

export interface TypeDecl {
  name: string;
  kind: TypeKind;
}

export interface Marker {
  line: number;
  text: string;
}

export interface JavaFileSummary {
  /** Relative path from project root */
  path: string;
  package: string;
  types: TypeDecl[];
  lines: number;
  methods: number;
  stubs: Marker[];
  todos: Marker[];
  imports: string[];
  isTest: boolean;
}

export interface MissingType {
  /** Fully-qualified type name (class part for static imports) */
  name: string;
  importedBy: string[];
}

export interface SpecInfo {
  path: string; // relative to project root when possible
  lines: number;
  truncated: boolean;
  content: string;
}

export interface ProjectSurvey {
  root: string;
  buildSystem: "maven" | "gradle" | "none";
  buildFile?: string;
  project?: { groupId?: string; artifactId?: string; version?: string };
  modules: string[];
  javaVersion?: string;
  dependencies: string[];
  sourceRoots: string[];
  javaFiles: JavaFileSummary[];
  totalJavaFiles: number;
  truncatedFiles: boolean;
  missingTypes: MissingType[];
  spec?: SpecInfo;
  stats: {
    files: number;
    lines: number;
    types: number;
    stubs: number;
    todos: number;
    missingTypes: number;
  };
}

export interface ScanOptions {
  specPath?: string;
  maxFiles?: number;
  maxSpecBytes?: number;
}

const SKIP_DIRS = new Set([
  "node_modules",
  "target",
  "build",
  "out",
  "bin",
  "dist",
  "generated",
  ".git",
  ".gradle",
  ".idea",
  ".vscode",
  ".mvn",
]);

const MAX_FILES_DEFAULT = 1500;
const MAX_SPEC_BYTES_DEFAULT = 60_000;

const PKG_RE = /^\s*package\s+((?:[a-zA-Z_$][\w$]*\.)+[a-zA-Z_$][\w$]*|[a-zA-Z_$][\w$]*)\s*;/m;
const IMPORT_RE = /^import\s+(static\s+)?([\w.]+)\s*;/gm;
const TYPE_RE =
  /^\s*(?:(?:public|protected|private|abstract|final|static|sealed|non-sealed|strictfp|@[\w$.]+)\s+)*(@interface|class|interface|enum|record)\s+([A-Za-z_$][\w$]*)/;
const METHOD_RE =
  /^\s*(?:(?:public|private|protected|static|final|synchronized|abstract|default|native|strictfp)\s+)*(?:<[^>]*>\s+)?(?:[\w$][\w$<>\[\], ?.&]*\s+)?([a-z_$][\w$]*)\s*\(/;
const METHOD_SKIP = new Set([
  "if", "for", "while", "switch", "catch", "return", "throw", "else", "do",
  "try", "assert", "synchronized", "new", "super", "this", "when", "sizeof",
]);
const TODO_RE = /\b(TODO|FIXME|XXX)\b/;
const STUB_RES = [
  /throw\s+new\s+UnsupportedOperationException/,
  /\/\/\s*(not\s+implemented|stub|unimplemented)\b/i,
];

// ---------------------------------------------------------------------------
// File walking
// ---------------------------------------------------------------------------

async function* walk(dir: string): AsyncGenerator<string> {
  let entries;
  try {
    entries = await readdir(dir, { withFileTypes: true });
  } catch {
    return;
  }
  for (const entry of entries) {
    const full = join(dir, entry.name);
    if (entry.isSymbolicLink()) continue;
    if (entry.isDirectory()) {
      if (entry.name.startsWith(".") || SKIP_DIRS.has(entry.name)) continue;
      yield* walk(full);
    } else if (entry.isFile() && entry.name.endsWith(".java")) {
      yield full;
    }
  }
}

// ---------------------------------------------------------------------------
// Java parsing
// ---------------------------------------------------------------------------

function parseJavaFile(absPath: string, relPath: string, content: string): JavaFileSummary {
  const linesArr = content.split("\n");
  const pkgMatch = content.match(PKG_RE);
  const pkg = pkgMatch ? pkgMatch[1] : "";

  const types: TypeDecl[] = [];
  const imports: string[] = [];
  const stubs: Marker[] = [];
  const todos: Marker[] = [];
  let methods = 0;

  for (let i = 0; i < linesArr.length; i++) {
    const line = linesArr[i];
    const lineNo = i + 1;

    const typeMatch = line.match(TYPE_RE);
    if (typeMatch) {
      const kindRaw = typeMatch[1];
      const kind: TypeKind =
        kindRaw === "@interface" ? "annotation"
        : kindRaw === "class" ? "class"
        : kindRaw === "interface" ? "interface"
        : kindRaw === "enum" ? "enum"
        : "record";
      types.push({ name: typeMatch[2], kind });
    }

    IMPORT_RE.lastIndex = 0;
    let importMatch: RegExpExecArray | null;
    while ((importMatch = IMPORT_RE.exec(line)) !== null) {
      imports.push(importMatch[2]);
    }

    if (METHOD_SKIP.has(line.trim().split(/\s|\(/)[0] ?? "")) {
      // handled below via regex name check; nothing to do here
    } else {
      const methodMatch = line.match(METHOD_RE);
      if (methodMatch && !METHOD_SKIP.has(methodMatch[1])) {
        methods++;
      }
    }

    if (TODO_RE.test(line)) {
      todos.push({ line: lineNo, text: line.trim().slice(0, 120) });
    }
    for (const re of STUB_RES) {
      if (re.test(line)) {
        stubs.push({ line: lineNo, text: line.trim().slice(0, 120) });
        break;
      }
    }
  }

  const isTest =
    relPath.includes(`${sep}src${sep}test${sep}`) ||
    relPath.includes(`${sep}src${sep}it${sep}`) ||
    /Test(s)?\.java$/.test(relPath) ||
    /IT\.java$/.test(relPath);

  return {
    path: relPath.split(sep).join("/"),
    package: pkg,
    types,
    lines: linesArr.length,
    methods,
    stubs,
    todos,
    imports,
    isTest,
  };
}

// ---------------------------------------------------------------------------
// Missing-type cross-reference
// ---------------------------------------------------------------------------

function computeRootPackage(packages: string[]): string {
  const withPkg = packages.filter(Boolean);
  if (withPkg.length === 0) return "";
  const segLists = withPkg.map((p) => p.split("."));
  const minLen = Math.min(...segLists.map((s) => s.length));
  const common: string[] = [];
  for (let i = 0; i < minLen; i++) {
    const seg = segLists[0][i];
    if (!segLists.every((s) => s[i] === seg)) break;
    common.push(seg);
  }
  return common.join(".");
}

function resolveMissingTypes(files: JavaFileSummary[]): MissingType[] {
  const defined = new Map<string, Set<string>>();
  for (const file of files) {
    if (!file.package) continue;
    let set = defined.get(file.package);
    if (!set) {
      set = new Set();
      defined.set(file.package, set);
    }
    for (const t of file.types) set.add(t.name);
  }
  if (defined.size === 0) return [];

  const rootPkg = computeRootPackage([...defined.keys()]);
  if (!rootPkg) return [];
  const prefix = rootPkg + ".";

  const missing = new Map<string, Set<string>>();
  for (const file of files) {
    for (const imp of file.imports) {
      if (imp !== rootPkg && !imp.startsWith(prefix)) continue;
      const typePart = imp; // IMPORT_RE does not capture the `static` flag; plain FQN
      const lastDot = typePart.lastIndexOf(".");
      if (lastDot <= 0) continue;
      const pkg = typePart.slice(0, lastDot);
      const typeName = typePart.slice(lastDot + 1);
      if (defined.get(pkg)?.has(typeName)) continue;
      let set = missing.get(typePart);
      if (!set) {
        set = new Set();
        missing.set(typePart, set);
      }
      set.add(file.path);
    }
  }

  return [...missing.entries()]
    .map(([name, importedBy]) => ({ name, importedBy: [...importedBy].sort() }))
    .sort((a, b) => a.name.localeCompare(b.name));
}

// ---------------------------------------------------------------------------
// Build file parsing (best-effort)
// ---------------------------------------------------------------------------

interface BuildInfo {
  buildSystem: "maven" | "gradle" | "none";
  buildFile?: string;
  project?: { groupId?: string; artifactId?: string; version?: string };
  modules: string[];
  javaVersion?: string;
  dependencies: string[];
}

function xmlTag(block: string, name: string): string | undefined {
  const m = block.match(new RegExp(`<${name}>([^<]*)</${name}>`));
  return m ? m[1].trim() : undefined;
}

function parseMavenPom(content: string): Omit<BuildInfo, "buildSystem"> {
  const xml = content.replace(/<!--[\s\S]*?-->/g, "");
  const parentBlock = xml.match(/<parent>([\s\S]*?)<\/parent>/)?.[1] ?? "";
  const parentGroup = xmlTag(parentBlock, "groupId");
  const parentVersion = xmlTag(parentBlock, "version");

  const ownXml = xml.replace(/<parent>[\s\S]*?<\/parent>/, "");
  const groupId = xmlTag(ownXml, "groupId") ?? parentGroup;
  const artifactId = xmlTag(ownXml, "artifactId");
  const version = xmlTag(ownXml, "version") ?? parentVersion;

  const modules = [...xml.matchAll(/<module>([^<]*)<\/module>/g)].map((m) => m[1].trim());

  const javaVersion =
    xmlTag(xml, "java.version") ??
    xmlTag(xml, "maven.compiler.release") ??
    xmlTag(xml, "maven.compiler.source");

  const dependencies: string[] = [];
  for (const m of xml.matchAll(/<dependency>([\s\S]*?)<\/dependency>/g)) {
    const g = xmlTag(m[1], "groupId");
    const a = xmlTag(m[1], "artifactId");
    const scope = xmlTag(m[1], "scope");
    if (g && a) dependencies.push(`${g}:${a}${scope ? ` (${scope})` : ""}`);
  }
  // De-duplicate while preserving order
  const deps = [...new Set(dependencies)].slice(0, 80);

  return {
    buildFile: "pom.xml",
    project: { groupId, artifactId, version },
    modules,
    javaVersion,
    dependencies: deps,
  };
}

function parseGradle(
  root: string,
  files: {
    build: { path: string; content: string }[];
    settings: { path: string; content: string }[];
  },
): Omit<BuildInfo, "buildSystem"> {
  const modules: string[] = [];
  let project: { groupId?: string; artifactId?: string; version?: string } | undefined;
  let javaVersion: string | undefined;
  const dependencies: string[] = [];

  for (const s of files.settings) {
    const content = s.content;
    const name = content.match(/rootProject\.name\s*=\s*['"`]([^'"`]+)['"`]/);
    if (name) project = { artifactId: name[1] };
    for (const m of content.matchAll(/include\s*\(([^)]*)\)/g)) {
      const names = [...m[1].matchAll(/['"`]([^'"`]+)['"`]/g)].map((x) => x[1].replace(/^:/, ""));
      modules.push(...names);
    }
  }

  for (const b of files.build) {
    const content = b.content;
    for (const m of content.matchAll(
      /\b(implementation|api|compileOnly|testImplementation|runtimeOnly|annotationProcessor)\s*\(?\s*['"`]([\w.\-]+):([\w.\-]+)(?::([\w.\-${}]+))?/g,
    )) {
      dependencies.push(`${m[2]}:${m[3]}${m[4] ? `:${m[4]}` : ""}`);
    }
    const ver =
      content.match(/sourceCompatibility\s*=\s*['"`](\d+(?:\.\d+)?)['"`]/) ??
      content.match(/JavaLanguageVersion\.of\((\d+)\)/) ??
      content.match(/JavaVersion\.VERSION_(\d+)/);
    if (ver) javaVersion = ver[1];
  }

  return {
    buildFile: files.build[0]?.path,
    project,
    modules,
    javaVersion,
    dependencies: [...new Set(dependencies)].slice(0, 80),
  };
}

async function parseBuild(root: string): Promise<BuildInfo> {
  const readIf = async (p: string): Promise<{ path: string; content: string } | undefined> => {
    try {
      const content = await readFile(join(root, p), "utf8");
      return { path: p, content };
    } catch {
      return undefined;
    }
  };

  const pom = await readIf("pom.xml");
  if (pom) {
    return { buildSystem: "maven", ...parseMavenPom(pom.content) };
  }

  const buildFiles = [
    (await readIf("build.gradle")) ?? (await readIf("build.gradle.kts")),
  ].filter(Boolean) as { path: string; content: string }[];
  const settingsFiles = [
    (await readIf("settings.gradle")) ?? (await readIf("settings.gradle.kts")),
  ].filter(Boolean) as { path: string; content: string }[];
  if (buildFiles.length > 0 || settingsFiles.length > 0) {
    return { buildSystem: "gradle", ...parseGradle(root, { build: buildFiles, settings: settingsFiles }) };
  }

  return { buildSystem: "none", modules: [], dependencies: [] };
}

// ---------------------------------------------------------------------------
// Spec discovery
// ---------------------------------------------------------------------------

const SPEC_CANDIDATES = [
  "spec.md",
  "SPEC.md",
  "Spec.md",
  "specs/spec.md",
  "specs/SPEC.md",
  "docs/spec.md",
  "docs/SPEC.md",
  "doc/spec.md",
  "doc/SPEC.md",
  "spec/spec.md",
];

async function fileExists(p: string): Promise<boolean> {
  try {
    const s = await stat(p);
    return s.isFile();
  } catch {
    return false;
  }
}

async function findSpec(root: string, specPath?: string): Promise<SpecInfo | undefined> {
  let abs: string | undefined;
  let rel: string | undefined;

  if (specPath) {
    abs = isAbsolute(specPath) ? specPath : join(root, specPath);
    if (await fileExists(abs)) rel = relative(root, abs).split(sep).join("/") || abs;
  } else {
    for (const cand of SPEC_CANDIDATES) {
      const p = join(root, cand);
      if (await fileExists(p)) {
        abs = p;
        rel = cand;
        break;
      }
    }
    // One level deeper: <dir>/spec.md
    if (!abs) {
      try {
        const entries = await readdir(root, { withFileTypes: true });
        for (const e of entries) {
          if (!e.isDirectory() || e.name.startsWith(".")) continue;
          for (const name of ["spec.md", "SPEC.md"]) {
            const p = join(root, e.name, name);
            if (await fileExists(p)) {
              abs = p;
              rel = `${e.name}/${name}`;
              break;
            }
          }
          if (abs) break;
        }
      } catch {
        // ignore
      }
    }
  }

  if (!abs || !rel) return undefined;

  const maxBytes = 60_000;
  let content = await readFile(abs, "utf8");
  const truncated = content.length > maxBytes;
  if (truncated) content = content.slice(0, maxBytes);
  return {
    path: rel,
    lines: content.split("\n").length,
    truncated,
    content,
  };
}

// ---------------------------------------------------------------------------
// Survey assembly
// ---------------------------------------------------------------------------

export async function scanProject(root: string, options: ScanOptions = {}): Promise<ProjectSurvey> {
  const maxFiles = options.maxFiles ?? MAX_FILES_DEFAULT;

  const build = await parseBuild(root);
  const spec = await findSpec(root, options.specPath);

  const allFiles: string[] = [];
  for await (const f of walk(root)) allFiles.push(f);
  allFiles.sort();

  const truncatedFiles = allFiles.length > maxFiles;
  const chosen = truncatedFiles ? allFiles.slice(0, maxFiles) : allFiles;

  const javaFiles: JavaFileSummary[] = [];
  for (const absPath of chosen) {
    try {
      const content = await readFile(absPath, "utf8");
      const relPath = relative(root, absPath);
      javaFiles.push(parseJavaFile(absPath, relPath, content));
    } catch {
      // unreadable file — skip
    }
  }

  const sourceRootsSet = new Set<string>();
  for (const f of javaFiles) {
    const m = f.path.match(/^(.*src\/(?:main|test|it|integration-test|generated-\w+)\/java)\//);
    if (m) sourceRootsSet.add(m[1]);
  }

  const missingTypes = resolveMissingTypes(javaFiles);

  const stats = {
    files: javaFiles.length,
    lines: javaFiles.reduce((n, f) => n + f.lines, 0),
    types: javaFiles.reduce((n, f) => n + f.types.length, 0),
    stubs: javaFiles.reduce((n, f) => n + f.stubs.length, 0),
    todos: javaFiles.reduce((n, f) => n + f.todos.length, 0),
    missingTypes: missingTypes.length,
  };

  return {
    root,
    buildSystem: build.buildSystem,
    buildFile: build.buildFile,
    project: build.project,
    modules: build.modules,
    javaVersion: build.javaVersion,
    dependencies: build.dependencies,
    sourceRoots: [...sourceRootsSet].sort(),
    javaFiles,
    totalJavaFiles: allFiles.length,
    truncatedFiles,
    missingTypes,
    spec,
    stats,
  };
}

// ---------------------------------------------------------------------------
// Report rendering
// ---------------------------------------------------------------------------

const MAX_LISTED_FILES = 400;
const MAX_STUBS_LISTED = 100;
const MAX_TODOS_LISTED = 100;

export interface RenderOptions {
  includeSpec?: boolean;
}

export function renderSurvey(survey: ProjectSurvey, opts: RenderOptions = {}): string {
  const includeSpec = opts.includeSpec !== false;
  const out: string[] = [];

  out.push("# Java project survey");
  out.push(`Root: ${survey.root}`);
  out.push("");

  // Build
  out.push("## Build");
  if (survey.buildSystem === "none") {
    out.push("- System: none detected (no pom.xml or build.gradle)");
  } else {
    out.push(`- System: ${survey.buildSystem} (${survey.buildFile ?? ""})`);
    if (survey.project) {
      const coords = [survey.project.groupId, survey.project.artifactId, survey.project.version]
        .filter(Boolean)
        .join(":");
      if (coords) out.push(`- Project: ${coords}`);
    }
    if (survey.javaVersion) out.push(`- Java: ${survey.javaVersion}`);
    if (survey.modules.length > 0) out.push(`- Modules: ${survey.modules.join(", ")}`);
    if (survey.dependencies.length > 0) {
      out.push(`- Dependencies (${survey.dependencies.length}): ${survey.dependencies.join(", ")}`);
    }
  }
  out.push("");

  // Layout
  if (survey.sourceRoots.length > 0) {
    out.push("## Layout");
    out.push("Source roots:");
    for (const r of survey.sourceRoots) out.push(`- ${r}`);

    const pkgCounts = new Map<string, number>();
    for (const f of survey.javaFiles) {
      const key = f.package || "(default package)";
      pkgCounts.set(key, (pkgCounts.get(key) ?? 0) + 1);
    }
    const sortedPkgs = [...pkgCounts.entries()].sort((a, b) => a[0].localeCompare(b[0]));
    out.push(`\nPackages (${sortedPkgs.length}):`);
    for (const [pkg, count] of sortedPkgs) {
      out.push(`- ${pkg} (${count} file${count === 1 ? "" : "s"})`);
    }
    out.push("");
  }

  // Files
  const listed = survey.javaFiles.slice(0, MAX_LISTED_FILES);
  out.push(`## Files (${survey.totalJavaFiles}${survey.truncatedFiles ? ", truncated" : ""})`);
  for (const f of listed) {
    const typeDesc = f.types.map((t) => `${t.kind} ${t.name}`).join(", ");
    const parts: string[] = [];
    if (f.isTest) parts.push("test");
    if (typeDesc) parts.push(typeDesc);
    parts.push(`${f.lines} lines`);
    if (f.methods > 0) parts.push(`${f.methods} methods`);
    if (f.stubs.length > 0) parts.push(`${f.stubs.length} stub marker(s)`);
    if (f.todos.length > 0) parts.push(`${f.todos.length} TODO/FIXME`);
    out.push(`- ${f.path}${parts.length ? " — " + parts.join(" | ") : ""}`);
  }
  if (survey.totalJavaFiles > MAX_LISTED_FILES) {
    out.push(`- … and ${survey.totalJavaFiles - MAX_LISTED_FILES} more file(s)`);
  }
  out.push("");

  // Incomplete markers
  const allStubs: { path: string; m: Marker }[] = [];
  const allTodos: { path: string; m: Marker }[] = [];
  for (const f of survey.javaFiles) {
    for (const m of f.stubs) allStubs.push({ path: f.path, m });
    for (const m of f.todos) allTodos.push({ path: f.path, m });
  }
  if (allStubs.length > 0 || allTodos.length > 0) {
    out.push("## Incomplete markers");
    if (allStubs.length > 0) {
      out.push(`Stubs (${allStubs.length}):`);
      for (const { path, m } of allStubs.slice(0, MAX_STUBS_LISTED)) {
        out.push(`- ${path}:${m.line} — ${m.text}`);
      }
      if (allStubs.length > MAX_STUBS_LISTED) out.push(`- … and ${allStubs.length - MAX_STUBS_LISTED} more`);
    }
    if (allTodos.length > 0) {
      out.push(`TODO/FIXME (${allTodos.length}):`);
      for (const { path, m } of allTodos.slice(0, MAX_TODOS_LISTED)) {
        out.push(`- ${path}:${m.line} — ${m.text}`);
      }
      if (allTodos.length > MAX_TODOS_LISTED) out.push(`- … and ${allTodos.length - MAX_TODOS_LISTED} more`);
    }
    out.push("");
  }

  // Missing types
  if (survey.missingTypes.length > 0) {
    out.push(`## Missing types (imported but not defined) — ${survey.missingTypes.length}`);
    for (const mt of survey.missingTypes.slice(0, 50)) {
      const by = mt.importedBy.slice(0, 5).join(", ");
      const more = mt.importedBy.length > 5 ? ` +${mt.importedBy.length - 5} more` : "";
      out.push(`- ${mt.name} ← ${by}${more}`);
    }
    if (survey.missingTypes.length > 50) out.push(`- … and ${survey.missingTypes.length - 50} more`);
    out.push("");
  } else {
    out.push("## Missing types");
    out.push("- none detected");
    out.push("");
  }

  // Spec
  if (includeSpec && survey.spec) {
    out.push(`## Spec: ${survey.spec.path} (${survey.spec.lines} lines${survey.spec.truncated ? ", truncated" : ""})`);
    out.push(survey.spec.content.trimEnd());
    if (survey.spec.truncated) out.push("… [spec content truncated]");
    out.push("");
  }

  // Stats
  out.push("## Stats");
  out.push(
    `Files: ${survey.stats.files} | Lines: ${survey.stats.lines} | Types: ${survey.stats.types} | ` +
      `Stub markers: ${survey.stats.stubs} | TODOs: ${survey.stats.todos} | Missing types: ${survey.stats.missingTypes}`,
  );

  return out.join("\n");
}

