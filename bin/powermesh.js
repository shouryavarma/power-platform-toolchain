#!/usr/bin/env node
const { execSync } = require("child_process");
const { existsSync } = require("fs");
const { resolve, join } = require("path");

const PKG_DIR = resolve(__dirname, "..");
const HOME = process.env.USERPROFILE || process.env.HOME;
const PLUGIN_DIR = join(HOME, ".claude", "plugins", "powermesh");
const SKILL_DIR = join(HOME, ".agents", "skills");

const cmd = process.argv[2] || "help";

function ps(script) {
  try {
    execSync(
      `powershell -NoProfile -ExecutionPolicy Bypass -File "${script}"`,
      { stdio: "inherit", timeout: 120_000 }
    );
    return true;
  } catch (e) {
    return false;
  }
}

function log(tag, msg, color) {
  const colors = { green: 32, yellow: 33, red: 31, cyan: 36, dim: 2 };
  const c = colors[color] || 0;
  console.log(`\x1b[${c}m[${tag}]\x1b[0m ${msg}`);
}

function init() {
  if (process.platform !== "win32") {
    log("ERR", "PowerMesh requires Windows (Power Platform toolchain depends on PAC CLI)", "red");
    process.exit(1);
  }

  const installer = join(PKG_DIR, "install.ps1");
  if (!existsSync(installer)) {
    log("ERR", "install.ps1 not found. Is the package complete?", "red");
    process.exit(1);
  }

  log("POWERMESH", "Running installer...", "cyan");
  if (!ps(installer)) {
    log("ERR", "Installer failed", "red");
    process.exit(1);
  }
  log("OK", "Installation complete", "green");
}

function testCmd() {
  const runner = join(PLUGIN_DIR, "scripts", "test-runner.ps1");
  if (!existsSync(runner)) {
    log("ERR", "Plugin not installed. Run `npx powermesh init` first.", "red");
    process.exit(1);
  }
  const r = execSync(
    `powershell -NoProfile -ExecutionPolicy Bypass -File "${runner}"`,
    { stdio: "inherit", timeout: 120_000 }
  );
  process.exit(0);
}

function status() {
  const installed = existsSync(join(PLUGIN_DIR, "plugin.yaml"));
  const skills = existsSync(join(SKILL_DIR, "powermesh", "SKILL.md"));

  console.log(`\n  PowerMesh v${require(join(PKG_DIR, "package.json")).version}`);
  console.log(`  Plugins:  ${installed ? "\x1b[32minstalled\x1b[0m" : "\x1b[31mnot found\x1b[0m"} @ ${PLUGIN_DIR}`);
  console.log(`  Skills:   ${skills ? "\x1b[32mregistered\x1b[0m" : "\x1b[31mnot found\x1b[0m"} @ ${SKILL_DIR}/powermesh/`);
  console.log(`  Platform: ${process.platform}`);
  console.log(`  Node:     ${process.version}\n`);
}

function help() {
  console.log(`
  PowerMesh — Natural language interface for Microsoft Power Platform

  Usage:

    npx powermesh init     Install/update the PowerMesh plugin
    npx powermesh test     Run verification tests
    npx powermesh status   Check installation status
    npx powermesh help     Show this message

  Requirements:
    Windows, Node >= 18, PAC CLI (pac), Claude Code
    See https://github.com/shouryavarma/power-platform-toolchain
`);
}

const cmds = { init, test: testCmd, status, help };
if (cmds[cmd]) cmds[cmd]();
else { help(); process.exit(1); }
