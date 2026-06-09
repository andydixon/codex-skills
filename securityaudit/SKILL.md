---
name: securityaudit
description: >-
  Run a deep, evidence-based security audit of a software project, create security and functionality-next-step reports under audits/, or fix findings with --fix. Use for securityaudit/securityaudit --fix, secure code review, blackhat-style adversarial review, threat modelling, dependency/configuration review, denial-of-service analysis, frontend HTML/JavaScript robustness review, project-wide appsec assessment, code-quality hardening, and repair of confirmed security, DoS, frontend, robustness, or maintainability findings. Normal mode audits source, tests, build/deploy files, dependencies, CI/CD, auth/authz, input handling, browser behavior, data protection, infrastructure, operations, DoS and abuse vectors, and fragile code without changing app files except git bootstrap if needed and reports. Fix mode safely improves confirmed issues in git, preserving functionality, testing, and committing successful fixes.
---

# Security Audit

## Core Rules

- Act as a senior application security engineer, secure code reviewer, threat modeller, abuse-case tester, and pragmatic maintainer.
- Use an adversarial "blackhat hacker" lens safely: think like a hostile attacker trying to exploit, DoS, bypass, persist, pivot, exfiltrate, or abuse business logic, but keep all testing local, authorised, non-destructive, and evidence-based.
- Review the entire project deeply and sceptically. Tie every finding to concrete evidence from files, functions, routes, dependencies, configuration values, behaviours, or architectural decisions.
- Create an `audits/` folder at the project root if it does not exist. Write all audit artifacts there.
- Save the security report as `audits/YYYYMMDD-HHII-securityAudit.md`, using the current local system date and time. Use four-digit 24-hour time, e.g. `audits/20260131-1427-securityAudit.md`.
- Also save a functionality and next-steps report as `audits/YYYYMMDD-HHII-functionalityNextSteps.md` with the same timestamp as the security report.
- Do not invent files, routes, code, dependencies, or findings. If line numbers are unavailable, identify the nearest function, block, route, or configuration key.
- If a class of issue was checked and not found, mention that briefly.
- Keep snippets short and focused.

## Project Preparation and Git Safety

Before auditing or fixing:

- Identify the project root and check whether it is inside a git repository with `git rev-parse --show-toplevel`.
- If a git repository exists, inspect the working tree before editing or creating commits. Do not overwrite, revert, or discard user changes.
- If no git repository exists:
  - Initialize a new git repository in the project root.
  - Create or update `.gitignore` with conservative, codebase-appropriate entries before staging anything.
  - Preserve any existing `.gitignore` content. Add missing entries rather than replacing useful project-specific rules.
  - Include common local-only files, secrets, caches, logs, editor/OS files, generated build outputs, dependency directories regenerated from lockfiles, test coverage, temporary files, local databases, and tool caches.
  - Do not ignore source files, migrations, lockfiles, documentation, infrastructure-as-code, or other reproducible project assets unless the codebase clearly treats them as generated.
  - Check for obvious high-confidence secrets or private key material that would be staged. If present, explain the issue and stop before creating the initial commit.
  - Stage the initial project state and create an initial commit, e.g. `chore: initial project snapshot`.
  - If repository initialization, `.gitignore` creation, staging, or committing fails, explain the issue and stop before making audit fixes or broader changes.

Normal audit mode may create the git bootstrap commit if no repository exists and may create files under `audits/`. It must not otherwise modify application code, configuration, tests, dependency files, or deployment files.

## Execution Modes

### Normal Audit Mode

Use this mode unless the user explicitly includes `--fix`.

- Perform the full security, DoS, abuse-case, code-quality, frontend robustness, dependency, configuration, and operational review.
- Write both reports under `audits/`.
- Do not change application code, configuration, tests, dependency files, or deployment files.
- Use recommendations, safer examples, and suggested tests in the reports rather than applying changes.

### Fix Mode (`--fix`)

Use this mode only when the user explicitly invokes `securityaudit --fix` or otherwise includes the `--fix` flag with the security audit request.

