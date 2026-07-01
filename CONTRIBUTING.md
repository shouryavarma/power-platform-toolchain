# Contributing to PowerMesh

Thanks for your interest in contributing! All contributions are welcome — bug reports, feature requests, documentation improvements, and code changes.

## How to contribute

### 1. Report bugs or request features

Open an [issue](https://github.com/shouryavarma/power-platform-toolchain/issues) with:
- A clear title and description
- Steps to reproduce (for bugs)
- Your environment (PowerShell version, PAC CLI version, OS)

### 2. Submit changes

1. Fork the repo
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Make your changes
4. Run the tests (`.\scripts\test-runner.ps1`)
5. Commit with a clear message (`git commit -m "Add feature: ..."`)
6. Push to your fork (`git push origin feature/my-feature`)
7. Open a pull request

### 3. Add a new sub-skill

1. Create `skills/<name>/SKILL.md` with the standard frontmatter:
   ```yaml
   ---
   name: powermesh-<name>
   version: 1.0.0
   description: Description of the skill
   user-invocable: true
   allowed-tools: Read, Write, Bash, question
   ---
   ```
2. Add a routing entry in `SKILL.md`'s intent routing table
3. Add an install entry in `install.ps1`'s `$subSkills` map
4. Add a test case in `tests/test-cases.yaml`
5. Add a test in `scripts/test-runner.ps1`
6. Update this file's sub-skills table if needed
7. Run `.\scripts\test-runner.ps1` to verify

### 4. Code style

- PowerShell: PascalCase cmdlets, descriptive variable names, comment-based help
- YAML: 2-space indentation, no tabs
- Markdown: No trailing whitespace, one blank line between sections
- Keep it simple — if a solution can be 3 lines instead of 10, use 3 lines

## Pull request guidelines

- Keep PRs focused on a single concern
- Update tests and documentation with your changes
- Verify tests pass before requesting review
- Reference any related issues

## Questions?

Open a [discussion](https://github.com/shouryavarma/power-platform-toolchain/discussions) or issue.
