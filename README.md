# Andy's Skill Pack

This repository contains four practical Codex/Claude Code skills:

| Skill | Use it when you need to... |
| --- | --- |
| `securityaudit` | run an evidence-based application security audit, write audit reports, or apply confirmed fixes with `--fix`. |
| `aitm` | create or update an `AITM.md` architecture input for automated threat modelling. |
| `debullshit` | turn confusing corporate email into clear, British-English, ADHD-friendly plain English. |
| `summarise` | create or update a repository `SUMMARY.md` based on code and Git history. |

## Codex install

Paste these into Codex if you prefer installing through `$skill-installer`:

```text
Use $skill-installer to install https://github.com/andydixon/securityaudit-skill/tree/main/securityaudit
Use $skill-installer to install https://github.com/andydixon/securityaudit-skill/tree/main/aitm
Use $skill-installer to install https://github.com/andydixon/securityaudit-skill/tree/main/debullshit
Use $skill-installer to install https://github.com/andydixon/securityaudit-skill/tree/main/summarise
```

Restart Codex after it installs.

Or paste this into Terminal on macOS/Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/andydixon/securityaudit-skill/main/install.sh | bash
```

That script installs all four skills into `~/.codex/skills`.

Or paste this into PowerShell on Windows:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-RestMethod https://raw.githubusercontent.com/andydixon/securityaudit-skill/main/install.ps1 | Invoke-Expression"
```

Restart Codex after it installs.

To install only selected skills, set `SECURITYAUDIT_SKILLS` to a space- or comma-separated list before running the script, for example `SECURITYAUDIT_SKILLS="securityaudit aitm"`.

## Claude Code install

Paste this into Terminal on macOS/Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/andydixon/securityaudit-skill/main/install-claude.sh | bash
```

That script installs all four skills into `~/.claude/skills`.

Or paste this into PowerShell on Windows:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-RestMethod https://raw.githubusercontent.com/andydixon/securityaudit-skill/main/install-claude.ps1 | Invoke-Expression"
```

Restart Claude Code if it was already open.

To install only selected Claude Code skills, set `SECURITYAUDIT_SKILLS` to a space- or comma-separated list before running the script.

## Skill usage

### `securityaudit`

Use this for a project-wide secure code review, dependency/configuration review, DoS review, frontend robustness review, and practical remediation planning.

Audit only:

```text
$securityaudit
```

Audit and fix:

```text
$securityaudit --fix
```

Claude Code:

```text
/securityaudit
/securityaudit --fix
```

Normal mode writes reports under `audits/` and avoids changing application code, apart from safe git bootstrap/report creation when needed. Fix mode requires an explicit `--fix`, works from evidence-backed findings, runs relevant checks, and commits successful fixes.

### `aitm`

Use this when you need a repository architecture document suitable as input to automated threat modelling. It recursively analyses the current project and creates or updates `AITM.md`.

```text
$aitm
/aitm
```

Good prompts:

```text
$aitm
$aitm create a threat-modelling architecture input for this repo
```

It focuses on components, data flows, actors, trust boundaries, auth/authz, sensitive data, entry points, external integrations, deployment evidence, and uncertainty. It should not modify app code.

### `debullshit`

Use this for pasted emails that are too corporate, vague, passive-aggressive, over-formal, or generally allergic to plain English.

```text
$debullshit
/debullshit
```

Example:

```text
$debullshit
<paste the email here>
```

It returns:

- the short version;
- what they actually want;
- what you need to do;
- important details;
- what is vague or missing;
- a corporate-to-human rewrite.

It preserves names, dates, figures, links, responsibilities, deadlines, nuance, and security warnings. If an email smells like phishing, payment fraud, credential harvesting, or process-bypass nonsense, it calls that out near the top.

### `summarise`

Use this to generate or update a project `SUMMARY.md` that explains what the software is, what it does now, and how it evolved through Git history.

```text
$summarise
/summarise
```

Good prompts:

```text
$summarise
$summarise write the summary to docs/project-summary.md
```

It inspects high-signal project files, uses Git status/tags/commits as evidence, highlights significant milestones, and keeps the result management-readable without inflating weak evidence into fake certainty.

## Installer behaviour

The install scripts are intentionally boring and defensive:

- install `securityaudit`, `aitm`, `debullshit`, and `summarise` by default;
- validate each `SKILL.md` name before installing it;
- back up any existing installed skill directory before replacing it;
- install from the local checkout when run inside this repository;
- otherwise download the requested branch from GitHub;
- accept the existing `SECURITYAUDIT_REPO` and `SECURITYAUDIT_REF` overrides;
- accept `SECURITYAUDIT_SKILLS` for installing a subset.
