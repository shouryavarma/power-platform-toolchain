---
name: powermesh-create-code-app
version: 1.0.0
description: >
  Create, build, and deploy code-first Power Apps (Power Apps for developers)
  using PAC CLI and the Microsoft create-code-app skill. Covers scaffolding,
  React/TypeScript project setup, data source integration, and deployment.
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, question, Task
---

# Code-First Power Apps (create-code-app)

Create, build, and deploy code-first Power Apps using React/TypeScript, PAC CLI, and the Canvas App framework.

## Detection

| User says... | Route to |
|-------------|----------|
| "create code app" / "code-first" | This skill + `skill("create-code-app")` |
| "list code apps" / "my code apps" | `pac canvas list` |
| "download a code app" | `pac canvas download --name <name>` |
| "build code app" / "deploy code app" | This skill |
| "add data source to code app" | `skill("add-data-source")` |

## Prerequisites

- Node.js 18+ and npm/yarn
- PAC CLI installed (`dotnet tool install --global Microsoft.PowerApps.CLI.Tool`)
- Power Platform environment with code app capability enabled

## Workflow

### 1. List existing code apps

```powershell
pac canvas list
```

### 2. Download an existing app as a React project

```powershell
pac canvas download --name "MyApp" --output-dir ./my-app
```

### 3. Create a new code-first app from scratch

For full scaffolding guidance, load the Microsoft skill:

```
> skill("create-code-app")
```

The Microsoft skill covers:
- **Requirements** — Ask clarifying questions (app purpose, screens, data sources)
- **Plan** — List React components, routes, state management
- **Scaffold** — Create Vite + React + TypeScript project
- **Initialize** — `npm create vite`, install Power Apps SDK
- **Build/baseline deploy** — `npm run build`, push to Power Platform
- **Add data sources** — Connect to Dataverse, SharePoint, or custom connectors
- **Implement screens** — Write React components using Power Apps controls
- **Final deploy** — Build and push to Power Platform
- **Credential provisioning** — If PAC CLI is not authenticated, prompt for auth

### 4. PAC CLI code app commands

```powershell
# List all canvas apps (including code-first)
pac canvas list

# Download a canvas app as React project
pac canvas download --name "AppName" --output-dir ./app

# Upload a code-first app
pac pcf push --publisher-prefix dev
```

### 5. Credential provisioning

If PAC CLI returns auth errors:

1. Ask user for their Power Platform environment URL
2. `pac auth create --url https://org.crm.dynamics.com`
3. Follow browser login prompt
4. Retry the operation

If `create-code-app` skill references MCP servers that are blocked, follow the standard credential bridge workflow:
1. Detect the missing env var from the error
2. Ask the user for the value with source instructions
3. Set `$env:VAR = "value"` (session-only)
4. Retry

## File conventions

- Code-first apps: React/Vite projects with TypeScript
- Canvas app source: `.pa.yaml` (YAML control definitions)
- Solutions: `.zip` (export/import via PAC CLI)
- PCF controls: TypeScript/React component libraries

## Examples

```
User: "Create a code-first app for task tracking"

Agent: "What data source?" → "SharePoint list called Tasks"
Agent: "What features?" → "View tasks, add new, mark complete"

Agent: → Scaffolds Vite + React + TS project
       → Installs Power Apps SDK
       → Creates TaskList, AddTask, TaskDetail components
       → Connects to SharePoint Tasks list
       → Builds and deploys to Power Platform
       → Returns the app URL
```

```
User: "List my code apps"

Agent: → pac canvas list
       → Returns table of app names, IDs, and last modified dates
```

## Related

- `skill("powermesh-canvas-app")` — Classic canvas app CREATE/EDIT
- `skill("powermesh-pac-cli")` — PAC CLI command reference
- `skill("create-code-app")` — Microsoft's official code app skill
