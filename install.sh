#!/usr/bin/env bash
set -euo pipefail

REPO_SLUG="${1:-${SECURITYAUDIT_REPO:-andydixon/securityaudit-skill}}"
REF="${2:-${SECURITYAUDIT_REF:-main}}"
SKILL_PATH="${SECURITYAUDIT_SKILL_PATH:-securityaudit}"
CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
DEST_PARENT="$CODEX_HOME_DIR/skills"
DEST="$DEST_PARENT/securityaudit"

say() {
  printf '%s\n' "$*"
}

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

need_command() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"
}

copy_skill() {
  src="$1"
  [ -f "$src/SKILL.md" ] || fail "Could not find SKILL.md at $src"
  grep -q '^name: securityaudit$' "$src/SKILL.md" || fail "SKILL.md does not look like the securityaudit skill"

  mkdir -p "$DEST_PARENT"
  stage="$(mktemp -d "$DEST_PARENT/.securityaudit-install.XXXXXX")"
  mkdir -p "$stage/securityaudit"
  cp -R "$src/." "$stage/securityaudit/"

  [ -f "$stage/securityaudit/SKILL.md" ] || fail "Install staging failed"
  grep -q '^name: securityaudit$' "$stage/securityaudit/SKILL.md" || fail "Install validation failed"

  if [ -e "$DEST" ]; then
    backup="$DEST.backup.$(date +%Y%m%d-%H%M%S)"
    say "Existing securityaudit skill found. Backing it up to:"
    say "$backup"
    mv "$DEST" "$backup"
  fi

  mv "$stage/securityaudit" "$DEST"
  rmdir "$stage" 2>/dev/null || true
}

SCRIPT_PATH="${BASH_SOURCE[0]:-}"
if [ -n "$SCRIPT_PATH" ] && [ -f "$SCRIPT_PATH" ]; then
  SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
else
  SCRIPT_DIR=""
fi

if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/$SKILL_PATH/SKILL.md" ]; then
  say "Installing securityaudit from local checkout..."
  copy_skill "$SCRIPT_DIR/$SKILL_PATH"
else
  need_command curl
  need_command tar

  tmp="$(mktemp -d)"
  cleanup() {
    rm -rf "$tmp"
  }
  trap cleanup EXIT

  archive="$tmp/repo.tar.gz"
  url="https://github.com/$REPO_SLUG/archive/refs/heads/$REF.tar.gz"

  say "Downloading securityaudit from $REPO_SLUG ($REF)..."
  curl -fsSL "$url" -o "$archive"
  tar -xzf "$archive" -C "$tmp"

  src="$(find "$tmp" -path "*/$SKILL_PATH/SKILL.md" -print -quit)"
  [ -n "$src" ] || fail "Could not find $SKILL_PATH/SKILL.md in the downloaded repo"
  copy_skill "$(dirname "$src")"
fi

say ""
say "Installed securityaudit to:"
say "$DEST"
say ""
say "Restart Codex, then use:"
say "  securityaudit"
say "  securityaudit --fix"
