---
name: powermesh-pac-cli
version: 1.0.0
description: Automate Power Platform via PAC CLI — zero env vars needed, most versatile tool.
user-invocable: true
allowed-tools: Bash, Read, question
---

# PAC CLI Automation

PAC CLI is the zero-setup workhorse. 25+ command groups.

## Command Cheat Sheet

| Category | Command | Example |
|----------|---------|---------|
| Auth | `pac auth create --url <url>` | Login to environment |
| Auth | `pac auth list` | List active auth profiles |
| Solutions | `pac solution list` | List solutions |
| Solutions | `pac solution export --name <name>` | Export as managed/unmanaged |
| Solutions | `pac solution import --file <path>` | Import solution |
| Solutions | `pac solution clone --name <name>` | Clone for source control |
| Environment | `pac env list` | List environments |
| Environment | `pac env who` | Who am I? |
| Data | `pac data list --table <name>` | List records |
| Data | `pac data create --table <name> --json <data>` | Create record |
| Data | `pac data update --table <name> --id <id> --json <data>` | Update record |
| Data | `pac data delete --table <name> --id <id>` | Delete record |
| Plugin | `pac plugin list` | List plugin assemblies |
| Plugin | `pac plugin register` | Register plugin |
| PCF | `pac pcf list` | List PCF controls |
| Connector | `pac connector list` | List custom connectors |
| Canvas | `pac canvas list` | List canvas apps |
| Canvas | `pac canvas download --name <name>` | Download .pa.yaml |
| Admin | `pac admin list --environments` | List all environments (admin) |
| Solution | `pac solution add-license --solution <name>` | Add license |

## Common Workflows

```
# Auth + Export solution
pac auth create --url https://contoso.crm.dynamics.com
pac solution export --name MySolution --managed

# Clone + version
pac solution clone --name MySolution --output src/solutions/
pac solution version --strategy increment --patch

# List + inspect
pac solution list
pac env who
```
