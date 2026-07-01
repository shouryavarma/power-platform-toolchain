# On-Demand Credential Provisioning

PowerMesh uses **on-demand credential provisioning** — credentials are prompted for only when a blocked MCP server is needed, set session-only, and never persisted to disk.

## Why on-demand?

Traditional approaches require you to:
- Pre-configure `.env` files with all credentials upfront
- Remember where every API key and token lives
- Update configurations when credentials change

PowerMesh's approach:
- **Zero setup** — Start using the toolchain immediately
- **Just-in-time** — Prompted only when you need a particular server
- **Session-only** — No secrets written to disk, no cleanup needed
- **Guided** — Each prompt tells you exactly where to get the credential

## Provisioning Matrix

### Power Automate (easiest to unblock)

| Detail | Value |
|--------|-------|
| **Server** | `powerautomate-mcp` |
| **Required** | `FLOWSTUDIO_API_KEY` |
| **Prompt** | "What's your Flow Studio API key?" |
| **Where to get** | https://mcp.flowstudio.app — free API key |
| **Usage** | `$env:FLOWSTUDIO_API_KEY = "pp-flow-abc123..."` |

### Microsoft 365

| Detail | Value |
|--------|-------|
| **Server** | `microsoft-365-mcp` |
| **Required** | Device code flow |
| **Prompt** | "Open https://microsoft.com/devicelogin and enter the code: ABC123" |
| **Where to get** | Device code displayed in the MCP server output |
| **Usage** | Follow device code prompt in browser |

### Dataverse

| Detail | Value |
|--------|-------|
| **Server** | `dataverse-mcp` |
| **Required** | `DATAVERSE_CONNECTION_URL`, `DATAVERSE_TENANT_ID` |
| **Prompt** | "What's your Dataverse org URL and tenant ID?" |
| **Where to get** | Power Platform Admin Center → Environments |
| **Usage** | `$env:DATAVERSE_CONNECTION_URL = "https://org.crm.dynamics.com"` |

### Power Platform

| Detail | Value |
|--------|-------|
| **Server** | `powerplatform-mcp` |
| **Required** | `POWERPLATFORM_DEV_URL`, `POWERPLATFORM_DEV_CLIENT_ID`, `POWERPLATFORM_DEV_CLIENT_SECRET`, `POWERPLATFORM_DEV_TENANT_ID` |
| **Prompt** | "What's your Dataverse org URL, SPN client ID, client secret, and tenant ID?" |
| **Where to get** | Azure AD app registration with Power Platform permissions |
| **Usage** | `$env:POWERPLATFORM_DEV_URL = "https://org.crm.dynamics.com"` |

## Implementation in Skills

### Main intent router (`SKILL.md`)

The main SKILL.md includes a `Credential Provisioning Workflow` section that instructs the agent:
1. **Detect** — Parse the error message from the MCP tool call
2. **Ask** — Use `question()` to ask for the value with source instructions
3. **Set** — `$env:VAR_NAME = "value"` (session-only)
4. **Retry** — Call the tool again

### MCP bridge sub-skill (`skills/mcp-bridge/SKILL.md`)

The bridge skill provides the full provisioning matrix, detection patterns (error message → env var mapping), and example PowerShell commands.

### Per-domain sub-skills

Each domain skill (e.g., `skills/dataverse/SKILL.md`) includes a credential provisioning section specific to that domain, with fallback instructions (e.g., "if user can't provide credentials, fall back to `pac data *` commands").

## Security

- **No storage** — Credentials are set as PowerShell session environment variables (`$env:VAR`) and are never written to disk
- **No logging** — Credential values are not written to log files
- **No transmission** — Credentials stay on your machine, used only to configure local MCP server processes
- **Session isolation** — Each Claude Code session gets its own credential scope; credentials don't leak between sessions
- **User control** — You choose what to share and when; every credential prompt includes the source URL

## Troubleshooting

### "I don't have a Flow Studio key"
Go to https://mcp.flowstudio.app and sign up. The API key is free.

### "I don't have an Azure AD app registration"
Create one in the Azure Portal:
1. Go to Azure AD → App registrations → New registration
2. Grant appropriate Power Platform API permissions
3. Note the client ID, client secret, and tenant ID
4. Provide these when prompted

### "My credentials aren't working"
1. Verify the values are correct
2. Make sure no extra spaces were included
3. Restart the session (credentials are session-only)
4. Try again with corrected values

### Can I persist credentials for convenience?
PowerMesh intentionally does not persist credentials. If you want persistent configuration, set them as environment variables in your shell profile (`$PROFILE`) or in `.claude.json`'s MCP server config under `env` for each server.
