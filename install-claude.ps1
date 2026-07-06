param(
  [string]$RepoSlug = $(if ($env:SECURITYAUDIT_REPO) { $env:SECURITYAUDIT_REPO } else { "andydixon/securityaudit-skill" }),
  [string]$Ref = $(if ($env:SECURITYAUDIT_REF) { $env:SECURITYAUDIT_REF } else { "main" }),
  [Alias("SkillPath")]
  [string]$Skills = $(if ($env:SECURITYAUDIT_SKILLS) { $env:SECURITYAUDIT_SKILLS } elseif ($env:SECURITYAUDIT_SKILL_PATH) { $env:SECURITYAUDIT_SKILL_PATH } else { "securityaudit aitm debullshit summarise" })
)

$ErrorActionPreference = "Stop"

function Say {
  param([string]$Message)
  Write-Host $Message
}

function Fail {
  param([string]$Message)
  Write-Error $Message
  exit 1
}

function Get-SkillList {
  param([string]$SkillText)
  return @($SkillText -split "[,\s]+" | Where-Object { $_ })
}

function Assert-ValidSkillName {
  param([string]$SkillName)
  if ($SkillName -notmatch "^[A-Za-z0-9_-]+$") {
    Fail "Invalid skill name: $SkillName"
  }
}

function Show-ClaudeUsage {
  param([string[]]$SkillNames)

  Say "Restart Claude Code if it was already open, then use:"
  foreach ($skill in $SkillNames) {
    if ($skill -eq "securityaudit") {
      Say "  /securityaudit"
      Say "  /securityaudit --fix"
    }
    else {
      Say "  /$skill"
    }
  }
}

function Copy-ClaudeSkill {
  param(
    [string]$SourcePath,
    [string]$SkillName
  )

  Assert-ValidSkillName -SkillName $SkillName

  $skillFile = Join-Path $SourcePath "SKILL.md"
  if (-not (Test-Path -LiteralPath $skillFile)) {
    Fail "Could not find SKILL.md at $SourcePath"
  }

  $skillText = Get-Content -LiteralPath $skillFile -Raw
  if ($skillText -notmatch "(?m)^name:\s*$([regex]::Escape($SkillName))\s*$") {
    Fail "SKILL.md at $SourcePath does not look like the $SkillName skill"
  }

  $claudeHome = if ($env:CLAUDE_HOME) { $env:CLAUDE_HOME } else { Join-Path $HOME ".claude" }
  $destParent = Join-Path $claudeHome "skills"
  $dest = Join-Path $destParent $SkillName

  New-Item -ItemType Directory -Force -Path $destParent | Out-Null

  $stage = Join-Path $destParent (".$SkillName-claude-install-" + [Guid]::NewGuid().ToString("N"))
  $stageSkill = Join-Path $stage $SkillName
  New-Item -ItemType Directory -Force -Path $stageSkill | Out-Null

  Copy-Item -LiteralPath $skillFile -Destination (Join-Path $stageSkill "SKILL.md") -Force
  foreach ($dir in @("scripts", "references", "assets")) {
    $sourceDir = Join-Path $SourcePath $dir
    if (Test-Path -LiteralPath $sourceDir) {
      Copy-Item -LiteralPath $sourceDir -Destination (Join-Path $stageSkill $dir) -Recurse -Force
    }
  }

  if (-not (Test-Path -LiteralPath (Join-Path $stageSkill "SKILL.md"))) {
    Fail "Install staging failed for $SkillName"
  }

  if (Test-Path -LiteralPath $dest) {
    $backup = "$dest.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Say "Existing Claude $SkillName skill found. Backing it up to:"
    Say $backup
    Move-Item -LiteralPath $dest -Destination $backup
  }

  Move-Item -LiteralPath $stageSkill -Destination $dest
  Remove-Item -LiteralPath $stage -Force -ErrorAction SilentlyContinue
  Say "Installed Claude Code $SkillName skill to $dest"
}

$skillNames = Get-SkillList -SkillText $Skills
if ($skillNames.Count -eq 0) {
  Fail "No skills requested"
}

if ($PSScriptRoot -and (Test-Path -LiteralPath (Join-Path (Join-Path $PSScriptRoot "securityaudit") "SKILL.md"))) {
  Say "Installing Claude Code skills from local checkout..."
  foreach ($skill in $skillNames) {
    $sourcePath = Join-Path $PSScriptRoot $skill
    if (-not (Test-Path -LiteralPath (Join-Path $sourcePath "SKILL.md"))) {
      Fail "Could not find $skill/SKILL.md in local checkout"
    }
    Copy-ClaudeSkill -SourcePath $sourcePath -SkillName $skill
  }
  Say ""
  Say "Installed Claude Code skills:"
  foreach ($skill in $skillNames) {
    $claudeHome = if ($env:CLAUDE_HOME) { $env:CLAUDE_HOME } else { Join-Path $HOME ".claude" }
    Say "  $skill -> $(Join-Path (Join-Path $claudeHome "skills") $skill)"
  }
  Say ""
  Show-ClaudeUsage -SkillNames $skillNames
  exit 0
}

if (-not (Get-Command Expand-Archive -ErrorAction SilentlyContinue)) {
  Fail "PowerShell Expand-Archive is required. Please use PowerShell 5 or newer."
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$temp = Join-Path ([IO.Path]::GetTempPath()) ("securityaudit-claude-install-" + [Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $temp | Out-Null

try {
  $archive = Join-Path $temp "repo.zip"
  $url = "https://github.com/$RepoSlug/archive/refs/heads/$Ref.zip"

  Say "Downloading Claude Code skills from $RepoSlug ($Ref)..."
  $client = New-Object Net.WebClient
  $client.DownloadFile($url, $archive)

  Expand-Archive -LiteralPath $archive -DestinationPath $temp -Force

  foreach ($skill in $skillNames) {
    $skillFile = Get-ChildItem -Path $temp -Filter "SKILL.md" -Recurse |
      Where-Object { Split-Path -Leaf (Split-Path -Parent $_.FullName) -eq $skill } |
      Select-Object -First 1

    if (-not $skillFile) {
      Fail "Could not find $skill/SKILL.md in the downloaded repo"
    }

    Copy-ClaudeSkill -SourcePath (Split-Path -Parent $skillFile.FullName) -SkillName $skill
  }

  Say ""
  Say "Installed Claude Code skills:"
  foreach ($skill in $skillNames) {
    $claudeHome = if ($env:CLAUDE_HOME) { $env:CLAUDE_HOME } else { Join-Path $HOME ".claude" }
    Say "  $skill -> $(Join-Path (Join-Path $claudeHome "skills") $skill)"
  }
  Say ""
  Show-ClaudeUsage -SkillNames $skillNames
}
finally {
  Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue
}
