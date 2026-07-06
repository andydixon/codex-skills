#!/usr/bin/env bash
set -euo pipefail

REPO_SLUG="${1:-${SECURITYAUDIT_REPO:-andydixon/securityaudit-skill}}"
REF="${2:-${SECURITYAUDIT_REF:-main}}"
DEFAULT_SKILLS="securityaudit aitm debullshit summarise"
SKILLS="${SECURITYAUDIT_SKILLS:-${SECURITYAUDIT_SKILL_PATH:-$DEFAULT_SKILLS}}"
SKILLS="${SKILLS//,/ }"
CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
DEST_PARENT="$CODEX_HOME_DIR/skills"

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

validate_skill_name() {
  skill="$1"
  case "$skill" in
    ""|*[!A-Za-z0-9_-]*)
      fail "Invalid skill name: $skill"
      ;;
  esac
}

print_usage() {
  say "Restart Codex, then use:"
  for skill in $SKILLS; do
    case "$skill" in
      securityaudit)
        say '  $securityaudit'
        say '  $securityaudit --fix'
        ;;
      *)
        say "  \$$skill"
        ;;
    esac
  done
}

copy_skill() {
  src="$1"
  skill="$2"
  dest="$DEST_PARENT/$skill"

  validate_skill_name "$skill"

  [ -f "$src/SKILL.md" ] || fail "Could not find SKILL.md at $src"
  grep -q "^name: $skill$" "$src/SKILL.md" || fail "SKILL.md at $src does not look like the $skill skill"

  mkdir -p "$DEST_PARENT"
  stage="$(mktemp -d "$DEST_PARENT/.$skill-install.XXXXXX")"
  mkdir -p "$stage/$skill"
  cp -R "$src/." "$stage/$skill/"

  [ -f "$stage/$skill/SKILL.md" ] || fail "Install staging failed for $skill"
  grep -q "^name: $skill$" "$stage/$skill/SKILL.md" || fail "Install validation failed for $skill"

  if [ -e "$dest" ]; then
    backup="$dest.backup.$(date +%Y%m%d-%H%M%S)"
    say "Existing $skill skill found. Backing it up to:"
    say "$backup"
    mv "$dest" "$backup"
  fi

  mv "$stage/$skill" "$dest"
  rmdir "$stage" 2>/dev/null || true
  say "Installed $skill to $dest"
}

SCRIPT_PATH="${BASH_SOURCE[0]:-}"
if [ -n "$SCRIPT_PATH" ] && [ -f "$SCRIPT_PATH" ]; then
  SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
else
  SCRIPT_DIR=""
fi

if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/securityaudit/SKILL.md" ]; then
  say "Installing skills from local checkout..."
  installed_any=false
  for skill in $SKILLS; do
    [ -f "$SCRIPT_DIR/$skill/SKILL.md" ] || fail "Could not find $skill/SKILL.md in local checkout"
    copy_skill "$SCRIPT_DIR/$skill" "$skill"
    installed_any=true
  done
  [ "$installed_any" = true ] || fail "No skills requested"
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

  say "Downloading skills from $REPO_SLUG ($REF)..."
  curl -fsSL "$url" -o "$archive"
  tar -xzf "$archive" -C "$tmp"

  installed_any=false
  for skill in $SKILLS; do
    src="$(find "$tmp" -path "*/$skill/SKILL.md" -print -quit)"
    [ -n "$src" ] || fail "Could not find $skill/SKILL.md in the downloaded repo"
    copy_skill "$(dirname "$src")" "$skill"
    installed_any=true
  done
  [ "$installed_any" = true ] || fail "No skills requested"
fi

say ""
say "Installed skills:"
for skill in $SKILLS; do
  say "  $skill -> $DEST_PARENT/$skill"
done
say ""
print_usage
