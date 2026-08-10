#!/usr/bin/env lua
--- wiki-init.lua - scaffold a project wiki with canonical structure
-- Creates:
--   wiki/README.md             Top-level index
--   wiki/concepts/             Library & tool documentation
--   wiki/decisions/            Design decision records
--   wiki/guidelines.md         Coding rules & conventions (single file)
--
-- Optional flags:
--   --with-guides              Also scaffold wiki/guides/{users,devs}/
--   --with-diagrams            Also scaffold wiki/diagrams/
--   --with-docs                Also scaffold wiki/docs/
--   --dry-run                  Print what would be created
--   --force                    Overwrite existing files
--
-- Usage:
--   ./wiki-init.lua
--   ./wiki-init.lua --with-guides --with-diagrams
--   ./wiki-init.lua --dry-run

-- ── Colors ───────────────────────────────────────────────────────────────────
local GREEN  = "\27[0;32m"
local YELLOW = "\27[1;33m"
local BLUE   = "\27[0;34m"
local RED    = "\27[0;31m"
local NC     = "\27[0m"

local function info(fmt, ...)  io.write(string.format(BLUE..fmt..NC.."\n", ...)) end
local function ok(fmt, ...)    io.write(string.format(GREEN..fmt..NC.."\n", ...)) end
local function warn(fmt, ...)  io.write(string.format(YELLOW..fmt..NC.."\n", ...)) end
local function err(fmt, ...)   io.write(string.format(RED..fmt..NC.."\n", ...)) end

-- ── Run helper ───────────────────────────────────────────────────────────────
local function run(cmd)
    local ok, how, code = os.execute(cmd)
    return ok
end

-- ── Flags ────────────────────────────────────────────────────────────────────
local opts = {
    with_guides  = false,
    with_diagrams = false,
    with_docs    = false,
    dry_run      = false,
    force        = false,
}

for _, a in ipairs(arg) do
    if a == "--with-guides"   then opts.with_guides   = true
    elseif a == "--with-diagrams" then opts.with_diagrams = true
    elseif a == "--with-docs"  then opts.with_docs     = true
    elseif a == "--dry-run"    then opts.dry_run       = true
    elseif a == "--force"      then opts.force         = true
    elseif a == "-h" or a == "--help" then
        print([[Usage: ./wiki-init.lua [OPTIONS]

Scaffold a project wiki with canonical structure:
  wiki/README.md             Top-level index
  wiki/concepts/             Library & tool documentation
  wiki/decisions/            Design decision records
  wiki/guidelines.md         Coding rules & conventions

Options:
  --with-guides        Also scaffold wiki/guides/{users,devs}/
  --with-diagrams      Also scaffold wiki/diagrams/
  --with-docs          Also scaffold wiki/docs/
  --dry-run            Print what would be created
  --force              Overwrite existing files]])
        os.exit(0)
    else
        io.stderr:write(string.format("%sUnknown option: %s%s\n", RED, a, NC))
        os.exit(1)
    end
end

-- ── Filesystem helpers ───────────────────────────────────────────────────────
local function exists(path)
    local f = io.open(path, "r")
    if f then f:close() return true end
    return false
end

local function ensure_dir(path)
    run("mkdir -p '" .. path:gsub("'", "'\\''") .. "'")
end

local function write_file(path, content)
    ensure_dir(path:match("(.+)/[^/]+$"))
    local f, e = io.open(path, "w")
    if not f then
        io.stderr:write(string.format("%sFailed to write %s: %s%s\n", RED, path, e, NC))
        return false
    end
    f:write(content)
    f:close()
    return true
end

local function create(path, content)
    -- content == nil means "create directory"
    if exists(path) and not opts.force then
        warn("  skip       %s (already exists)", path)
        return true
    end
    if opts.dry_run then
        info("  would create %s", path)
        return true
    end
    if content == nil then
        ensure_dir(path)
        ok("  created    %s/", path)
    else
        if write_file(path, content) then
            ok("  created    %s", path)
        else
            return false
        end
    end
    return true
