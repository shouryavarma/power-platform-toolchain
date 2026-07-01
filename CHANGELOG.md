# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] — 2026-07-01

### Added

- **Intent router** (`SKILL.md`) — Routes 30+ plain-English commands to the right MCP server or sub-skill
- **PAC CLI automation** (`skills/pac-cli/SKILL.md`) — Cheat sheet for 25+ command groups (auth, solutions, data, environments, plugins, connectors)
- **Canvas App builder** (`skills/canvas-app/SKILL.md`) — CREATE/EDIT workflows with Canvas Authoring MCP
- **Dataverse data layer** (`skills/dataverse/SKILL.md`) — CRUD via PAC CLI or dataverse-mcp with credential fallback
- **MCP credential bridge** (`skills/mcp-bridge/SKILL.md`) — On-demand credential provisioning for blocked MCP servers
- **One-command installer** (`install.ps1`) — Copies plugin + sub-skills, runs tests
- **GitHub push helper** (`push-to-github.ps1`) — Creates remote, pushes, prints one-liner install command
- **Test runner** (`scripts/test-runner.ps1`) — 15 test cases (8 critical PASS, 7 non-critical SKIPPED)
- **Test definitions** (`tests/test-cases.yaml`) — 25 documented test scenarios
- **EvalView E2E tests** (`tests/evalview/canvas-app-create.yaml`) — End-to-end canvas app creation scenario
- **Shared instructions** (`shared/shared-instructions.md`) — Cross-cutting concerns for auth, error handling, rate limits, file conventions
- **Example walkthrough** (`examples/canvas-app-inventory.yaml`) — Full session trace for creating an inventory canvas app
- **Microsoft skill copies** — 7 plugin skills auto-installed to `~/.agents/skills/`
- **On-demand credential provisioning** — Users are prompted for credentials only when a blocked server is needed; values are session-only, never persisted to disk

### Supported MCP servers

- `pac-cli` MCP — ✅ Ready (zero setup)
- `canvas-authoring` MCP — ✅ Ready (needs Studio tab open)
- `powerbi-modeling-mcp` — ✅ Ready (zero setup)
- `powerplatform-mcp` — ⚠️ Blocked (prompts for 4 env vars)
- `dataverse-mcp` — ⚠️ Blocked (prompts for 2 env vars)
- `microsoft-365-mcp` — ⚠️ Blocked (device code flow)
- `powerautomate-mcp` — ⚠️ Blocked (prompts for Flow Studio API key)
