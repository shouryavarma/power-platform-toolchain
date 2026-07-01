<#
.SYNOPSIS
  Push PowerMesh to GitHub and print the remote one-liner install command.

.DESCRIPTION
  Prompts for your GitHub repo URL, creates the remote, pushes main branch,
  and prints the install command you can run from ANY machine.

.EXAMPLE
  .\push-to-github.ps1
  # Enter: https://github.com/yourname/PowerMesh
#>

$ErrorActionPreference = "Stop"
$repo = Split-Path $PSScriptRoot -Parent

Write-Host "+------------------------------------------+" -ForegroundColor Cyan
Write-Host "|        Push PowerMesh to GitHub           |" -ForegroundColor Cyan
Write-Host "+------------------------------------------+" -ForegroundColor Cyan

$url = Read-Host "`nGitHub repo URL (e.g. https://github.com/yourname/PowerMesh)"

if (-not $url) {
    Write-Host "ERROR: No URL provided." -ForegroundColor Red
    exit 1
}

# Extract user/repo for the raw URL
$parts = $url -replace "https://github.com/", "" -replace ".git$", "" -split "/"
if ($parts.Count -lt 2) {
    Write-Host "ERROR: Invalid GitHub URL." -ForegroundColor Red
    exit 1
}
$user = $parts[0]
$repoName = $parts[1]

Write-Host "`n[PowerMesh] Setting up remote..." -ForegroundColor Cyan
$existing = git remote get-url origin 2>$null
if ($existing) {
    Write-Host "  Remote 'origin' already set to: $existing" -ForegroundColor Yellow
    $overwrite = Read-Host "  Overwrite? (y/N)"
    if ($overwrite -ne "y") { Write-Host "  Aborted."; exit 0 }
    git remote remove origin
}

git remote add origin $url
Write-Host "  Remote 'origin' -> $url" -ForegroundColor Green

Write-Host "`n[PowerMesh] Renaming branch to main..." -ForegroundColor Cyan
git branch -M main

Write-Host "`n[PowerMesh] Pushing to GitHub..." -ForegroundColor Cyan
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n+------------------------------------------+" -ForegroundColor Green
    Write-Host "|  Push successful!                         |" -ForegroundColor Green
    Write-Host "+------------------------------------------+" -ForegroundColor Green
    Write-Host ""
    Write-Host "  One-command install (from ANY machine):" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "    powershell -c ""iex (irm https://raw.githubusercontent.com/$user/$repoName/main/install.ps1)""" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "`nERROR: Push failed." -ForegroundColor Red
    Write-Host "  Make sure the repo exists on GitHub (create it first, then re-run)." -ForegroundColor Yellow
    exit 1
}
