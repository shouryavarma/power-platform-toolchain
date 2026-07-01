---
name: powermesh-dataverse
version: 1.0.0
description: CRUD operations on Dataverse data, tables, and metadata via PAC CLI and MCP servers.
user-invocable: true
allowed-tools: Read, Write, Bash, question
---

# Dataverse Data Layer

Interact with Dataverse entities, records, and metadata.

## Routing

| User says... | Tool |
|-------------|------|
| "list records from table X" | `pac data list` (if table) or `dataverse-mcp search_data` (if configured) |
| "create a record" | `pac data create` or `dataverse-mcp create_record` |
| "update record" | `pac data update` or `dataverse-mcp upsert_skill` |
| "delete record" | `pac data delete` |
| "create a table" | `dataverse-mcp create_table` (if configured) |
| "describe table schema" | `dataverse-mcp describe` (if configured) |
| "fetch XML query" | `dataverse-mcp read_query` (if configured) |

## Credential Provisioning

If `dataverse-mcp` errors about missing `DATAVERSE_CONNECTION_URL`:
1. Ask user for their Dataverse org URL (e.g. `https://contoso.crm.dynamics.com`)
2. Set `$env:DATAVERSE_CONNECTION_URL = "url"` and `$env:DATAVERSE_TENANT_ID = "tenant-id"`
3. Retry

If user can't provide credentials, fall back to `pac data *` commands (no env vars needed).
