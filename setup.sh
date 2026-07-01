#!/usr/bin/env bash
set -e
echo "============================================"
echo " PowerMesh - Power Platform Toolchain"
echo " One-command setup for Claude Code"
echo "============================================"
echo ""
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
powershell -NoProfile -ExecutionPolicy Bypass -File "$DIR/install.ps1"
echo ""
echo "DONE! Open Claude Code and try: list solutions"
