param(
  [string]$RepoSlug = $(if ($env:SECURITYAUDIT_REPO) { $env:SECURITYAUDIT_REPO } else { "andydixon/securityaudit-skill" }),
  [string]$Ref = $(if ($env:SECURITYAUDIT_REF) { $env:SECURITYAUDIT_REF } else { "main" }),
  [string]$SkillPath = $(if ($env:SECURITYAUDIT_SKILL_PATH) { $env:SECURITYAUDIT_SKILL_PATH } else { "securityaudit" })
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

function Copy-SecurityAuditSkill {
  param([string]$SourcePath)

  $skillFile = Join-Path $SourcePath "SKILL.md"
  if (-not (Test-Path -LiteralPath $skillFile)) {
    Fail "Could not find SKILL.md at $SourcePath"
  }

  $skillText = Get-Content -LiteralPath $skillFile -Raw
  if ($skillText -notmatch "(?m)^name:\s*securityaudit\s*$") {
    Fail "SKILL.md does not look like the securityaudit skill"
  }

  $codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
  $destParent = Join-Path $codexHome "skills"
  $dest = Join-Path $destParent "securityaudit"

  New-Item -ItemType Directory -Force -Path $destParent | Out-Null

  $stage = Join-Path $destParent (".securityaudit-install-" + [Guid]::NewGuid().ToString("N"))
  $stageSkill = Join-Path $stage "securityaudit"
  New-Item -ItemType Directory -Force -Path $stageSkill | Out-Null

  Copy-Item -Path (Join-Path $SourcePath "*") -Destination $stageSkill -Recurse -Force

  if (-not (Test-Path -LiteralPath (Join-Path $stageSkill "SKILL.md"))) {
    Fail "Install staging failed"
  }

  if (Test-Path -LiteralPath $dest) {
    $backup = "$dest.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Say "Existing securityaudit skill found. Backing it up to:"
    Say $backup
    Move-Item -LiteralPath $dest -Destination $backup
  }

  Move-Item -LiteralPath $stageSkill -Destination $dest
  Remove-Item -LiteralPath $stage -Force -ErrorAction SilentlyContinue

  Say ""
  Say "Installed securityaudit to:"
  Say $dest
  Say ""
  Say "Restart Codex, then use:"
  Say "  `$securityaudit"
  Say "  `$securityaudit --fix"
}

if ($PSScriptRoot -and (Test-Path -LiteralPath (Join-Path $PSScriptRoot $SkillPath "SKILL.md"))) {
  Say "Installing securityaudit from local checkout..."
  Copy-SecurityAuditSkill -SourcePath (Join-Path $PSScriptRoot $SkillPath)
  exit 0
}

if (-not (Get-Command Expand-Archive -ErrorAction SilentlyContinue)) {
  Fail "PowerShell Expand-Archive is required. Please use PowerShell 5 or newer."
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$temp = Join-Path ([IO.Path]::GetTempPath()) ("securityaudit-install-" + [Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $temp | Out-Null

try {
  $archive = Join-Path $temp "repo.zip"
  $url = "https://github.com/$RepoSlug/archive/refs/heads/$Ref.zip"

  Say "Downloading securityaudit from $RepoSlug ($Ref)..."
  $client = New-Object Net.WebClient
  $client.DownloadFile($url, $archive)

  Expand-Archive -LiteralPath $archive -DestinationPath $temp -Force

  $skillFile = Get-ChildItem -Path $temp -Filter "SKILL.md" -Recurse |
    Where-Object { Split-Path -Leaf (Split-Path -Parent $_.FullName) -eq $SkillPath } |
    Select-Object -First 1

  if (-not $skillFile) {
    Fail "Could not find $SkillPath/SKILL.md in the downloaded repo"
  }

  Copy-SecurityAuditSkill -SourcePath (Split-Path -Parent $skillFile.FullName)
}
finally {
  Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue
}
