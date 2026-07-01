---
name: powermesh
version: 1.0.0
description: >
  Unified Power Platform toolchain. Routes plain-English requests to the right
  MCP server, sub-skill, or CLI command automatically. Covers Canvas Apps,
  Model-Driven Apps, Power Pages, Dataverse, PAC CLI, Power BI, Power Automate,
  and Microsoft 365 Graph.
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, question, Task
---

# PowerMesh — Unified Power Platform Toolchain

## Intent Routing

| User says... | Route to |
|-------------|----------|
| "create canvas app" / "make an app" | `skill("canvas-app")` → CREATE workflow |
| "edit canvas app" / "change screen" | `skill("canvas-app")` → EDIT workflow |
| "add data source to canvas app" | `skill("add-data-source")` |
| "configure canvas MCP" | `skill("configure-canvas-mcp")` |
| "create model-driven page" / "genpage" | `skill("genpage")` |
| "create power pages site" / "portal" | `skill("create-site")` |
| "deploy power pages" | `skill("deploy-site")` |
| "scan power pages" / "audit permissions" | `skill("scan-site")` / `skill("audit-permissions")` |
| "create code app" / "code-first" | `skill("create-code-app")` |
| "generate MCP widget" / "tool visual" | `skill("generate-mcp-app-ui")` |
| "list solutions" / "export solution" | `pac-cli` → `pac solution list/export/import` |
| "manage environments" | `pac-cli` → `pac env *` |
| "login to environment" | `pac-cli` → `pac auth create` |
| "list/query data" | `pac data *` or `dataverse-mcp` (if configured) |
| "show Power Automate flows" | `powerautomate-mcp` (prompts for key) |
| "send email" / "calendar" | `microsoft-365-mcp` (device auth flow) |
| "Power BI model" / "DAX" | `powerbi-modeling-mcp` |
| "register plugin" / "PCF control" | `pac plugin *` / `pac pcf *` |
| "manage connector" | `pac connector *` |
| "ALM pipeline" / "deployment" | `skill("plan-alm")` / `skill("setup-pipeline")` |

## MCP Server Status

| Server | Status | Env Vars | Prompt? |
|--------|--------|----------|---------|
| `pac-cli` | ✅ Ready | None | Never |
| `canvas-authoring` | ✅ Ready | None | Never |
| `powerbi-modeling-mcp` | ✅ Ready | None | Never |
| `powerplatform-mcp` | ⚠️ Blocked | 4 vars | On demand |
| `dataverse-mcp` | ⚠️ Blocked | 2 vars | On demand |
| `microsoft-365-mcp` | ⚠️ Blocked | Device auth | On demand |
| `powerautomate-mcp` | ⚠️ Blocked | 1 var | On demand |

## Credential Provisioning Workflow

When a blocked server is needed, DO NOT fail silently:

1. **Detect** — parse the error message to identify the missing env var
2. **Ask** — use `question()` to ask for the value, include *where to get it*
3. **Set** — `$env:VAR_NAME = "value"` (session-only)
4. **Retry** — call the tool again

See `skill("powermesh-mcp-bridge")` for the full provisioning matrix.

## Sub-skills

Run `skill("powermesh-<name>")` for deeper guidance:
- `powermesh-canvas-app` — Canvas App CREATE/EDIT workflows
- `powermesh-dataverse` — Dataverse CRUD via PAC CLI and MCP
- `powermesh-pac-cli` — PAC CLI command reference
- `powermesh-mcp-bridge` — On-demand credential provisioning

## Testing

```powershell
./scripts/test-runner.ps1          # Run all tests
./scripts/test-runner.ps1 -List    # List tests
./scripts/test-runner.ps1 -Test "pac-solution-list"
```

Tests are defined in `tests/test-cases.yaml` (25 cases) and `tests/evalview/`.

## Examples

See `examples/` for full walkthroughs:
- `canvas-app-inventory.yaml` — complete session trace
- More coming in future releases
