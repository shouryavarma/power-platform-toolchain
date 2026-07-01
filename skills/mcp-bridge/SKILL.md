---
name: powermesh-mcp-bridge
version: 1.0.0
description: >
  Bridge layer for blocked MCP servers. Detects missing credentials,
  prompts the user, provisions session env vars, and retries.
user-invocable: true
allowed-tools: Bash, question
---

# MCP Credential Bridge

When an MCP server fails with "env var not set", use this bridge to provision on demand.

## Detection Pattern

```
Tool call → error message contains:
  - "POWERPLATFORM_DEV_URL is not configured" → powerplatform-mcp
  - "DATAVERSE_CONNECTION_URL is not configured" → dataverse-mcp
  - "FLOWSTUDIO_API_KEY is not set" → powerautomate-mcp
  - "No auth token" → microsoft-365-mcp
```

## Provisioning Matrix

| Server | Env Vars | Prompt Question | Where to Get |
|--------|----------|----------------|--------------|
| `powerplatform-mcp` | `POWERPLATFORM_DEV_URL`, `_CLIENT_ID`, `_CLIENT_SECRET`, `_TENANT_ID` | "What's your Dataverse org URL, SPN client ID, client secret, and tenant ID?" | Azure AD app registration |
| `dataverse-mcp` | `DATAVERSE_CONNECTION_URL`, `DATAVERSE_TENANT_ID` | "What's your Dataverse org URL and tenant ID?" | Power Platform Admin Center |
| `microsoft-365-mcp` | Device code flow | "I'll start device auth — open https://microsoft.com/devicelogin and enter the code" | M365 admin |
| `powerautomate-mcp` | `FLOWSTUDIO_API_KEY` | "What's your Flow Studio API key?" | https://mcp.flowstudio.app |

## Implementation

```powershell
$env:POWERPLATFORM_DEV_URL = "https://org.crm.dynamics.com"
$env:POWERPLATFORM_DEV_CLIENT_ID = "spn-guid"
$env:POWERPLATFORM_DEV_CLIENT_SECRET = "secret"
$env:POWERPLATFORM_DEV_TENANT_ID = "tenant-guid"
# Then retry the MCP tool call
```
