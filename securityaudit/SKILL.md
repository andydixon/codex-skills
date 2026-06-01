---
name: securityaudit
description: Run a deep, evidence-based security audit of an entire software project and produce a Markdown report, or fix findings when invoked with "--fix". Use when the user invokes "securityaudit", "securityaudit --fix", asks for a security audit, secure code review, threat model, dependency/security configuration review, denial-of-service review, project-wide application security assessment, or asks to repair security findings from such an audit. In normal mode inspect source, tests, build/deployment files, dependencies, CI/CD, auth/authz, input handling, data protection, infrastructure, and operational risks without modifying project files except for the final report. In "--fix" mode, only modify code inside a git repository, test fixes, and commit successful changes.
---

# Security Audit

## Core Rules

- Act as a senior application security engineer, secure code reviewer, and threat modeller.
- Review the entire project deeply and sceptically. Tie every finding to concrete evidence from files, functions, routes, dependencies, configuration values, behaviours, or architectural decisions.
- In normal mode, do not modify project files except to create the final audit report.
- In fix mode, triggered only when the user includes `--fix`, follow the Fix Mode rules below.
- Save the report in the project root as `YYYYMMDD-HHII-securityAudit.md`, using the current local system date and time. Use four-digit 24-hour time, e.g. `20260131-1427-securityAudit.md`.
- Do not invent files, routes, code, dependencies, or findings. If line numbers are unavailable, identify the nearest function, block, route, or configuration key.
- If a class of issue was checked and not found, mention that briefly.
- Keep snippets short and focused.

## Execution Modes

### Normal Audit Mode

Use this mode unless the user explicitly includes `--fix`.

- Perform the full security review and write the final Markdown report.
- Do not change application code, configuration, tests, dependency files, or deployment files.
- Use recommendations, safer examples, and suggested tests in the report rather than applying changes.

### Fix Mode (`--fix`)

Use this mode only when the user explicitly invokes `securityaudit --fix` or otherwise includes the `--fix` flag with the security audit request.

- Before making any change, verify the project root is inside a git repository with `git rev-parse --show-toplevel`.
- If the project is not a git repository, refuse to modify files. Explain that fixes require the code to be in a git repository first, then stop before changing anything.
- Inspect the working tree before editing. Do not overwrite or revert user changes. If unrelated changes exist, work around them; if they block safe fixes, explain the conflict.
- Identify real, evidence-backed security issues before fixing them. Do not make speculative hardening changes without tying them to a finding.
- Fix each confirmed issue with the smallest safe change that addresses the root cause. Add or update security regression tests where practical.
- After each logical fix or tightly related group of fixes, run the most relevant tests or checks for that change. Prefer targeted tests first, then broader suites when risk warrants it.
- Commit only after tests/checks pass. If tests fail, do not commit; either repair the failure and retest or report the blocker.
- Use clear security-focused commit messages, e.g. `fix: enforce webhook signature validation`.
- If a finding cannot be fixed safely in the current context, leave it uncommitted and document the reason, risk, and next step.
- At the end, summarize commits created, tests run, findings fixed, findings left open, and any residual risk.

## Review Scope

Inspect all relevant project surfaces, including:

- Application source code, tests, build scripts, package manifests, lockfiles, and CI/CD configuration.
- Infrastructure and deployment files such as Dockerfiles, Compose, Kubernetes, Terraform, Ansible, Helm, cloud config, and environment examples.
- Authentication, authorisation, session, cookie, token, cache, cryptography, key management, logging, monitoring, and error handling code.
- API routes, controllers, handlers, jobs, workers, queues, scheduled tasks, webhooks, integrations, database access, migrations, file upload, and file processing paths.
- Input validation, output encoding, CORS, CSRF, security headers, rate limiting, throttling, timeouts, retries, pagination, body-size limits, and resource controls.
- Admin, debug, development-only, or operational functionality exposed by code or configuration.

## Issue Categories

Look specifically for these categories, but do not limit the audit to them:

