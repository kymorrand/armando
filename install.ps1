# Armando (The Gardener) — Windows PowerShell Installer
# Symlinks agents and commands into Claude Code's global directories
# and adds the 'armando' command to your PowerShell profile.
#
# Run as Administrator (symlinks require elevated permissions on Windows):
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   .\install.ps1

$ErrorActionPreference = "Stop"

$ArmandoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeAgentsDir = Join-Path $HOME ".claude\agents"
$ClaudeCommandsDir = Join-Path $HOME ".claude\commands"

Write-Host "Installing Armando from: $ArmandoDir" -ForegroundColor Cyan
Write-Host ""

# --- Create Claude Code directories ---
New-Item -ItemType Directory -Force -Path $ClaudeAgentsDir | Out-Null
New-Item -ItemType Directory -Force -Path $ClaudeCommandsDir | Out-Null

# --- Symlink agents ---
Write-Host "Linking agents..." -ForegroundColor Yellow
Get-ChildItem -Path "$ArmandoDir\agents\*.md" | ForEach-Object {
    $target = Join-Path $ClaudeAgentsDir $_.Name
    if (Test-Path $target) {
        $item = Get-Item $target
        if ($item.LinkType -eq "SymbolicLink") {
            Remove-Item $target
        } else {
            Write-Host "  WARNING: $target exists. Backing up to $target.bak" -ForegroundColor Red
            Move-Item $target "$target.bak"
        }
    }
    New-Item -ItemType SymbolicLink -Path $target -Target $_.FullName | Out-Null
    Write-Host "  Linked: $($_.Name)" -ForegroundColor Green
}

# --- Symlink commands ---
Write-Host "Linking commands..." -ForegroundColor Yellow
Get-ChildItem -Path "$ArmandoDir\commands\*.md" | ForEach-Object {
    $target = Join-Path $ClaudeCommandsDir $_.Name
    if (Test-Path $target) {
        $item = Get-Item $target
        if ($item.LinkType -eq "SymbolicLink") {
            Remove-Item $target
        } else {
            Write-Host "  WARNING: $target exists. Backing up to $target.bak" -ForegroundColor Red
            Move-Item $target "$target.bak"
        }
    }
    New-Item -ItemType SymbolicLink -Path $target -Target $_.FullName | Out-Null
    Write-Host "  Linked: $($_.Name)" -ForegroundColor Green
}

# --- Add armando command to PowerShell profile ---
if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
    Write-Host "Created PowerShell profile at: $PROFILE" -ForegroundColor Yellow
}

$profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
if ($profileContent -match "function armando") {
    Write-Host ""
    Write-Host "armando command already exists in PowerShell profile — skipping." -ForegroundColor Yellow
} else {
    $armandoFunc = @'

# Armando (The Gardener) — AI development team
function armando {
    # Activate Python venv if present
    if (Test-Path ".venv\Scripts\Activate.ps1") {
        & ".venv\Scripts\Activate.ps1"
    }
    claude --dangerously-skip-permissions --agent thorn
}
'@
    Add-Content -Path $PROFILE -Value $armandoFunc
    Write-Host ""
    Write-Host "Added armando command to PowerShell profile: $PROFILE" -ForegroundColor Green
}

Write-Host ""
Write-Host "Done. Restart PowerShell, then navigate to any project and type 'armando' to start." -ForegroundColor Cyan