- Complete the Project Preparation and Git Safety workflow first. If no git repository exists, initialize it, create/update `.gitignore`, and create the initial commit before making fixes.
- Inspect the working tree before editing. Do not overwrite or revert user changes. If unrelated changes exist, work around them; if they block safe fixes, explain the conflict.
- Identify real, evidence-backed security, DoS, robustness, frontend, or code-quality issues before fixing them. Do not make speculative hardening changes without tying them to a finding or clearly evidenced maintainability defect.
- Fix each confirmed issue with the smallest safe change that addresses the root cause while preserving existing behaviour.
- Improve badly written, fragile, duplicated, or error-prone code only when the improvement reduces a concrete risk, prevents breakage, improves error handling, or makes a confirmed fix safe to maintain.
- Add or update regression tests where practical. Include negative, abuse-case, boundary, and frontend interaction tests when relevant.
- For HTML and JavaScript changes, verify that user-visible events fire, async failures are handled, errors do not break subsequent scripts, and useful non-sensitive diagnostics go to the console.
- After each logical fix or tightly related group of fixes, run the most relevant tests or checks for that change. Prefer targeted tests first, then broader suites when risk warrants it.
- Commit only after tests/checks pass. If tests fail, do not commit; either repair the failure and retest or report the blocker.
- Use clear security- or robustness-focused commit messages, e.g. `fix: enforce webhook signature validation` or `fix: handle frontend form submission errors`.
- If a finding cannot be fixed safely in the current context, leave it uncommitted and document the reason, risk, and next step.
- At the end, summarize commits created, tests run, findings fixed, findings left open, generated audit files, and any residual risk.

## Adversarial Methodology

Use a two-pass approach:

1. Map the system as an attacker would.
   - Identify trust boundaries, entry points, exposed routes, auth gates, roles, state transitions, background jobs, queue consumers, file parsers, webhooks, third-party integrations, storage layers, admin/debug features, and deployment exposure.
   - Trace unauthenticated, low-privilege, cross-tenant, cross-origin, public file, and machine-to-machine paths first.
   - Look for ways to turn benign features into abuse primitives: enumeration, replay, over-posting, confused deputy, privilege escalation, data scraping, quota bypass, workflow bypass, SSRF, lateral movement, and persistence.
2. Validate defensively from the code.
   - Tie every plausible attack path to concrete implementation evidence.
   - Prefer safe local proof-of-concept inputs, reproduction steps, or unit-test-shaped examples.
   - State what would be required to exploit the issue and what evidence would raise or lower confidence.

## Deep DoS Review

For every public endpoint, parser, import/export path, search/filter/sort path, file upload, webhook, background worker, scheduled task, retry loop, and integration:

- Identify attacker-controlled inputs that influence CPU, memory, disk, network, database, queue depth, lock duration, recursion depth, fan-out, retries, or cache keys.
- Look for unbounded request bodies, uploads, decompression, pagination, sorting, joins, regular expressions, recursion, loops, promise/task creation, goroutines/threads, retries, timeouts, and response sizes.
- Check N+1 query patterns, expensive authorization checks, cache-bypass keys, lock contention, thundering-herd behaviour, idempotency gaps, queue flooding, retry storms, and algorithmic complexity attacks.
- Check infrastructure limits: reverse proxy body limits, app server timeouts, DB pool sizes, worker concurrency, memory/CPU limits, rate limits, autoscaling assumptions, and circuit breakers.
- For each credible DoS vector, include a safe trigger example, likely resource impact, required attacker capability, and concrete resource-control fix.

## Code Quality and Functionality Review

In both modes, review code quality as a reliability and security input:

- Identify fragile or badly written code that increases security or operational risk: duplicated validation, inconsistent auth checks, swallowed errors, overly broad exception handling, ambiguous state transitions, hidden global state, unsafe defaults, poor input normalization, magic strings, dead code, race-prone code, and hard-to-test complexity.
- Distinguish style preferences from risk-bearing defects. Report only issues that affect correctness, resilience, maintainability of security controls, user-facing behaviour, or safe future change.
- In fix mode, improve the smallest area necessary to reduce the risk while preserving existing behaviour and public APIs.
- Add tests or checks before/after refactors when behaviour preservation is non-trivial.

## HTML and JavaScript Review

When HTML, JavaScript, TypeScript, templates, or browser-facing code exists:

