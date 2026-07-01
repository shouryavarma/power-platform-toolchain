---
name: powermesh-canvas-app
version: 1.0.0
description: Create or edit Power Apps Canvas Apps via natural language, using Canvas Authoring MCP.
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, question, mcp__canvas-authoring__sync_canvas, mcp__canvas-authoring__compile_canvas
---

# Canvas App Builder

Create or edit a Power Apps canvas app from a plain-English description.

## Detection

- **CREATE mode**: user asks to "create", "build", "make", "generate" a new app
- **EDIT mode**: user asks to "edit", "modify", "change", "add screen to" an existing app

## Workflow (CREATE)

1. **Requirements** — ask clarifying questions until the app is well-defined
2. **Plan** — list screens, data sources, controls, and navigation flow
3. **Configure MCP** — run `configure-canvas-mcp` skill to set up the coauthoring session
4. **Build screens** — write `.pa.yaml` for each screen in parallel using Task agents
5. **Compile & validate** — `compile_canvas` to check for errors
6. **Sync to Studio** — `sync_canvas` to push YAML to the open Studio tab

## Workflow (EDIT)

1. **Clone current state** — `sync_canvas` to pull current YAML from Studio
2. **Understand** — read the `.pa.yaml` to understand current screens/controls
3. **Apply change** — edit YAML, compile, sync

## Example

```
User: "Create a canvas app for expense reporting"
Agent: → Asks about screens, data source (SharePoint list?), approval flow
Agent: → Writes 3 .pa.yaml files (Submit Expense, Pending Approvals, History)
Agent: → compile_canvas → fix errors → sync_canvas
```
