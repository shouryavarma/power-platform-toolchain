# PowerMesh Architecture

## Overview

PowerMesh connects Claude Code to the Microsoft Power Platform ecosystem through three routing layers. When you say something in plain English, the system determines which layer and which tool to invoke.

## Routing Flow

```
User prompt (plain English)
    │
    ▼
┌────────────────────────────────────────────────────┐
│ STEP 1: Intent Router (SKILL.md)                    │
│ Matches prompt against 30+ routing patterns        │
│   e.g. "list solutions" → pac-cli layer            │
│   e.g. "create canvas app" → sub-skills layer      │
│   e.g. "show my flows" → MCP servers layer         │
└──────────────────────┬─────────────────────────────┘
                       │
                       ▼
          ┌────────────┴────────────┐
          │                         │
          ▼                         ▼
   ┌──────────────┐         ┌──────────────┐
   │ Sub-skills   │         │ MCP Servers  │
   │ (4 internal) │         │ (7 external) │
   │ (7 microsoft)│         └──────┬───────┘
   └──────┬───────┘                │
          │                        ▼
          │                 ┌──────────────┐
          │                 │ Credential   │
          │                 │ Bridge       │
          │                 │ (if blocked) │
          │                 └──────┬───────┘
          │                        │
          └────────────┬───────────┘
                       ▼
               ┌──────────────┐
               │ Tool Call    │
               │ (Bash, MCP)  │
               └──────────────┘
```

## Layer 1: PAC CLI (Zero-Setup Workhorse)

PAC CLI is the most versatile tool in the stack. It requires no environment variables, no authentication configuration, and works immediately after installation.

**Command groups:** auth, solution, env, data, plugin, pcf, connector, canvas, admin, help, model, package, pipeline, policy, telemetry, virtual, etc.

**When to use:** Always prefer PAC CLI when it can do the job. It's faster, more reliable, and doesn't require credential prompts.

**When to escalate:** Complex operations that PAC CLI doesn't support (e.g., canvas app coauthoring, deep Dataverse metadata queries, Power Automate flow management).

## Layer 2: Sub-skills

Sub-skills are specialized SKILL.md files that provide deep guidance for complex domains. They are loaded via `skill("powermesh-<name>")` and contain domain-specific instructions, workflows, and example dialogs.

### Internal sub-skills

| Skill | Domain | Key MCP integration |
|-------|--------|-------------------|
| `powermesh-canvas-app` | Canvas App CREATE/EDIT | Canvas Authoring MCP (`compile_canvas`, `sync_canvas`) |
| `powermesh-dataverse` | Dataverse CRUD | `dataverse-mcp` (if configured) or PAC CLI fallback |
| `powermesh-pac-cli` | PAC CLI reference | None (self-contained) |
| `powermesh-mcp-bridge` | Credential provisioning | None (orchestration only) |

### Microsoft plugin skills (copied)

These are official Microsoft-provided skills that PowerMesh delegates to for specific tasks. They are auto-installed to `~/.agents/skills/` by the installer for direct loadability.

## Layer 3: MCP Servers

MCP servers provide specialized Power Platform integrations. They run as subprocesses of Claude Code and communicate via stdio or HTTP.

### Ready servers (no setup)

- **`pac-cli` MCP** — Wraps the PAC CLI as an MCP server. Provides tool access to `pac` commands. Started via `pac mcp`.
- **`canvas-authoring` MCP** — Provides `compile_canvas` and `sync_canvas` tools for canvas app coauthoring. Requires a Power Apps Studio browser tab to remain open.
- **`powerbi-modeling-mcp`** — Power BI model operations. Free, no auth required for basic operations.

### Blocked servers (need credentials)

These servers require environment variables or auth tokens. When a blocked server is needed, the credential bridge activates:

1. MCP tool call returns an error (e.g., "POWERPLATFORM_DEV_URL is not configured")
2. `powermesh-mcp-bridge` skill identifies the missing variable
3. User is prompted for the value with instructions on where to obtain it
4. Value is set as `$env:VAR_NAME = "value"` (session-only, not persisted)
5. Tool call is retried

See `docs/CREDENTIAL_PROVISIONING.md` for full details.

## Credential Bridge

```
MCP tool error: "VAR_NAME not set"
    │
    ▼
┌──────────────────────┐
│ Parse error message  │──→ Identify env var name
└──────────────────────┘
    │
    ▼
┌──────────────────────┐
│ question() to user   │──→ "I need [var]. Get it at [url]."
└──────────────────────┘
    │
    ▼
┌──────────────────────┐
│ $env:VAR = "value"   │──→ Session only, never written to disk
└──────────────────────┘
    │
    ▼
┌──────────────────────┐
│ Retry MCP tool call  │──→ Success
└──────────────────────┘
```

## Test Architecture

Tests are defined in `tests/test-cases.yaml` and executed by `scripts/test-runner.ps1`.

**Test types:**
1. **PAC CLI documentation tests** — Verify every command in SKILL.md exists in `pac help` output
2. **Credential flow tests** — Verify the credential bridge documentation for each blocked server
3. **Sub-skill routing tests** (non-critical) — Verify intent routing strings map to correct skills
4. **EvalView tests** (in `tests/evalview/`) — Automated E2E scenarios using the EvalView framework

**Test output:**
```
Results: 8 passed, 0 failed, 7 skipped
```
- **PASS** — Test verified successfully
- **FAIL** — Test found a discrepancy (blocking)
- **SKIPPED** — Test needs a runtime environment (non-critical)
