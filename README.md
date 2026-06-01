# Security Audit Skill

This installs the `securityaudit` Codex skill.

## Easiest install

Paste this into Codex:

```text
Use $skill-installer to install https://github.com/andydixon/securityaudit-skill/tree/main/securityaudit
```

Restart Codex after it installs.

## Terminal install

Paste this into Terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/andydixon/securityaudit-skill/main/install.sh | bash -s -- andydixon/securityaudit-skill
```

Restart Codex after it installs.

## Use it

Audit only:

```text
$securityaudit
```

Audit and fix:

```text
$securityaudit --fix
```

Fix mode only changes files when the project is already in a git repository. It runs tests before committing successful fixes.
