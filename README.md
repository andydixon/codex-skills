# Security Audit Skill

This installs the `securityaudit` audit/fix workflow for Codex or Claude Code.

## Codex install

Paste this into Codex:

```text
Use $skill-installer to install https://github.com/andydixon/securityaudit-skill/tree/main/securityaudit
```

Restart Codex after it installs.

Or paste this into Terminal on macOS/Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/andydixon/securityaudit-skill/main/install.sh | bash
```

Or paste this into PowerShell on Windows:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-RestMethod https://raw.githubusercontent.com/andydixon/securityaudit-skill/main/install.ps1 | Invoke-Expression"
```

Restart Codex after it installs.

## Claude Code install

Paste this into Terminal on macOS/Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/andydixon/securityaudit-skill/main/install-claude.sh | bash
```

Or paste this into PowerShell on Windows:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-RestMethod https://raw.githubusercontent.com/andydixon/securityaudit-skill/main/install-claude.ps1 | Invoke-Expression"
```

Restart Claude Code if it was already open.

## Codex usage

Audit only:

```text
$securityaudit
```

Audit and fix:

```text
$securityaudit --fix
```

## Claude Code usage

Audit only:

```text
/securityaudit
```

Audit and fix:

```text
/securityaudit --fix
```

## What it does

Normal mode writes a project security audit report and does not change code.

Fix mode only changes files when the project is already in a git repository. It runs tests before committing successful fixes. If the project is not a git repository, it refuses to make changes.
