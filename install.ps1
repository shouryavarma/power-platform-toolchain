<#
.SYNOPSIS
  PowerMesh Installer - one-command setup for the Unified Power Platform toolchain.

.DESCRIPTION
  Copies plugin files to ~/.claude/plugins/powermesh/, registers sub-skills
  in ~/.agents/skills/, and verifies the installation by running the test suite.

  Works both locally (from the repo directory) and remotely (from a GitHub raw URL).

.EXAMPLE
  # Local (run from repo root):
  .\install.ps1

  # Remote:
  powershell -c "iex (irm https://raw.githubusercontent.com/user/PowerMesh/main/install.ps1)"
#>

$ErrorActionPreference = "Stop"

# -- Detect install mode -------------------------------------------------------
$isLocal = Test-Path "$PSScriptRoot\plugin.yaml"
if ($isLocal) {
    $src = $PSScriptRoot
    Write-Host "[PowerMesh] Installing from local repo: $src" -ForegroundColor Cyan
} else {
    Write-Host "[PowerMesh] Remote install mode not yet configured." -ForegroundColor Yellow
    Write-Host "[PowerMesh] Run this script from the repo root for local install." -ForegroundColor Yellow
    exit 1
}

# -- Directories ---------------------------------------------------------------
$pluginDir  = "$HOME\.claude\plugins\powermesh"
$skillsDir  = "$HOME\.agents\skills"
$subSkills = @{
    "powermesh"            = "SKILL.md"
    "powermesh-canvas-app" = "skills\canvas-app\SKILL.md"
    "powermesh-dataverse"  = "skills\dataverse\SKILL.md"
    "powermesh-pac-cli"    = "skills\pac-cli\SKILL.md"
    "powermesh-mcp-bridge" = "skills\mcp-bridge\SKILL.md"
    "powermesh-create-code-app" = "skills\create-code-app\SKILL.md"
}

Write-Host "`n[PowerMesh] Creating directories..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $pluginDir -Force | Out-Null
foreach ($name in $subSkills.Keys) {
    New-Item -ItemType Directory -Path "$skillsDir\$name" -Force | Out-Null
}

# -- Copy plugin files ---------------------------------------------------------
Write-Host "[PowerMesh] Copying plugin files..." -ForegroundColor Cyan
$exclude = @('.git', '.gitignore')
Get-ChildItem -Path $src -Directory | Where-Object { $_.Name -notin $exclude } | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination "$pluginDir\$($_.Name)" -Recurse -Force
}
Get-ChildItem -Path $src -File | Where-Object { $_.Name -notin $exclude } | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination "$pluginDir\$($_.Name)" -Force
}

# -- Copy sub-skills -----------------------------------------------------------
Write-Host "[PowerMesh] Installing sub-skills..." -ForegroundColor Cyan
foreach ($name in $subSkills.Keys) {
    $srcSkill = "$src\$($subSkills[$name])"
    $dstSkill = "$skillsDir\$name\SKILL.md"
    if (Test-Path $srcSkill) {
        Copy-Item -Path $srcSkill -Destination $dstSkill -Force
        Write-Host "  + $name" -ForegroundColor Green
    }
}

# -- Run tests -----------------------------------------------------------------
$testRunner = "$pluginDir\scripts\test-runner.ps1"
if (Test-Path $testRunner) {
    Write-Host "`n[PowerMesh] Running verification tests..." -ForegroundColor Cyan
    & $testRunner; $exitCode = $LASTEXITCODE
    if ($exitCode -eq 0) {
        Write-Host "`n[PowerMesh] All critical tests PASSED.`n" -ForegroundColor Green
    } else {
        Write-Host "`n[PowerMesh] WARNING: Some tests failed. Check output above.`n" -ForegroundColor Yellow
    }
} else {
    Write-Host "[PowerMesh] Test runner not found at $testRunner - skipping." -ForegroundColor Yellow
}

# -- Summary -------------------------------------------------------------------
Write-Host "+------------------------------------------+" -ForegroundColor Cyan
Write-Host "|        PowerMesh Installation Complete    |" -ForegroundColor Cyan
Write-Host "+------------------------------------------+" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Plugin:  ~/.claude/plugins/powermesh/"
Write-Host "  Skills:  ~/.agents/skills/powermesh*/"
Write-Host ""
Write-Host "  MCP servers are already in .claude.json." -ForegroundColor DarkYellow
Write-Host "  Add more manually if needed." -ForegroundColor DarkYellow
Write-Host ""
Write-Host "  Say what you want in plain English." -ForegroundColor Green
Write-Host '  Load the skill: skill("powermesh")' -ForegroundColor Yellow
Write-Host "+------------------------------------------+" -ForegroundColor Cyan
