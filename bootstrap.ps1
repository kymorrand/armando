<#
.SYNOPSIS
    Armando portable bootstrap for Windows 11.

.DESCRIPTION
    Brings Armando to a bare Windows 11 box that has only PowerShell 5.1+
    (built in) and Git for Windows. Installs a local Node, the Claude Code
    CLI, and the armando repo into a self-contained prefix at
    $env:USERPROFILE\armando-portable\ (override with $env:ARMANDO_PORTABLE).
    All Claude Code state is redirected into the prefix via
    CLAUDE_CONFIG_DIR. Nothing lands in the host $HOME\.claude\.

    Mirror of bootstrap.sh. Same prefix shape, same teardown discipline,
    same auth flow.

.PARAMETER DryRun
    Print the plan; no downloads, no disk writes outside $env:TEMP.

.NOTES
    Symlink strategy (no admin / no UAC required):
      - Directory symlinks need admin or Developer Mode. We do not use them.
      - bootstrap.ps1 does NOT create symlinks itself. It delegates per-file
        agent and command linking to install.ps1, which uses directory
        junctions where possible (no admin needed) and per file hardlinks /
        copies as fallback. See install.ps1.
      - This script only creates plain directories, downloads a Node zip,
        extracts it, runs npm install, and writes to $PROFILE. None of
        those steps require admin.

    PowerShell version: tested against Windows PowerShell 5.1 (built into
    Windows 11) and PowerShell 7+. Avoid 7+-only syntax (no ternary, no
    null-coalesce). Set-StrictMode + $ErrorActionPreference='Stop' at top.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\bootstrap.ps1

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\bootstrap.ps1 -DryRun
#>

