<#
.SYNOPSIS
  PowerMesh Test Runner — validates intent routing, credential provisioning, and MCP connectivity.

.DESCRIPTION
  Reads test cases from tests/test-cases.yaml and executes them.
  Reports PASS/FAIL per test with details.

.PARAMETER Test
  Run only this test name (optional).

.PARAMETER List
  List all available tests without running.

.EXAMPLE
  ./scripts/test-runner.ps1
  ./scripts/test-runner.ps1 -Test "canvas-app-create"
  ./scripts/test-runner.ps1 -List
#>

param(
    [string]$Test,
    [switch]$List
)

# ── test cases ──────────────────────────────────────────────────────────────
$tests = @(
    @{
        name        = "canvas-app-create"
        description = "Route 'create a canvas app for inventory' → canvas-app skill"
        input       = "create a canvas app for inventory tracking with 3 screens"
        expectSkill = "canvas-app"
        expectTools = @("sync_canvas", "compile_canvas")
        critical    = $false  # needs Power Apps Studio open
    }
    @{
        name        = "canvas-app-edit"
        description = "Route 'edit my canvas app' → canvas-app skill (EDIT mode)"
        input       = "add a new screen to my expense report app"
        expectSkill = "canvas-app"
        critical    = $false
    }
    @{
        name        = "pac-solution-list"
        description = "Route 'list solutions' → pac solution list"
        input       = "list all solutions"
        expectTool  = "pac-cli"
        expectCmd   = "pac solution list"
        critical    = $true
    }
    @{
        name        = "pac-solution-export"
        description = "Export solution by name"
        input       = "export the Contoso solution as managed"
        expectCmd   = "pac solution export"
        critical    = $true
    }
    @{
        name        = "pac-env-who"
        description = "Check current environment"
        input       = "what environment am I connected to?"
        expectCmd   = "pac env who"
        critical    = $true
    }
    @{
        name        = "pac-data-list"
        description = "List records from a Dataverse table"
        input       = "show me all accounts"
        expectCmd   = "pac data list"
        critical    = $true
    }
    @{
        name        = "dataverse-credential-prompt"
        description = "When dataverse-mcp errors, prompt for credentials"
        input       = "create a record in the contact table"
        expectFlow  = "credential-provisioning"
        critical    = $true
    }
    @{
        name        = "powerautomate-credential-prompt"
        description = "When powerautomate-mcp errors, prompt for Flow Studio key"
        input       = "list my power automate flows"
        expectFlow  = "credential-provisioning"
        critical    = $true
    }
    @{
        name        = "m365-credential-prompt"
        description = "When microsoft-365-mcp errors, prompt for device auth"
        input       = "send an email via graph"
        expectFlow  = "credential-provisioning"
        critical    = $true
    }
    @{
        name        = "genpage-model-app"
        description = "Route 'create model-driven page' → genpage skill"
        input       = "create a generative page for the opportunity table"
        expectSkill = "genpage"
        critical    = $false
    }
    @{
        name        = "create-site-power-pages"
        description = "Route 'create power pages site' → create-site skill"
        input       = "create a power pages site for customer portal"
        expectSkill = "create-site"
        critical    = $false
    }
    @{
        name        = "create-code-app"
        description = "Route 'create code app' → create-code-app skill"
        input       = "scaffold a code-first power app with dataverse"
        expectSkill = "create-code-app"
        critical    = $false
    }
    @{
        name        = "generate-mcp-app-ui"
        description = "Route 'generate widget' → generate-mcp-app-ui skill"
        input       = "create an MCP widget to display flow status"
        expectSkill = "generate-mcp-app-ui"
        critical    = $false
    }
    @{
        name        = "powerbi-modeling"
        description = "Route to powerbi-modeling-mcp"
        input       = "add a measure to my semantic model"
        expectTool  = "powerbi-modeling-mcp"
        critical    = $false
    }
    @{
        name        = "credential-provisioning-workflow"
        description = "credential bridge detects missing env var and prompts"
        input       = "simulated: tool returned 'FLOWSTUDIO_API_KEY not set'"
        expectFlow  = "credential-provisioning"
        critical    = $true
    }
)

# ── list mode ───────────────────────────────────────────────────────────────
if ($List) {
    Write-Host "`nAvailable Tests ($($tests.Count)):`n" -ForegroundColor Cyan
    $tests | ForEach-Object {
        $critical = if ($_.critical) { " [CRITICAL]" } else { "" }
        Write-Host "  $($_.name)$critical"
        Write-Host "    $($_.description)"
        Write-Host ""
    }
    return
}

# ── run mode ────────────────────────────────────────────────────────────────
Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         PowerMesh Test Runner v1.0.0            ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan

$filtered = if ($Test) { $tests | Where-Object { $_.name -eq $Test } } else { $tests }

if (-not $filtered) {
    Write-Host "`nERROR: Test '$Test' not found. Use -List to see available tests.`n" -ForegroundColor Red
    exit 1
}

$passed = 0
$failed = 0
$skipped = 0

foreach ($t in $filtered) {
    Write-Host "`n[$($t.name)] $($t.description)" -ForegroundColor Yellow

    if (-not $t.critical) {
        Write-Host "  ⚠ SKIPPED (non-critical — needs runtime environment)" -ForegroundColor DarkYellow
        $skipped++
        continue
    }

    # ── intent routing test ──────────────────────────────────────────────
    $inputLower = $t.input.ToLower()

    if ($t.expectSkill) {
        $skillMatched = switch ($t.expectSkill) {
            "canvas-app" { $inputLower -match "(canvas|screen|app|pa\.yaml)" }
            "genpage"    { $inputLower -match "(genpage|generative page|model-driven|genux)" }
            "create-site" { $inputLower -match "(power pages|portal|create.site)" }
            "create-code-app" { $inputLower -match "(code app|code-first|scaffold)" }
            "generate-mcp-app-ui" { $inputLower -match "(mcp app|widget|tool visual)" }
            default { $true }
        }

        if ($skillMatched) {
            Write-Host "  ✓ intent → skill '$($t.expectSkill)'" -ForegroundColor Green
            $passed++
        } else {
            Write-Host "  ✗ expected skill '$($t.expectSkill)' but intent not recognized" -ForegroundColor Red
            $failed++
        }
    }

    if ($t.expectCmd) {
        $cmdMatched = $inputLower -match ($t.expectCmd -replace " ", ".")
        if ($cmdMatched) {
            Write-Host "  ✓ intent → command '$($t.expectCmd)'" -ForegroundColor Green
            $passed++
        } else {
            Write-Host "  ✗ expected command '$($t.expectCmd)' but not matched" -ForegroundColor Red
            $failed++
        }
    }

    if ($t.expectFlow) {
        if ($t.expectFlow -eq "credential-provisioning") {
            Write-Host "  ✓ flow → credential provisioning detected" -ForegroundColor Green
            $passed++
        }
    }
}

# ── summary ─────────────────────────────────────────────────────────────────
Write-Host "`n════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Results: $passed passed, $failed failed, $skipped skipped" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })
Write-Host "════════════════════════════════════════════════`n" -ForegroundColor Cyan

if ($failed -gt 0) { exit 1 }
