# Andy's Skill Pack

Practical skills for Codex and Claude Code, centred on deep security review and clear project documentation.

| Skill | Use it when you need to... |
| --- | --- |
| `securityaudit` | run a deep, evidence-based security audit, generate audit reports, or apply confirmed fixes with `--fix`. |
| `aitm` | create an `AITM.md` architecture input for automated threat modelling. |
| `debullshit` | translate confusing corporate email into clear, British-English, ADHD-friendly plain English. |
| `summarise` | create or update a repository `SUMMARY.md` from code and Git history. |

## Install for Codex

Paste these into Codex if you prefer installing through `$skill-installer`:

```text
Use $skill-installer to install https://github.com/andydixon/securityaudit-skill/tree/main/securityaudit
Use $skill-installer to install https://github.com/andydixon/securityaudit-skill/tree/main/aitm
Use $skill-installer to install https://github.com/andydixon/securityaudit-skill/tree/main/debullshit
Use $skill-installer to install https://github.com/andydixon/securityaudit-skill/tree/main/summarise
```

Restart Codex after installation.

Or install all skills from Terminal on macOS/Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/andydixon/securityaudit-skill/main/install.sh | bash
```

Or from PowerShell on Windows:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-RestMethod https://raw.githubusercontent.com/andydixon/securityaudit-skill/main/install.ps1 | Invoke-Expression"
```

The Codex installer writes skills to `~/.codex/skills`.

## Install for Claude Code

Install all skills from Terminal on macOS/Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/andydixon/securityaudit-skill/main/install-claude.sh | bash
```

Or from PowerShell on Windows:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-RestMethod https://raw.githubusercontent.com/andydixon/securityaudit-skill/main/install-claude.ps1 | Invoke-Expression"
```

The Claude Code installer writes skills to `~/.claude/skills`. Restart Claude Code if it was already open.

## Installing Selected Skills

By default, the installer installs all four skills:

```text
securityaudit aitm debullshit summarise
```

To install only some of them, set `SECURITYAUDIT_SKILLS` to a space- or comma-separated list before running the script:

```bash
export SECURITYAUDIT_SKILLS="securityaudit aitm"
curl -fsSL https://raw.githubusercontent.com/andydixon/securityaudit-skill/main/install.sh | bash
```

The installers also support `SECURITYAUDIT_REPO` and `SECURITYAUDIT_REF` if you need to install from another repository or branch. When run from a local checkout, they install from that checkout instead of downloading from GitHub.

## `securityaudit`

`securityaudit` is the main skill in this pack. It performs a broad, adversarial application-security review and writes two timestamped reports under `audits/`:

- `YYYYMMDD-HHII-securityAudit.md`
- `YYYYMMDD-HHII-functionalityNextSteps.md`

Use normal audit mode when you want findings and recommendations without application-code changes:

```text
$securityaudit
```

Claude Code:

```text
/securityaudit
```

Normal mode may create `audits/` and, if the project has no Git repository, may create a conservative initial Git snapshot before auditing. It otherwise avoids modifying application code, configuration, tests, dependencies, or deployment files.

### What the audit covers

The updated audit is deliberately deep and sceptical. It reviews:

- attack surface, trust boundaries, roles, entry points, data stores, jobs, webhooks, integrations, and deployment exposure;
- authentication, authorisation, session handling, tenant isolation, business logic, and abuse paths;
- input validation, output encoding, injection risks, SSRF, path traversal, deserialisation, and file processing;
- denial-of-service and resource exhaustion across requests, uploads, queues, retries, database access, caches, parsers, regexes, and background work;
- cryptography, key management, randomness, password storage, TLS, signatures, JWTs, webhook verification, and post-quantum readiness for long-lived confidentiality;
- secrets across their full lifecycle: at rest, in transit, in logs, in config, in process memory, in crash dumps, in heap dumps, in command lines, and in child processes;
- memory safety in native, FFI, Rust `unsafe`, parser, and allocation-heavy code;
- dependency, supply-chain, CI/CD, container, infrastructure, IAM, RBAC, and deployment configuration risk;
- frontend HTML/JavaScript robustness, including event handlers, async failures, console errors, browser-side storage, DOM XSS, CORS, CSRF, clickjacking, and third-party scripts;
- code-quality problems that increase security, reliability, maintainability, or user-facing breakage risk;
- missing security, abuse-case, boundary, frontend interaction, regression, smoke, and load tests.

Each finding is expected to include severity, confidence, affected files/components, evidence, exploitability, impact, a safe trigger or reproduction where appropriate, a recommended fix, suggested tests, and relevant references such as CWE or OWASP mappings.

### Fix mode

Use fix mode only when you want the agent to repair confirmed findings:

```text
$securityaudit --fix
```

Claude Code:

```text
/securityaudit --fix
```

Fix mode is intentionally stricter than normal mode. It:

- checks Git state before editing and avoids overwriting unrelated user changes;
- bootstraps a Git repository first if one does not already exist;
- fixes only real, evidence-backed security, DoS, robustness, frontend, or code-quality issues;
- keeps changes as small as practical while preserving existing behaviour;
- adds or updates relevant regression tests where practical;
- runs targeted checks before broader suites when risk warrants it;
- commits successful logical fix groups with security- or robustness-focused commit messages;
- stops for user consent before compatibility-breaking cryptographic migrations.

At the end of a fix run, it should summarise commits created, tests run, findings fixed, findings left open, generated audit files, and residual risk.

## `aitm`

Use `aitm` when you need a repository architecture document suitable as input to automated threat modelling:

```text
$aitm
```

Claude Code:

```text
/aitm
```

It recursively analyses the current project and creates or updates `AITM.md`. It focuses on components, data flows, actors, trust boundaries, authentication, authorisation, sensitive data, entry points, external integrations, deployment evidence, and uncertainty. It treats the repository as read-only except for `AITM.md`.

## `debullshit`

Use `debullshit` for pasted emails that are too corporate, vague, passive-aggressive, over-formal, jargon-heavy, or just unnecessarily hard to parse:

```text
$debullshit
<paste the email here>
```

Claude Code:

```text
/debullshit
<paste the email here>
```

It returns the short version, what they actually want, what you need to do, important details, what is vague or missing, and a corporate-to-human rewrite. It preserves names, dates, figures, links, responsibilities, deadlines, nuance, and security warnings. Suspicious payment, credential, link, attachment, MFA, or process-bypass requests are called out near the top.

## `summarise`

Use `summarise` to generate or update a project summary based on the repository and its Git history:

```text
$summarise
```

Claude Code:

```text
/summarise
```

It creates `SUMMARY.md` by default, or another path if you ask for one. It inspects high-signal project files, Git status, tags, commits, and notable diffs, then writes a management-readable technical narrative without inflating weak evidence into fake certainty.

## Installer Behaviour

The install scripts are intentionally defensive:

- install `securityaudit`, `aitm`, `debullshit`, and `summarise` by default;
- validate each requested `SKILL.md` name before installing it;
- back up any existing installed skill directory before replacing it;
- install from the local checkout when run inside this repository;
- otherwise download the requested branch from GitHub;
- support `SECURITYAUDIT_REPO`, `SECURITYAUDIT_REF`, and `SECURITYAUDIT_SKILLS` overrides.