end

-- ── Detect project root ──────────────────────────────────────────────────────
local function detect_project_root()
    local f = io.popen("pwd 2>/dev/null")
    local dir = f and f:read("*l") or os.getenv("PWD") or "."
    f:close()

    local markers = { "mise.toml", "package.json", "go.mod", "Cargo.toml",
                      "Makefile", "pyproject.toml", "Gemfile" }

    while dir and dir ~= "/" and dir ~= "" do
        for _, m in ipairs(markers) do
            if exists(dir .. "/" .. m) then
                return dir
            end
        end
        dir = dir:match("(.+)/[^/]+$")
    end
    return nil
end

local root = detect_project_root()
if not root then
    io.stderr:write(string.format(
        "%sError: could not detect project root.%s\nRun from a directory containing mise.toml, package.json, go.mod, etc.\n",
        RED, NC))
    os.exit(1)
end

local wiki = root .. "/wiki"

-- ── Templates ────────────────────────────────────────────────────────────────
local TOP_README = [[# Project Wiki

This wiki documents the project's architecture, decisions, and conventions.

## Structure

| Directory / File | Purpose |
|------------------|---------|
| `concepts/`      | Library and tool documentation (chi, htmx, sqlc, caddy, ...) |
| `decisions/`     | Design decision records (architecture, trade-offs, ADRs) |
| `guidelines.md`  | Coding rules, style, naming, module/API usage, error handling |

## Optional sections (add when relevant)

| Directory / File | Purpose |
|------------------|---------|
| `guides/`        | Audience-specific guides (users, developers, admins) |
| `diagrams/`      | Architecture diagrams (d2, mermaid) |
| `docs/`          | Project-specific documentation (design language, components) |

## How to use

- **Add a concept**: `wiki/concepts/<tool>.md` — what it is, why we chose it, how we use it
- **Record a decision**: `wiki/decisions/<topic>.md` — context, alternatives, consequences
- **Update guidelines**: edit `wiki/guidelines.md` to reflect coding standards
]]

local CONCEPTS_README = [[# Concepts

Library and tool documentation. Each file covers one tool or technology used in the project.

## Structure for each concept

```
# <Tool Name>

## What it is
<Brief description>

## Why we use it
<Rationale for choosing this tool>

## Key concepts
- <Concept 1>: <Explanation>
- <Concept 2>: <Explanation>

## How we use it here
<Project-specific usage patterns>

## Gotchas
<Lessons learned, pitfalls to avoid>
```

## Examples
- `chi.md` — Go HTTP router
- `htmx.md` — HTML-first interactivity
- `sqlc.md` — Type-safe SQL codegen
- `caddy.md` — Reverse proxy / dev server
- `mise.md` — Task runner and tool manager
]]

local DECISIONS_README = [[# Design Decisions

Records of significant design decisions and their rationale.

## Structure for each decision

```
# <Decision Title>

**Status**: Accepted | Deprecated | Superseded
**Date**: YYYY-MM-DD

## Context
<What problem are we solving? What constraints exist?>

## Decision
<What did we decide?>

## Alternatives considered
- **<Alt 1>**: <Description> — <Why rejected>
- **<Alt 2>**: <Description> — <Why rejected>

## Consequences

### Positive
- <Benefit 1>
- <Benefit 2>

### Negative
- <Trade-off 1>
- <Trade-off 2>
```

## Examples
- `architecture.md` — Overall system architecture
- `runtime-choice.md` — Language/runtime rationale
- `database-strategy.md` — Database approach
- `api-proxy-boundary.md` — Where to place API boundaries
]]