[CmdletBinding()]
param(
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

$NodeVersion       = '20.18.1'
$NodeShaWinX64     = '56e5aacdeee7168871721b75819ccacf2367de8761b78eaceacdecd41e04ca03'
$ArmandoRepoUrl    = if ($env:ARMANDO_REPO_URL) { $env:ARMANDO_REPO_URL } else { 'https://github.com/kymorrand/armando.git' }
$ArmandoPortable   = if ($env:ARMANDO_PORTABLE) { $env:ARMANDO_PORTABLE } else { Join-Path $env:USERPROFILE 'armando-portable' }

$NodeDir    = Join-Path $ArmandoPortable 'node'
$ClaudeDir  = Join-Path $ArmandoPortable 'claude'
$RepoDir    = Join-Path $ArmandoPortable 'armando'
$ClaudeHome = Join-Path $ArmandoPortable '.claude-home'

$NodeArchiveName = "node-v$NodeVersion-win-x64.zip"
$NodeArchiveUrl  = "https://nodejs.org/dist/v$NodeVersion/$NodeArchiveName"

# Portable installs use the '-portable' suffix to distinguish from a
# traditional install.ps1 block in the same $PROFILE. uninstall.ps1's regex
# accepts either form so a single uninstall removes both if present.
$MarkerBegin = '# >>> armando-portable >>>'
$MarkerEnd   = '# <<< armando-portable <<<'

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

function Write-Log {
    param([string]$Message)
    Write-Host "[armando] $Message"
}

function Write-WarnLog {
    param([string]$Message)
    Write-Host "[armando] WARN: $Message" -ForegroundColor Yellow
}

function Stop-WithError {
    param([string]$Message)
    Write-Host "[armando] ERROR: $Message" -ForegroundColor Red
    exit 1
}

function Test-Command {
    param([string]$Name)
    $cmd = Get-Command -Name $Name -ErrorAction SilentlyContinue
    return $null -ne $cmd
}

function Get-FileSha256Lower {
    param([string]$Path)
    $hash = Get-FileHash -LiteralPath $Path -Algorithm SHA256
    return $hash.Hash.ToLowerInvariant()
}

# ---------------------------------------------------------------------------
# Plan banner
# ---------------------------------------------------------------------------

Write-Log 'Armando portable bootstrap (Windows)'
Write-Log "  prefix      : $ArmandoPortable"
Write-Log "  node version: $NodeVersion (win-x64)"
Write-Log "  node dir    : $NodeDir"
Write-Log "  claude dir  : $ClaudeDir"
Write-Log "  repo dir    : $RepoDir"
Write-Log "  CLAUDE_CONFIG_DIR: $ClaudeHome"
Write-Log "  profile     : $($PROFILE.CurrentUserAllHosts)"
Write-Log "  node url    : $NodeArchiveUrl"

if ($DryRun) {
    Write-Log 'DRY RUN: no downloads, no disk writes outside $env:TEMP.'
    Write-Log 'Plan:'
    Write-Log "  1. mkdir $ArmandoPortable (node, claude, .claude-home)"
    Write-Log "  2. download + verify $NodeArchiveName (sha256: $NodeShaWinX64)"
    Write-Log "  3. extract Node into $NodeDir (skip if already present)"
    Write-Log "  4. npm install --prefix $ClaudeDir @anthropic-ai/claude-code (skip if already present)"
    Write-Log "  5. git clone $ArmandoRepoUrl $RepoDir (or git pull if present)"
    Write-Log "  6. CLAUDE_CONFIG_DIR=$ClaudeHome powershell -File $RepoDir\install.ps1"
    Write-Log "  7. write sentinel-bracketed activation block into $($PROFILE.CurrentUserAllHosts)"
    Write-Log "  8. set user-scope CLAUDE_CONFIG_DIR = $ClaudeHome"
    Write-Log '  9. print next-step instructions (claude login)'
    exit 0
}

# ---------------------------------------------------------------------------
# Pre flight
# ---------------------------------------------------------------------------

if (-not (Test-Command -Name 'git')) {
    Stop-WithError "git not found on PATH. Install Git for Windows from https://git-scm.com/download/win and re-run."
}

# ---------------------------------------------------------------------------
# Layout
# ---------------------------------------------------------------------------

foreach ($d in @($ArmandoPortable, $NodeDir, $ClaudeDir, $ClaudeHome)) {
    if (-not (Test-Path -LiteralPath $d)) {
        New-Item -ItemType Directory -Path $d -Force | Out-Null
    }
}

# ---------------------------------------------------------------------------
# Node
# ---------------------------------------------------------------------------

$NodeExe = Join-Path $NodeDir 'node.exe'

if (Test-Path -LiteralPath $NodeExe) {
    $existing = & $NodeExe --version 2>$null
    Write-Log "Node already installed at $NodeExe ($existing)"
}
else {
    Write-Log "Downloading Node $NodeVersion (win-x64)..."
    $tmpZip = Join-Path $env:TEMP ("armando-node-{0}.zip" -f ([System.IO.Path]::GetRandomFileName()))

    try {
        # Prefer TLS 1.2 on Windows PowerShell 5.1.
        try {
            [System.Net.ServicePointManager]::SecurityProtocol = `
                [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
        } catch {
            # Older runtime; ignore.
        }

        try {
            Invoke-WebRequest -Uri $NodeArchiveUrl -OutFile $tmpZip -UseBasicParsing
        }
        catch {
            Stop-WithError "failed to download $NodeArchiveUrl. Check network and retry."
        }

        $localSha = Get-FileSha256Lower -Path $tmpZip
        if ($localSha -ne $NodeShaWinX64) {
            Stop-WithError "Node archive checksum mismatch. expected=$NodeShaWinX64 got=$localSha"
        }
        Write-Log 'Node archive checksum verified.'

        Write-Log "Extracting Node into $NodeDir..."
        $tmpExtract = Join-Path $env:TEMP ("armando-node-extract-{0}" -f ([System.IO.Path]::GetRandomFileName()))
        New-Item -ItemType Directory -Path $tmpExtract -Force | Out-Null
        Expand-Archive -LiteralPath $tmpZip -DestinationPath $tmpExtract -Force

        $extractedRoot = Get-ChildItem -LiteralPath $tmpExtract -Directory | Select-Object -First 1
        if ($null -eq $extractedRoot) {
            Stop-WithError 'Node archive extracted no directory.'
        }

        # Copy contents (node.exe, npm.cmd, npx.cmd, node_modules\, ...) into $NodeDir.
        Get-ChildItem -LiteralPath $extractedRoot.FullName -Force | ForEach-Object {
            Copy-Item -LiteralPath $_.FullName -Destination $NodeDir -Recurse -Force
        }

        Remove-Item -LiteralPath $tmpExtract -Recurse -Force -ErrorAction SilentlyContinue
    }
    finally {
        if (Test-Path -LiteralPath $tmpZip) {
            Remove-Item -LiteralPath $tmpZip -Force -ErrorAction SilentlyContinue
        }
    }

    if (-not (Test-Path -LiteralPath $NodeExe)) {
        Stop-WithError "Node extraction failed: $NodeExe not present."
    }
    $installedVersion = & $NodeExe --version 2>$null
    Write-Log "Node installed: $installedVersion"
}

# Put portable node at the front of the in-process PATH so npm + claude resolve.
$env:PATH = "$NodeDir;$env:PATH"

# ---------------------------------------------------------------------------
# Claude Code
# ---------------------------------------------------------------------------

$ClaudeCliCmd = Join-Path $ClaudeDir 'node_modules\.bin\claude.cmd'
$ClaudeCliPs1 = Join-Path $ClaudeDir 'node_modules\.bin\claude.ps1'

if ((Test-Path -LiteralPath $ClaudeCliCmd) -or (Test-Path -LiteralPath $ClaudeCliPs1)) {
    Write-Log "Claude Code already installed under $ClaudeDir"
}
else {
    Write-Log "Installing @anthropic-ai/claude-code into $ClaudeDir..."
    $npmCmd = Join-Path $NodeDir 'npm.cmd'
    if (-not (Test-Path -LiteralPath $npmCmd)) {
        Stop-WithError "npm not found at $npmCmd. Node install may be incomplete."
    }
    Push-Location -LiteralPath $ClaudeDir
    try {
        & $npmCmd install --silent --no-fund --no-audit --prefix $ClaudeDir '@anthropic-ai/claude-code'
        if ($LASTEXITCODE -ne 0) {
            Stop-WithError 'npm install of @anthropic-ai/claude-code failed.'
        }
    }
    finally {
        Pop-Location
    }
    if (-not ((Test-Path -LiteralPath $ClaudeCliCmd) -or (Test-Path -LiteralPath $ClaudeCliPs1))) {
        Stop-WithError 'Claude Code installed but the CLI shim is missing.'
    }
    Write-Log 'Claude Code installed.'
}

# ---------------------------------------------------------------------------
# Armando repo
# ---------------------------------------------------------------------------

if (Test-Path -LiteralPath (Join-Path $RepoDir '.git')) {
    Write-Log "Armando repo already present at $RepoDir. Pulling latest..."
    Push-Location -LiteralPath $RepoDir
    try {
        & git pull --quiet --ff-only
        if ($LASTEXITCODE -ne 0) {
            Write-WarnLog 'git pull failed; continuing with existing checkout.'
        }
    }
    finally {
        Pop-Location
    }
}
else {
    Write-Log "Cloning $ArmandoRepoUrl into $RepoDir..."
    & git clone --quiet $ArmandoRepoUrl $RepoDir
    if ($LASTEXITCODE -ne 0) {
        Stop-WithError "git clone failed: $ArmandoRepoUrl"
    }
}

# ---------------------------------------------------------------------------
# Symlink / hardlink / copy agents and commands via install.ps1
# ---------------------------------------------------------------------------

$RepoInstaller = Join-Path $RepoDir 'install.ps1'
if (-not (Test-Path -LiteralPath $RepoInstaller)) {
    Stop-WithError "install.ps1 missing from cloned repo at $RepoInstaller"
}

Write-Log "Running install.ps1 with CLAUDE_CONFIG_DIR=$ClaudeHome..."
$prevClaudeConfigDir = $env:CLAUDE_CONFIG_DIR
$env:CLAUDE_CONFIG_DIR = $ClaudeHome
try {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $RepoInstaller
    if ($LASTEXITCODE -ne 0) {
        Stop-WithError 'install.ps1 failed.'
    }
}
finally {
    if ($null -eq $prevClaudeConfigDir) {
        Remove-Item Env:CLAUDE_CONFIG_DIR -ErrorAction SilentlyContinue
    }
    else {
        $env:CLAUDE_CONFIG_DIR = $prevClaudeConfigDir
    }
}

# ---------------------------------------------------------------------------
# User-scope CLAUDE_CONFIG_DIR
# ---------------------------------------------------------------------------

try {
    [Environment]::SetEnvironmentVariable('CLAUDE_CONFIG_DIR', $ClaudeHome, 'User')
    Write-Log "Set user-scope CLAUDE_CONFIG_DIR = $ClaudeHome"
}
catch {
    Write-WarnLog "Failed to persist CLAUDE_CONFIG_DIR to user env: $($_.Exception.Message)"
}

# ---------------------------------------------------------------------------
# Activation block in $PROFILE
# ---------------------------------------------------------------------------

function Write-ActivationBlock {
    param(
        [string]$ProfilePath,
        [string]$Prefix
    )

    # Use direct .NET file APIs throughout. Cmdlet parameter binding under
    # Windows PowerShell 5.1 + StrictMode Latest has fired AmbiguousParameterSet
    # in the wild for New-Item/Add-Content combinations here; .NET I/O bypasses
    # cmdlet param sets entirely and is fully unambiguous.

    $parent = [System.IO.Path]::GetDirectoryName($ProfilePath)
    if ($parent -and -not [System.IO.Directory]::Exists($parent)) {
        [System.IO.Directory]::CreateDirectory($parent) | Out-Null
    }

    $existing = ''
    if ([System.IO.File]::Exists($ProfilePath)) {
        $existing = [System.IO.File]::ReadAllText($ProfilePath)
    }
    if ($existing -and ($existing -match [regex]::Escape($MarkerBegin))) {
        Write-Log "Activation block already present in $ProfilePath (idempotent skip)."
        return
    }

    $block = @"

$MarkerBegin
# Armando portable activation. Removable via uninstall.ps1.
`$env:ARMANDO_PORTABLE = '$Prefix'
if (Test-Path -LiteralPath (Join-Path `$env:ARMANDO_PORTABLE 'node\node.exe')) {
    `$env:CLAUDE_CONFIG_DIR = Join-Path `$env:ARMANDO_PORTABLE '.claude-home'
    `$env:PATH = (Join-Path `$env:ARMANDO_PORTABLE 'claude\node_modules\.bin') + ';' + (Join-Path `$env:ARMANDO_PORTABLE 'node') + ';' + `$env:PATH
}
function armando {
    if (-not (Test-Path -LiteralPath (Join-Path `$env:ARMANDO_PORTABLE 'node\node.exe'))) {
        Write-Host "armando: portable prefix missing at `$env:ARMANDO_PORTABLE" -ForegroundColor Red
        return
    }
    `$repo = Join-Path `$env:ARMANDO_PORTABLE 'armando'
    if (Test-Path -LiteralPath (Join-Path `$repo '.git')) {
        Push-Location -LiteralPath `$repo
        try { git pull --quiet 2>`$null } catch { }
        Pop-Location
    }
    `$versionFile = Join-Path `$repo 'VERSION'
    if (Test-Path -LiteralPath `$versionFile) {
        `$version = (Get-Content -LiteralPath `$versionFile -First 1).Trim()
    } else {
        `$version = 'dev'
    }
    Write-Host ''
    Write-Host "  Armando v`$version: The Gardener (portable)" -ForegroundColor Green
    Write-Host "  Let's go do it, dude." -ForegroundColor DarkGray
    Write-Host ''
    if (Test-Path -LiteralPath '.venv\Scripts\Activate.ps1') {
        & '.venv\Scripts\Activate.ps1'
    }
    claude --dangerously-skip-permissions --agent armando `@args
    if (Test-Path -LiteralPath (Join-Path `$repo '.git')) {
        Push-Location -LiteralPath `$repo
        try {
            git add -A 2>`$null
            git diff --cached --quiet 2>`$null
            if (`$LASTEXITCODE -ne 0) {
                `$msg = "Session update from `$env:COMPUTERNAME on `$(Get-Date -Format 'yyyy-MM-dd_HHmm')"
                git commit -m `$msg --quiet 2>`$null
                git push --quiet 2>`$null
            }
        } catch { }
        Pop-Location
    }
}
$MarkerEnd
"@

    $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
    if ([System.IO.File]::Exists($ProfilePath)) {
        [System.IO.File]::AppendAllText($ProfilePath, $block, $utf8NoBom)
    } else {
        [System.IO.File]::WriteAllText($ProfilePath, $block, $utf8NoBom)
    }
    Write-Log "Wrote activation block to $ProfilePath"
}

Write-ActivationBlock -ProfilePath $PROFILE.CurrentUserAllHosts -Prefix $ArmandoPortable

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------

Write-Host ''
Write-Log 'Bootstrap complete.'
Write-Host ''
Write-Host 'Next steps:' -ForegroundColor Cyan
Write-Host "  1. Open a new PowerShell window (so `$PROFILE re-runs)."
Write-Host '  2. Authenticate Claude Code one time:'
Write-Host '       claude login'
Write-Host '  3. From any project directory, run:'
Write-Host '       armando'
Write-Host ''
Write-Host 'To remove everything later:'
Write-Host "       powershell -ExecutionPolicy Bypass -File '$RepoDir\uninstall.ps1'"
Write-Host ''
