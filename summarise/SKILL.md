---
name: summarise
description: Generate or update a repository SUMMARY.md that explains what a software project is, what it does, and how it evolved through Git history. Use when the user asks to summarise a codebase, create project history documentation, produce a v3-style management-readable technical narrative, analyse milestones from Git tags, or document significant commits and their product impact.
---

# Summarise

## Goal

Create a `SUMMARY.md` in the repository root unless the user names another file. The document should feel like a polished project-evolution report: technically accurate, management-readable, British English, friendly, crisp, and lightly ADHD without becoming gimmicky.

## Workflow

1. Inspect the project before writing:
   - read high-signal files such as `README*`, package manifests, docs, plugin/app metadata, build files, and the main source tree layout;
   - identify the project type, audience, core capabilities, and current state;
   - do not rely only on commit messages.

2. Gather Git evidence:
   - run `git status --short` and avoid mixing unrelated dirty work into the summary unless it is relevant;
   - list tags in chronological order and treat them as milestones;
   - compare milestone ranges with `git diff --shortstat <from>..<to>`;
   - inspect significant commits with `git show --stat --summary <commit>` and, where useful, `git show --name-only <commit>`;
   - consider merge commits, large diffs, new packages, major docs, tests, security work, UX changes, and architecture shifts as candidates for deeper explanation.

3. Use the helper script when useful:
   - run `~/.codex/skills/summarise/scripts/git-summary-evidence.sh [repo]`;
   - use its output as evidence, not as the final document;
   - inspect extra commits manually when the script highlights something important.

4. Write `SUMMARY.md` with this shape unless the project strongly suggests another:
   - title and short version;
   - executive summary;
   - line-count/change-size table;
   - timeline from Git commits, with tags as milestone headings;
   - what the project does now;
   - architecture and main components;
   - major feature areas;
   - significant commits and why they mattered;
   - security, testing, documentation, and operational maturity;
   - what it is good at;
   - what it is not yet;
   - recommended rollout/readout narrative;
   - final read.

5. Keep the writing honest:
   - distinguish implemented features from foundations, prototypes, and future work;
   - never inflate weak evidence into certainty;
   - call out uncertainty if commit messages are vague;
   - avoid corporate filler, but make it readable for non-specialists.

## Style

- Use British English.
- Prefer concrete product impact over raw technical trivia.
- Explain technical terms briefly when they matter.
- Keep a lively, human tone: direct, warm, occasionally wry.
- Avoid overdoing jokes; one sharp line beats six forced ones.
- Use crisp headings and tables where they help scanning.
- Use exact commit hashes, tag names, dates, and file counts where available.

## Significant Commit Heuristics

Give more detail to commits that:

- introduce or remove a package, service, plugin, app, or major subsystem;
- add a new user-facing workflow;
- change data flow, storage, auth, permissions, or trust boundaries;
- add detector/model/algorithm families;
- introduce a new UI paradigm or configuration system;
- add tests around risky behaviour;
- harden security, input bounds, sanitisation, or error handling;
- create or update major documentation;
- have unusually large line counts or many touched files.

Do not treat every commit equally. A small commit can matter if it changes the product shape; a large commit can be mechanical. Say which is which.

## Output Rules

- Create or update `SUMMARY.md` using normal file-editing tools.
- If a project already has a versioned summary such as `v3.md`, use it as a style reference but do not blindly copy it.
- If the user asks for a specific filename, use that filename instead.
- Include enough detail that a manager can understand the journey without reading the source, while an engineer can still trust the evidence.
- Before finishing, run `git diff --check` if a Git repository is present.