- Authentication: missing or weak authentication, insecure password/reset flows, session fixation, token leakage, weak remember-me logic, missing MFA for sensitive flows.
- Authorisation: IDOR, broken access control, privilege escalation, missing ownership checks, tenant isolation failures, role bypasses, admin route exposure.
- Injection: SQL, NoSQL, command, LDAP, template, header, log, path traversal, unsafe deserialisation.
- Browser-side risks: XSS, CSRF, CORS misconfiguration, clickjacking, insecure cookies, missing security headers, DOM injection, open redirects.
- API risks: missing validation, excessive data exposure, mass assignment, unsafe pagination, missing rate limits, weak errors, unsafe webhooks, replay risks, missing idempotency.
- Denial-of-service: unbounded queries, request bodies, pagination, regex backtracking, infinite loops, recursion, memory or CPU exhaustion, file upload abuse, decompression bombs, queue flooding, lock contention, retry storms, missing timeouts, N+1 attack vectors, cache bypass, algorithmic complexity attacks.
- Data protection and privacy: secrets, sensitive data or PII leakage, unsafe logs/errors/backups, weak retention, missing encryption in transit or at rest where relevant.
- Cryptography: weak algorithms, hardcoded keys, predictable tokens, insecure randomness, missing key rotation, bad signatures, hashes, salts, or IVs.
- Dependency and supply chain: vulnerable, unpinned, suspicious, deprecated, or confused dependencies; unsafe build scripts; insecure package sources; CI/CD secret exposure.
- Infrastructure and deployment: insecure images, root containers, excessive capabilities, missing resource limits, network exposure, default credentials, debug mode, verbose production errors, TLS issues, health/readiness gaps, overly permissive IAM/RBAC/file permissions/service accounts.
- Business logic: race conditions, TOCTOU, payment/credit manipulation, workflow bypass, replay, abuse of invitation/referral/voucher/discount/reward systems, state machine bypasses, missing audit trails.
- Test gaps: missing security, negative, abuse-case, boundary, and regression tests.

## Finding Requirements

For every finding include:

- Finding ID, title, severity (`Critical`, `High`, `Medium`, `Low`, or `Informational`), and confidence (`High`, `Medium`, or `Low`).
- Affected files and line numbers where possible.
- Affected component, route, function, class, service, job, or dependency.
- Clear explanation, why it matters, exploitability, potential impact, concrete exploit/trigger example, and safe proof-of-concept or reproduction steps where appropriate.
- Recommended fix, safer code/configuration example where practical, and suggested tests.
- Relevant CWE, OWASP ASVS, OWASP Top 10, OWASP API Security Top 10, or similar mapping where applicable.
- Assumptions, limitations, and uncertainty.

## Report Structure

Write the final Markdown report with these sections:

1. `# Security Audit Report`
2. `## 1. Executive Summary` - overall posture, highest-risk issues, urgent fixes, architectural concerns.
3. `## 2. Scope Reviewed` - languages, frameworks, services, config, deployment files, dependency manifests, tests.
4. `## 3. Methodology` - static review, dependency review, configuration review, threat modelling, DoS analysis, test review.
5. `## 4. Risk Rating Method` - how severity and confidence were assigned.
6. `## 5. Findings Summary Table` - Markdown table with `ID`, `Severity`, `Confidence`, `Title`, `Component`, `Status`; use `Open` unless informational.
7. `## 6. Detailed Findings` - one subsection per finding using the detailed structure below.
8. `## 7. Denial-of-Service Review`
9. `## 8. Dependency and Supply-Chain Review`
10. `## 9. Secrets and Sensitive Data Review`
11. `## 10. Authentication and Authorisation Review`
12. `## 11. Input Validation and Output Encoding Review`
13. `## 12. Infrastructure and Deployment Review`
14. `## 13. Logging, Monitoring, and Error Handling Review`
15. `## 14. Test Coverage and Security Regression Gaps`
16. `## 15. Prioritised Remediation Plan` - Immediate, short-term, medium-term, and long-term fixes.
17. `## 16. False Positives / Needs Manual Verification`
18. `## 17. Final Notes` - residual risk and limitations.

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
