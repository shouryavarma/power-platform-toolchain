# PowerMesh — Unified Power Platform Toolchain

Natural language interface for all Microsoft Power Platform tools. Say what you want in plain English; PowerMesh routes to the right MCP server, plugin skill, or agent automatically.

## Architecture

```
User prompt (plain English)
    │
    ▼
┌────────────────────────────────────────────────┐
│           PowerMesh Intent Router              │
│  (powermesh SKILL.md routing table)            │
└──────┬──────┬──────┬──────┬──────┬─────────────┘
       │      │      │      │      │
       ▼      ▼      ▼      ▼      ▼
   ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌──────────┐
   │PAC  │ │Canv.│ │Data-│ │M365 │ │Power     │
   │CLI  │ │Auth │ │verse│ │Graph│ │Automate  │
   │MCP  │ │MCP  │ │MCP  │ │MCP  │ │MCP       │
   └─────┘ └─────┘ └─────┘ └─────┘ └──────────┘
   (ready) (ready) (blocked)(blocked)(blocked)
```

- **Ready** servers work immediately (no env vars needed)
- **Blocked** servers prompt for credentials on first use, then work for the session

## Quick Start

### 1. Install the plugin

Copy the `powermesh` directory to your `~/.claude/plugins/powermesh/` or reference it from your project's `.claude.json`.

### 2. Load the skill

```
> skill("powermesh")
```

This makes all sub-skills and routing tables available.

### 3. Speak naturally

| You say | PowerMesh does |
|---------|---------------|
| "Create a canvas app for inventory tracking" | Loads canvas-app skill → plans screens → writes `.pa.yaml` → compiles → syncs |
| "List all solutions" | `pac solution list` via PAC CLI MCP |
| "Export the Contoso solution" | `pac solution export --name Contoso` |
| "Add a Dataverse table for Customers" | Falls back to `pac data create` or prompts for dataverse-mcp credentials |
| "Show my Power Automate flows" | Prompts for Flow Studio API key → lists flows |
| "What's my current environment?" | `pac env who` |

## Sub-skills

| Skill | Purpose | Load via |
|-------|---------|----------|
| `powermesh-canvas-app` | Canvas App create/edit | `skill("powermesh-canvas-app")` |
| `powermesh-dataverse` | Dataverse CRUD + metadata | `skill("powermesh-dataverse")` |
| `powermesh-pac-cli` | PAC CLI cheat sheet | `skill("powermesh-pac-cli")` |
| `powermesh-mcp-bridge` | Credential provisioning | `skill("powermesh-mcp-bridge")` |
| `canvas-app` (Microsoft) | Official canvas app skill | `skill("canvas-app")` |
| `genpage` (Microsoft) | Model-driven app pages | `skill("genpage")` |
| `create-site` (Microsoft) | Power Pages sites | `skill("create-site")` |
| `create-code-app` (Microsoft) | Code-first Power Apps | `skill("create-code-app")` |

## Testing

```powershell
# Run all tests
./scripts/test-runner.ps1

# Run specific test
./scripts/test-runner.ps1 -Test "canvas-app-create"
```

Test definitions are in `tests/test-cases.yaml`. EvalView tests are in `tests/evalview/`.

## Examples

See the `examples/` directory for complete walkthroughs:

- `canvas-app-inventory.yaml` — Create an inventory tracking canvas app
- `solution-alm.yaml` — Full ALM lifecycle with PAC CLI
- `dataverse-crud.yaml` — CRUD operations on Dataverse data
- `power-pages-deploy.yaml` — Deploy a Power Pages site

## Credential Provisioning

Servers that need env vars will prompt you on first use:

1. You ask for something (e.g., "list my flows")
2. PowerMesh detects the required MCP server is blocked
3. PowerMesh asks you for the credential value
4. You provide it (session-only, never persisted to disk)
5. PowerMesh retries and succeeds

This means **zero setup required** to start using PowerMesh.

## File Reference

```
powermesh/
├── plugin.yaml                       # Plugin manifest
├── README.md                         # This file
├── SKILL.md                          # Main intent router
├── .gitignore
├── shared/
│   └── shared-instructions.md        # Cross-cutting concerns
├── skills/
│   ├── canvas-app/SKILL.md           # Canvas app builder
│   ├── dataverse/SKILL.md            # Dataverse CRUD
│   ├── pac-cli/SKILL.md              # PAC CLI automation
│   └── mcp-bridge/SKILL.md           # Credential provisioning
├── scripts/
│   └── test-runner.ps1               # Test runner
├── tests/
│   ├── test-cases.yaml               # All test cases
│   └── evalview/                     # EvalView E2E tests
└── examples/
    └── canvas-app-inventory.yaml     # Example walkthrough
```