- Verify that scripts load in the intended order and do not fail the whole page when one feature errors.
- Check that selectors match existing DOM nodes, event listeners are attached after elements exist, dynamically inserted controls receive handlers, and forms/buttons/links fire the expected events.
- Exercise key interactions when a local app can run: forms, navigation, modals, uploads, filters, destructive actions, auth/logout, and async flows.
- Inspect browser console output when possible. Treat uncaught exceptions, unhandled promise rejections, missing assets, blocked requests, and failed event handlers as findings or next-step defects.
- Ensure errors are handled with user-safe behaviour and useful non-sensitive `console.debug`, `console.warn`, or `console.error` context for developers.
- Do not log credentials, tokens, session IDs, personal data, sensitive request bodies, or full server responses that may contain secrets.
- Check browser security issues: DOM XSS, unsafe `innerHTML`, template injection, open redirects, insecure postMessage, CSRF, CORS assumptions, clickjacking, mixed content, insecure cookies, and missing security headers.

## Review Scope

Inspect all relevant project surfaces, including:

- Application source code, tests, build scripts, package manifests, lockfiles, and CI/CD configuration.
- Infrastructure and deployment files such as Dockerfiles, Compose, Kubernetes, Terraform, Ansible, Helm, cloud config, and environment examples.
- Authentication, authorisation, session, cookie, token, cache, cryptography, key management, logging, monitoring, and error handling code.
- API routes, controllers, handlers, jobs, workers, queues, scheduled tasks, webhooks, integrations, database access, migrations, file upload, and file processing paths.
- Input validation, output encoding, CORS, CSRF, security headers, rate limiting, throttling, timeouts, retries, pagination, body-size limits, and resource controls.
- Frontend templates, HTML, JavaScript/TypeScript, route transitions, event handlers, async flows, error boundaries, console diagnostics, and browser build configuration.
- Admin, debug, development-only, or operational functionality exposed by code or configuration.
- Tests and test fixtures, especially where they reveal intended security, auth, validation, error, and abuse-case behaviour.

## Issue Categories

Look specifically for these categories, but do not limit the audit to them:

- Authentication: missing or weak authentication, insecure password/reset flows, session fixation, token leakage, weak remember-me logic, missing MFA for sensitive flows.
- Authorisation: IDOR, broken access control, privilege escalation, missing ownership checks, tenant isolation failures, role bypasses, admin route exposure.
- Injection: SQL, NoSQL, command, LDAP, template, header, log, path traversal, unsafe deserialisation, SSRF, XXE.
- Browser-side risks: XSS, CSRF, CORS misconfiguration, clickjacking, insecure cookies, missing security headers, DOM injection, unsafe postMessage, open redirects.
- API risks: missing validation, excessive data exposure, mass assignment, unsafe pagination, missing rate limits, weak errors, unsafe webhooks, replay risks, missing idempotency.
- Denial-of-service: unbounded queries, request bodies, pagination, regex backtracking, infinite loops, recursion, memory or CPU exhaustion, file upload abuse, decompression bombs, queue flooding, lock contention, retry storms, missing timeouts, N+1 attack vectors, cache bypass, algorithmic complexity attacks.
- Data protection and privacy: secrets, sensitive data or PII leakage, unsafe logs/errors/backups, weak retention, missing encryption in transit or at rest where relevant.
- Cryptography: weak algorithms, hardcoded keys, predictable tokens, insecure randomness, missing key rotation, bad signatures, hashes, salts, or IVs.
- Dependency and supply chain: vulnerable, unpinned, suspicious, deprecated, or confused dependencies; unsafe build scripts; insecure package sources; CI/CD secret exposure.
- Infrastructure and deployment: insecure images, root containers, excessive capabilities, missing resource limits, network exposure, default credentials, debug mode, verbose production errors, TLS issues, health/readiness gaps, overly permissive IAM/RBAC/file permissions/service accounts.
- Business logic: race conditions, TOCTOU, payment/credit manipulation, workflow bypass, replay, abuse of invitation/referral/voucher/discount/reward systems, state machine bypasses, missing audit trails.
- Frontend robustness: broken event handlers, uncaught exceptions, unhandled promise rejections, stale selectors, silent async failures, missing user-safe fallback states, sensitive debug logs.
- Code quality risk: security-critical duplication, fragile parsing, inconsistent normalization, dead or unreachable security checks, overly broad exception handling, poorly isolated side effects, missing invariants.
- Test gaps: missing security, negative, abuse-case, boundary, frontend interaction, and regression tests.