local GUIDELINES_MD = [[# Coding Guidelines

Coding standards and conventions for this project.

## Table of Contents

1. [Code Style](#code-style)
2. [Naming Conventions](#naming-conventions)
3. [Module & API Usage](#module--api-usage)
4. [Error Handling](#error-handling)
5. [Testing](#testing)
6. [Documentation](#documentation)

---

## Code Style

**Formatter**: <e.g. gofmt, prettier, rustfmt>
**Linter**: <e.g. golangci-lint, eslint, clippy>

<Define style rules here>

## Naming Conventions

<Define patterns for files, functions, variables, types, etc.>

### Files
- <Pattern>

### Functions & Methods
- <Pattern>

### Variables & Constants
- <Pattern>

### Types & Interfaces
- <Pattern>

## Module & API Usage

<Define how to use internal modules, APIs, and contracts>

### Internal Modules
- <Module 1>: <Purpose and usage pattern>

### Public APIs
- <API 1>: <Purpose and usage pattern>

### Contracts & Interfaces
- <Contract 1>: <Purpose and usage pattern>

## Error Handling

<Define error patterns, wrapping, logging rules>

### Patterns
- <Pattern 1>

### Logging
- <Rule 1>

## Testing

<Define testing conventions, naming, structure>

### Test Files
- <Pattern 1>

### Test Naming
- <Pattern 1>

## Documentation

<Define documentation requirements and style>

### When to document
- <Rule 1>

### Style
- <Rule 1>
]]

local GUIDES_README = [[# Guides

Audience-specific guides for using and understanding the project.

## Structure

- `users/` — End-user guides (how to use the product)
- `devs/`  — Developer guides (how to build, contribute, conventions)

## Adding a guide

1. Create the audience subdirectory (if missing)
2. Add a `README.md` as the entry point for that audience
3. Add individual guides with clear, task-oriented titles
]]

local DIAGRAMS_README = [[# Diagrams

Architecture and design diagrams.

## Supported formats

- **d2** — Declarative diagramming (recommended; render via `mise run diagrams`)
- **mermaid** — Markdown-native diagrams
- **draw.io** — Visual diagrams (export PNG/SVG alongside source)

## Conventions

- Store source files alongside rendered output
- Use clear, descriptive filenames
- Update the relevant guide or decision when a diagram changes materially
]]

local DOCS_README = [[# Project Documentation

Project-specific documentation that doesn't fit in `concepts/`, `decisions/`, or `guidelines.md`.

## When to put something here

- Too specific for `concepts/` (not a general tool)
- Too detailed for `guidelines.md` (needs its own file)
- Too project-focused for `decisions/` (not a decision record)

## Examples

- Design language specs
- Component documentation
- Integration guides
]]

-- ── Build the wiki ───────────────────────────────────────────────────────────
info("Initializing wiki in: %s", wiki)
print()

create(wiki .. "/README.md",          TOP_README)
create(wiki .. "/concepts",           nil)
create(wiki .. "/concepts/README.md", CONCEPTS_README)
create(wiki .. "/decisions",          nil)
create(wiki .. "/decisions/README.md", DECISIONS_README)
create(wiki .. "/guidelines.md",      GUIDELINES_MD)

if opts.with_guides then
    create(wiki .. "/guides",           nil)
    create(wiki .. "/guides/README.md", GUIDES_README)
    create(wiki .. "/guides/users",     nil)
    create(wiki .. "/guides/devs",      nil)
end

if opts.with_diagrams then
    create(wiki .. "/diagrams",           nil)
    create(wiki .. "/diagrams/README.md", DIAGRAMS_README)
end

if opts.with_docs then
    create(wiki .. "/docs",           nil)
    create(wiki .. "/docs/README.md", DOCS_README)
end

print()
ok("Wiki initialized!")
print()
print("Next steps:")
print("  1. Review wiki/README.md and update the project description")
print("  2. Add concepts for your key tools in wiki/concepts/")
print("  3. Record major decisions in wiki/decisions/")
print("  4. Customize wiki/guidelines.md for your project's conventions")
