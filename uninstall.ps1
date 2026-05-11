<#
.SYNOPSIS
    Armando uninstall (Windows).

.DESCRIPTION
    Inverse of bootstrap.ps1 / install.ps1.

    Removes:
      1. Per file entries under $CLAUDE_CONFIG_DIR\agents\ and \commands\
         whose link target, or (for plain-copy fallbacks) byte content,
         resolves into this armando repo. Junctions, hardlinks, symlinks,
         and matching plain copies are removed. Anything else is left alone.
      2. The sentinel bracketed activation block from $PROFILE.CurrentUserAllHosts
         and $PROFILE.CurrentUserCurrentHost. Strips both
         '# >>> armando >>>' and '# >>> armando-portable >>>' blocks so the
         same script handles traditional and portable installs.
         A .armando-bak file is written next to each modified profile.
      3. The user-scope CLAUDE_CONFIG_DIR env var, but only when its current
         value points into the portable prefix being removed. If the user
         pointed it somewhere else, leave it.
      4. (Portable installs only.) The portable prefix at $env:ARMANDO_PORTABLE
         after prompting the user. Use -Yes to skip the prompt.

.PARAMETER Yes
    Do not prompt before removing the portable prefix.

.PARAMETER DryRun
    Report what would happen; touch nothing.

.NOTES
    Set-StrictMode Latest + $ErrorActionPreference='Stop'.
    Targets Windows PowerShell 5.1 and PowerShell 7+. No em dashes.
#>

[CmdletBinding()]
param(
    [switch]$Yes,
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Layout discovery
# ---------------------------------------------------------------------------

$ArmandoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ($env:ARMANDO_PORTABLE) {
    $ArmandoPortable = $env:ARMANDO_PORTABLE
}
else {
    $ArmandoPortable = Join-Path $env:USERPROFILE 'armando-portable'
}
if ($env:CLAUDE_CONFIG_DIR) {
    $ClaudeConfigDir = $env:CLAUDE_CONFIG_DIR
}
else {
    $ClaudeConfigDir = Join-Path $HOME '.claude'
}

function Write-Log {
    param([string]$Message)
    Write-Host "[armando] $Message"
}
function Write-WarnLog {
    param([string]$Message)
    Write-Host "[armando] WARN: $Message" -ForegroundColor Yellow
}

Write-Log "armando repo : $ArmandoDir"
Write-Log "portable     : $ArmandoPortable"
Write-Log "CLAUDE_CONFIG_DIR: $ClaudeConfigDir"
if ($DryRun) { Write-Log 'DRY RUN: no disk writes.' }

# ---------------------------------------------------------------------------
# 1. Per file link / copy removal under agents and commands
# ---------------------------------------------------------------------------

function Resolve-LinkTarget {
    param([System.IO.FileSystemInfo]$Item)
    # PowerShell 5.1+ exposes Target on reparse points. Junctions and symlinks
    # both report a Target. Hardlinks do not (same inode on NTFS), so the
    # caller must fall back to content comparison.
    try {
        if ($null -ne $Item.Target -and $Item.Target.Count -gt 0) {
            return [string]$Item.Target[0]
        }
    } catch { }
    return $null
}

function Test-PathInsideArmando {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) { return $false }
    try {
        $resolved = (Resolve-Path -LiteralPath $Path -ErrorAction Stop).ProviderPath
    } catch {
        $resolved = $Path
    }
    $root = (Resolve-Path -LiteralPath $ArmandoDir).ProviderPath
    return $resolved.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)
}