## Finding Requirements

For every finding include:

- Finding ID, title, severity (`Critical`, `High`, `Medium`, `Low`, or `Informational`), and confidence (`High`, `Medium`, or `Low`).
- Affected files and line numbers where possible.
- Affected component, route, function, class, service, job, dependency, frontend interaction, or deployment control.
- Clear explanation, why it matters, exploitability, potential impact, concrete exploit/trigger example, and safe proof-of-concept or reproduction steps where appropriate.
- Recommended fix, safer code/configuration example where practical, and suggested tests.
- Relevant CWE, OWASP ASVS, OWASP Top 10, OWASP API Security Top 10, or similar mapping where applicable.
- Assumptions, limitations, and uncertainty.

## Security Report Structure

Write the final Markdown security report with these sections:

1. `# Security Audit Report`
2. `## 1. Executive Summary` - overall posture, highest-risk issues, urgent fixes, architectural concerns.
3. `## 2. Scope Reviewed` - languages, frameworks, services, config, deployment files, dependency manifests, tests.
4. `## 3. Methodology` - static review, dependency review, configuration review, threat modelling, adversarial attack-surface mapping, DoS analysis, frontend review, test review.
5. `## 4. Risk Rating Method` - how severity and confidence were assigned.
6. `## 5. Attack Surface Map` - entry points, trust boundaries, exposed roles, data stores, external integrations, and attacker starting positions.
7. `## 6. Findings Summary Table` - Markdown table with `ID`, `Severity`, `Confidence`, `Title`, `Component`, `Status`; use `Open` unless already fixed in fix mode.
8. `## 7. Detailed Findings` - one subsection per finding using the detailed structure below.
9. `## 8. Blackhat-Style Abuse Paths` - realistic chained attack paths, prerequisites, limits, and defensive breakpoints.
10. `## 9. Denial-of-Service Review`
11. `## 10. Dependency and Supply-Chain Review`
12. `## 11. Secrets and Sensitive Data Review`
13. `## 12. Authentication and Authorisation Review`
14. `## 13. Input Validation and Output Encoding Review`
15. `## 14. Frontend HTML/JavaScript Robustness Review`
16. `## 15. Infrastructure and Deployment Review`
17. `## 16. Logging, Monitoring, and Error Handling Review`
18. `## 17. Test Coverage and Security Regression Gaps`
19. `## 18. Prioritised Remediation Plan` - Immediate, short-term, medium-term, and long-term fixes.
20. `## 19. False Positives / Needs Manual Verification`
21. `## 20. Final Notes` - residual risk and limitations.

For each detailed finding, use:

```markdown
### Finding ID: [ID]

#### Title

#### Severity

#### Confidence

#### Affected Files / Components

#### Description

#### Evidence

#### Attack Scenario

#### Impact

#### Recommendation

#### Safer Example

#### Suggested Tests

#### References

#### Assumptions / Limitations
```

## Functionality and Next-Steps Report Structure

Write a separate Markdown report focused on improving the project beyond immediate security remediation:

1. `# Functionality and Next Steps Report`
2. `## 1. Executive Summary` - highest-impact functionality, reliability, maintainability, and user-experience opportunities.
3. `## 2. Current Functional Risks` - broken or fragile behaviours, brittle code paths, frontend event risks, missing error handling, and likely user-impacting issues.
4. `## 3. Code Quality Improvements` - badly written or hard-to-maintain areas, why they matter, and safe refactor steps.
5. `## 4. Frontend Interaction and Error-Handling Improvements` - event firing, async handling, console diagnostics, and user-safe fallback recommendations.
6. `## 5. Testing Roadmap` - unit, integration, end-to-end, abuse-case, frontend interaction, regression, load, and smoke tests to add.
7. `## 6. Recommended New Functionality` - evidence-backed features that fit the existing project and would improve usefulness, safety, operability, or user outcomes.
8. `## 7. Next-Level Opportunities` - larger architectural, product, observability, automation, performance, accessibility, developer-experience, or operational improvements.
9. `## 8. Prioritised Action Plan` - immediate, short-term, medium-term, and long-term actions with rationale and risk.
10. `## 9. Caveats and Validation Needed` - assumptions, manual checks, user research, or runtime validation that should happen before major changes.
