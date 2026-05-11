<#
.SYNOPSIS
    Armando - Windows PowerShell installer.

.DESCRIPTION
    Wires the armando repo into Claude Code's config directory.

    Honors $env:CLAUDE_CONFIG_DIR (Claude Code's documented relocation env
    var). When unset, defaults to $HOME\.claude to preserve traditional
    behavior. bootstrap.ps1 sets CLAUDE_CONFIG_DIR into the portable
    prefix before invoking this script.

    Link strategy (no admin / no UAC required):
      - Per file agent and command links use NTFS hardlinks
        (New-Item -ItemType HardLink). Hardlinks on the same volume do not
        require admin or Developer Mode. They also keep the source-of-truth
        in this repo: edits to repo\agents\*.md are visible immediately under
        $CLAUDE_CONFIG_DIR\agents\.
      - If the source and target are on different volumes (rare, but
        possible when CLAUDE_CONFIG_DIR is moved off C:), hardlinks fail.
        We fall back to a plain Copy-Item. The Windows uninstaller detects
        copies by content hash compare against the source and removes them.
      - Directory symlinks are NOT used (they require admin or Developer
        Mode). Directory junctions are an option but per file hardlinks
        give better granularity (uninstall can tell which files came from
        Armando).

.NOTES
    Set-StrictMode Latest + $ErrorActionPreference='Stop'. No em dashes.
    Cross compatible with Windows PowerShell 5.1 and PowerShell 7+.
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ArmandoDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if ($env:CLAUDE_CONFIG_DIR) {
    $ClaudeConfigDir = $env:CLAUDE_CONFIG_DIR
}
else {
    $ClaudeConfigDir = Join-Path $HOME '.claude'
}
$ClaudeAgentsDir   = Join-Path $ClaudeConfigDir 'agents'
$ClaudeCommandsDir = Join-Path $ClaudeConfigDir 'commands'

Write-Host "Installing Armando from: $ArmandoDir" -ForegroundColor Cyan
Write-Host "Target CLAUDE_CONFIG_DIR: $ClaudeConfigDir" -ForegroundColor Cyan
Write-Host ''

# --- Create Claude Code directories ---
New-Item -ItemType Directory -Force -Path $ClaudeAgentsDir   | Out-Null
New-Item -ItemType Directory -Force -Path $ClaudeCommandsDir | Out-Null

function Test-IsReparsePoint {
    param([System.IO.FileSystemInfo]$Item)
    try {
        return ($Item.Attributes -band [IO.FileAttributes]::ReparsePoint) -eq [IO.FileAttributes]::ReparsePoint
    } catch {
        return $false
    }
}

function Install-ArmandoFile {
    param(
        [string]$SourcePath,
        [string]$TargetPath
    )
    # Clean any prior entry at target.
    if (Test-Path -LiteralPath $TargetPath) {
        try {
            $existing = Get-Item -LiteralPath $TargetPath -Force
            if ((Test-IsReparsePoint -Item $existing) -or -not $existing.PSIsContainer) {
                Remove-Item -LiteralPath $TargetPath -Force
            }
            else {
                $bak = "$TargetPath.bak"
                Write-Host "  WARNING: $TargetPath exists and is a real directory. Backing up to $bak" -ForegroundColor Red
                Move-Item -LiteralPath $TargetPath -Destination $bak -Force
            }
        } catch {
            # If we cannot inspect it, attempt removal anyway.
            Remove-Item -LiteralPath $TargetPath -Force -Recurse -ErrorAction SilentlyContinue
        }
    }

    # Try hardlink first (no admin needed, same-volume only).
    $linked = $false
    try {
        New-Item -ItemType HardLink -Path $TargetPath -Target $SourcePath -ErrorAction Stop | Out-Null
        $linked = $true
    } catch {
        $linked = $false
    }
    if (-not $linked) {
        Copy-Item -LiteralPath $SourcePath -Destination $TargetPath -Force
        Write-Host "  Copied (cross-volume fallback): $([IO.Path]::GetFileName($TargetPath))" -ForegroundColor DarkGray
    }
    else {
        Write-Host "  Linked: $([IO.Path]::GetFileName($TargetPath))" -ForegroundColor Green
    }
}