function Get-FileSha256Lower {
    param([string]$Path)
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Remove-ArmandoEntries {
    param(
        [string]$TargetDir,
        [string]$SourceDir
    )
    if (-not (Test-Path -LiteralPath $TargetDir)) {
        Write-Log "$TargetDir not present; skipping."
        return
    }
    if (-not (Test-Path -LiteralPath $SourceDir)) {
        Write-WarnLog "source $SourceDir not present; cannot content-compare copies."
    }

    $removed = 0
    $kept = 0

    Get-ChildItem -LiteralPath $TargetDir -Force -ErrorAction SilentlyContinue | ForEach-Object {
        $item = $_
        $shouldRemove = $false

        # Reparse point? (symlink, junction)
        $isReparse = $false
        try {
            $isReparse = ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -eq [IO.FileAttributes]::ReparsePoint
        } catch { }

        if ($isReparse) {
            $linkTarget = Resolve-LinkTarget -Item $item
            if ($null -ne $linkTarget -and (Test-PathInsideArmando -Path $linkTarget)) {
                $shouldRemove = $true
            }
        }
        elseif ($item.PSIsContainer) {
            # Plain directory under agents/commands is not something we created.
            $shouldRemove = $false
        }
        else {
            # Plain file: could be a hardlink (no Target) or a copy. Compare
            # against same-named source.
            if (Test-Path -LiteralPath $SourceDir) {
                $sourceFile = Join-Path $SourceDir $item.Name
                if (Test-Path -LiteralPath $sourceFile) {
                    try {
                        $a = Get-FileSha256Lower -Path $item.FullName
                        $b = Get-FileSha256Lower -Path $sourceFile
                        if ($a -eq $b) { $shouldRemove = $true }
                    } catch { }
                }
            }
        }

        if ($shouldRemove) {
            if ($DryRun) {
                Write-Log "DRY-RUN: would remove $($item.FullName)"
            }
            else {
                try {
                    Remove-Item -LiteralPath $item.FullName -Force -Recurse -ErrorAction Stop
                    Write-Log "Removed: $($item.FullName)"
                } catch {
                    Write-WarnLog "could not remove $($item.FullName): $($_.Exception.Message)"
                }
            }
            $removed++
        }
        else {
            $kept++
        }
    }

    Write-Log "$TargetDir: removed $removed armando entr(ies), preserved $kept other entr(ies)."
}

Write-Log "Scanning $ClaudeConfigDir for armando entries (repo: $ArmandoDir)..."
$AgentsTarget   = Join-Path $ClaudeConfigDir 'agents'
$CommandsTarget = Join-Path $ClaudeConfigDir 'commands'
$AgentsSource   = Join-Path $ArmandoDir 'agents'
$CommandsSource = Join-Path $ArmandoDir 'commands'

Remove-ArmandoEntries -TargetDir $AgentsTarget   -SourceDir $AgentsSource
Remove-ArmandoEntries -TargetDir $CommandsTarget -SourceDir $CommandsSource

# ---------------------------------------------------------------------------
# 2. Strip sentinel block(s) from $PROFILE variants
# ---------------------------------------------------------------------------

function Remove-SentinelBlock {
    param([string]$ProfilePath)

    if ([string]::IsNullOrWhiteSpace($ProfilePath)) { return }
    if (-not (Test-Path -LiteralPath $ProfilePath)) {
        Write-Log "$ProfilePath not present; skipping."
        return
    }

    $lines = Get-Content -LiteralPath $ProfilePath -ErrorAction Stop
    if ($null -eq $lines) { return }

    $hasBlock = $false
    foreach ($line in $lines) {
        if ($line -match '^# >>> armando(-portable)? >>>\s*$') { $hasBlock = $true; break }
    }
    if (-not $hasBlock) {
        Write-Log "$ProfilePath: no armando block, skipping."
        return
    }

    if ($DryRun) {
        Write-Log "DRY-RUN: would strip armando sentinel block from $ProfilePath"
        return
    }

    $out = New-Object System.Collections.Generic.List[string]
    $skip = $false
    foreach ($line in $lines) {
        if ($line -match '^# >>> armando(-portable)? >>>\s*$') { $skip = $true; continue }
        if ($line -match '^# <<< armando(-portable)? <<<\s*$') { $skip = $false; continue }
        if (-not $skip) { $out.Add($line) | Out-Null }
    }

    $backup = "$ProfilePath.armando-bak"
    Copy-Item -LiteralPath $ProfilePath -Destination $backup -Force
    Set-Content -LiteralPath $ProfilePath -Value $out
    Write-Log "Stripped armando block from $ProfilePath (backup at $backup)"
}

foreach ($p in @($PROFILE.CurrentUserAllHosts, $PROFILE.CurrentUserCurrentHost)) {
    Remove-SentinelBlock -ProfilePath $p
}

# ---------------------------------------------------------------------------
# 3. Clear user-scope CLAUDE_CONFIG_DIR if it points into the prefix
# ---------------------------------------------------------------------------

try {
    $userClaudeConfigDir = [Environment]::GetEnvironmentVariable('CLAUDE_CONFIG_DIR', 'User')
}
catch {
    $userClaudeConfigDir = $null
}

if (-not [string]::IsNullOrWhiteSpace($userClaudeConfigDir)) {
    $portableRoot = $null
    try {
        if (Test-Path -LiteralPath $ArmandoPortable) {
            $portableRoot = (Resolve-Path -LiteralPath $ArmandoPortable).ProviderPath
        }
    } catch { }

    $configResolved = $userClaudeConfigDir
    try {
        if (Test-Path -LiteralPath $userClaudeConfigDir) {
            $configResolved = (Resolve-Path -LiteralPath $userClaudeConfigDir).ProviderPath
        }
    } catch { }

    if ($null -ne $portableRoot -and $configResolved.StartsWith($portableRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        if ($DryRun) {
            Write-Log "DRY-RUN: would clear user-scope CLAUDE_CONFIG_DIR (currently $userClaudeConfigDir)"
        }
        else {
            try {
                [Environment]::SetEnvironmentVariable('CLAUDE_CONFIG_DIR', $null, 'User')
                Write-Log 'Cleared user-scope CLAUDE_CONFIG_DIR.'
            }
            catch {
                Write-WarnLog "failed to clear user CLAUDE_CONFIG_DIR: $($_.Exception.Message)"
            }
        }
    }
    else {
        Write-Log "Leaving user CLAUDE_CONFIG_DIR alone (points outside portable prefix: $userClaudeConfigDir)"
    }
}

# ---------------------------------------------------------------------------
# 4. Portable prefix removal (only when running from inside it)
# ---------------------------------------------------------------------------

$insidePortable = $false
try {
    $resolvedRepo = (Resolve-Path -LiteralPath $ArmandoDir).ProviderPath
    $expected     = $null
    if (Test-Path -LiteralPath $ArmandoPortable) {
        $expected = Join-Path ((Resolve-Path -LiteralPath $ArmandoPortable).ProviderPath) 'armando'
    }
    if ($null -ne $expected -and $resolvedRepo.TrimEnd('\') -ieq $expected.TrimEnd('\')) {
        $insidePortable = $true
    }
} catch { }

if ($insidePortable) {
    Write-Log "Detected portable install (repo lives at $ArmandoDir)."
    if ($DryRun) {
        Write-Log "DRY-RUN: would Remove-Item -Recurse $ArmandoPortable"
    }
    else {
        $proceed = $Yes.IsPresent
        if (-not $proceed) {
            $reply = Read-Host "[armando] Remove entire portable prefix at $ArmandoPortable ? [y/N]"
            if ($reply -match '^(y|Y|yes|YES)$') { $proceed = $true }
        }
        if (-not $proceed) {
            Write-Log 'Skipped prefix removal. Re-run with -Yes to force.'
        }
        else {
            $bad = @('', '/', '\', $HOME, $env:USERPROFILE, "$env:SystemDrive\")
            $portableTrim = $ArmandoPortable.TrimEnd('\','/')
            $badMatch = $false
            foreach ($b in $bad) {
                if ($null -ne $b -and $portableTrim -ieq $b.TrimEnd('\','/')) { $badMatch = $true; break }
            }
            if ($badMatch) {
                Write-WarnLog "refusing to Remove-Item -Recurse $ArmandoPortable"
                exit 1
            }
            try {
                Remove-Item -LiteralPath $ArmandoPortable -Recurse -Force -ErrorAction Stop
                Write-Log "Removed $ArmandoPortable"
            }
            catch {
                Write-WarnLog "Remove-Item failed: $($_.Exception.Message)"
            }
        }
    }
}
else {
    Write-Log "Traditional install detected; leaving $ArmandoDir in place."
}

Write-Log 'Uninstall complete.'
