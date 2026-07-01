# PowerMesh Shared Instructions

## Cross-cutting concerns for every Power Platform operation.

### 1. Identity & Auth
- `pac-cli` handles auth with `pac auth create` — no env vars needed.
- Other MCP servers may need SPN or device-code auth. Prompt on demand.

### 2. Error Handling
- If an MCP tool errors with "missing env var", follow the credential provisioning workflow in SKILL.md.
- If PAC CLI returns a non-zero exit, show stderr verbatim.
- If canvas-authoring returns a compile error, show the error list from `compile_canvas`.

### 3. Rate Limiting
- Power Platform API: ~600 requests/min per user. PAC CLI handles batching.
- Canvas Authoring: one coauthoring session at a time.

### 4. File Conventions
- Canvas apps: `.pa.yaml` (YAML control definitions)
- Power Pages: `.pagemeta.yaml` per page
- Solutions: `.zip` (export/import via PAC CLI)
- Code apps: React/Vite projects

### 5. Session Locality
- Env vars set via `$env:VAR = "value"` are session-only.
- Canvas Authoring session needs the Power Apps Studio tab to stay open.