Write-Host 'Linking agents...' -ForegroundColor Yellow
Get-ChildItem -LiteralPath (Join-Path $ArmandoDir 'agents') -Filter '*.md' -File | ForEach-Object {
    Install-ArmandoFile -SourcePath $_.FullName -TargetPath (Join-Path $ClaudeAgentsDir $_.Name)
}

Write-Host 'Linking commands...' -ForegroundColor Yellow
Get-ChildItem -LiteralPath (Join-Path $ArmandoDir 'commands') -Filter '*.md' -File | ForEach-Object {
    Install-ArmandoFile -SourcePath $_.FullName -TargetPath (Join-Path $ClaudeCommandsDir $_.Name)
}

# ---------------------------------------------------------------------------
# Profile activation block
# ---------------------------------------------------------------------------
# Portable installs handle their own activation block via bootstrap.ps1, so
# only write the traditional block when CLAUDE_CONFIG_DIR is the default.
# ---------------------------------------------------------------------------

$DefaultClaudeConfigDir = Join-Path $HOME '.claude'
if ($ClaudeConfigDir -ne $DefaultClaudeConfigDir) {
    Write-Host ''
    Write-Host 'CLAUDE_CONFIG_DIR is non-default; skipping PowerShell profile edit.' -ForegroundColor Yellow
    Write-Host '(The portable bootstrap manages its own activation block.)'
    Write-Host ''
    Write-Host 'Done.' -ForegroundColor Cyan
    exit 0
}

$ProfilePath = $PROFILE.CurrentUserAllHosts
$profileParent = Split-Path -LiteralPath $ProfilePath -Parent
if (-not (Test-Path -LiteralPath $profileParent)) {
    New-Item -ItemType Directory -Path $profileParent -Force | Out-Null
}
if (-not (Test-Path -LiteralPath $ProfilePath)) {
    New-Item -ItemType File -Path $ProfilePath -Force | Out-Null
    Write-Host "Created PowerShell profile at: $ProfilePath" -ForegroundColor Yellow
}

$MarkerBegin = '# >>> armando >>>'
$MarkerEnd   = '# <<< armando <<<'

$profileContent = Get-Content -LiteralPath $ProfilePath -Raw -ErrorAction SilentlyContinue
if ($null -ne $profileContent -and $profileContent -match [regex]::Escape($MarkerBegin)) {
    Write-Host ''
    Write-Host "armando block already present in $ProfilePath. Skipping." -ForegroundColor Yellow
    Write-Host "Remove the block between '$MarkerBegin' and '$MarkerEnd' and re-run to refresh."
}
else {
    $block = @"

$MarkerBegin
# Armando: AI development team. Removable via uninstall.ps1.
function armando {
    `$armandoRepo = Join-Path `$HOME 'armando'
    if (Test-Path -LiteralPath (Join-Path `$armandoRepo '.git')) {
        Push-Location -LiteralPath `$armandoRepo
        try { git pull --quiet 2>`$null } catch { }
        Pop-Location
    }
    `$versionFile = Join-Path `$armandoRepo 'VERSION'
    if (Test-Path -LiteralPath `$versionFile) {
        `$version = (Get-Content -LiteralPath `$versionFile -First 1).Trim()
    } else {
        `$version = 'dev'
    }
    Write-Host ''
    Write-Host "  Armando v`$version" -ForegroundColor Green
    Write-Host "  Let's go do it, dude." -ForegroundColor DarkGray
    Write-Host ''
    if (Test-Path -LiteralPath '.venv\Scripts\Activate.ps1') {
        & '.venv\Scripts\Activate.ps1'
    }
    claude --dangerously-skip-permissions --agent armando `@args
    if (Test-Path -LiteralPath (Join-Path `$armandoRepo '.git')) {
        Push-Location -LiteralPath `$armandoRepo
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
    Add-Content -LiteralPath $ProfilePath -Value $block
    Write-Host ''
    Write-Host "Added armando block to $ProfilePath" -ForegroundColor Green
}

Write-Host ''
Write-Host 'Done. Restart PowerShell, then navigate to any project and type armando to start.' -ForegroundColor Cyan
