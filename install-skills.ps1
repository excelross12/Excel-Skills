<#
.SYNOPSIS
    Installs EXL Skills into a target project's .claude/ folder.

.PARAMETER Target
    Path to the target project. Defaults to the current directory.

.PARAMETER Components
    Comma-separated list of components to install: Skills, Agents, Hooks, Settings.
    Defaults to all four.

.PARAMETER Force
    Overwrite existing files without prompting.

.EXAMPLE
    .\install-skills.ps1 -Target "C:\Projects\MyApp"
    .\install-skills.ps1 -Target . -Components Skills,Agents
    .\install-skills.ps1 -Target "C:\Projects\MyApp" -Force
#>
param(
    [string]$Target = ".",
    [string[]]$Components = @("Skills", "Agents", "Hooks", "Settings"),
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Resolve paths
$Source = $PSScriptRoot
$SourceClaude = Join-Path $Source ".claude"
New-Item -ItemType Directory -Force -Path $Target | Out-Null
$TargetResolved = (Resolve-Path $Target).Path
$TargetClaude = Join-Path $TargetResolved ".claude"

Write-Host ""
Write-Host "EXL Skills Installer" -ForegroundColor Cyan
Write-Host "Source : $SourceClaude" -ForegroundColor DarkGray
Write-Host "Target : $TargetClaude" -ForegroundColor DarkGray
Write-Host "Install: $($Components -join ', ')" -ForegroundColor DarkGray
Write-Host ""

# Confirm if target already has .claude/ and not forced
if ((Test-Path $TargetClaude) -and -not $Force) {
    $reply = Read-Host "Target already has .claude/ - continue and merge? [y/N]"
    if ($reply -notmatch '^[Yy]') {
        Write-Host "Aborted." -ForegroundColor Yellow
        exit 0
    }
}

New-Item -ItemType Directory -Force -Path $TargetClaude | Out-Null

$installed = @()
$skipped = @()

# --- Skills ---
if ($Components -contains "Skills") {
    $src = Join-Path $SourceClaude "skills"
    $dst = Join-Path $TargetClaude "skills"
    if (Test-Path $src) {
        Copy-Item -Recurse -Force:$Force -Path $src -Destination $TargetClaude
        $count = (Get-ChildItem $dst -Directory).Count
        $installed += "Skills ($($count) skill directories)"
    } else {
        $skipped += "Skills (not found in source)"
    }
}

# --- Agents ---
if ($Components -contains "Agents") {
    $src = Join-Path $SourceClaude "agents"
    $dst = Join-Path $TargetClaude "agents"
    if (Test-Path $src) {
        Copy-Item -Recurse -Force:$Force -Path $src -Destination $TargetClaude
        $count = (Get-ChildItem $dst -Filter "*.md").Count
        $installed += "Agents ($($count) agent files)"
    } else {
        $skipped += "Agents (not found in source)"
    }
}

# --- Hooks (Python scripts) ---
if ($Components -contains "Hooks") {
    $src = Join-Path $SourceClaude "hooks"
    $dst = Join-Path $TargetClaude "hooks"
    if (Test-Path $src) {
        Copy-Item -Recurse -Force:$Force -Path $src -Destination $TargetClaude
        $count = (Get-ChildItem $dst -Filter "*.py").Count
        $installed += "Hooks ($($count) Python hook scripts)"
    } else {
        $skipped += "Hooks (not found in source)"
    }
}

# --- Settings (merge, don't overwrite) ---
if ($Components -contains "Settings") {
    $srcSettings = Join-Path $SourceClaude "settings.json"
    $dstSettings = Join-Path $TargetClaude "settings.json"

    if (-not (Test-Path $srcSettings)) {
        $skipped += "Settings (settings.json not found in source)"
    } elseif (-not (Test-Path $dstSettings)) {
        # No existing settings — just copy
        Copy-Item $srcSettings $dstSettings
        $installed += "Settings (copied fresh)"
    } else {
        # Merge: combine hook arrays, deduplicate by command string
        $srcJson = Get-Content $srcSettings -Raw | ConvertFrom-Json
        $dstJson = Get-Content $dstSettings -Raw | ConvertFrom-Json

        if (-not $dstJson.hooks) {
            $dstJson | Add-Member -MemberType NoteProperty -Name "hooks" -Value ([PSCustomObject]@{})
        }

        $hookEvents = @("SessionStart", "PreCompact", "PostToolUse", "UserPromptSubmit", "Stop")

        foreach ($event in $hookEvents) {
            $srcHooks = $srcJson.hooks.$event
            if (-not $srcHooks) { continue }

            $existing = $dstJson.hooks.$event
            if (-not $existing) {
                $dstJson.hooks | Add-Member -MemberType NoteProperty -Name $event -Value $srcHooks -Force
            } else {
                # Deduplicate: add source entries whose command doesn't already exist
                $existingCommands = $existing | ForEach-Object {
                    if ($_.command) { $_.command } elseif ($_.hooks) { $_.hooks.command }
                }
                foreach ($entry in $srcHooks) {
                    $entryCmd = if ($entry.command) { $entry.command } elseif ($entry.hooks) { $entry.hooks.command }
                    if ($existingCommands -notcontains $entryCmd) {
                        $existing += $entry
                    }
                }
                $dstJson.hooks | Add-Member -MemberType NoteProperty -Name $event -Value $existing -Force
            }
        }

        $dstJson | ConvertTo-Json -Depth 10 | Set-Content $dstSettings -Encoding utf8
        $installed += "Settings (merged into existing settings.json)"
    }
}

# --- Create .bmad/ state directory ---
$bmadDir = Join-Path $TargetResolved ".bmad"
if (-not (Test-Path $bmadDir)) {
    New-Item -ItemType Directory -Force -Path $bmadDir | Out-Null
    '{"phase":"analyst","story":null,"agent":null}' | Set-Content (Join-Path $bmadDir "state.json") -Encoding utf8
    '[]' | Set-Content (Join-Path $bmadDir "anchors.json") -Encoding utf8
    Write-Host "  Created .bmad/ state directory" -ForegroundColor DarkGray
}

# --- Summary ---
Write-Host "Installed:" -ForegroundColor Green
foreach ($item in $installed) { Write-Host "  + $item" -ForegroundColor Green }

if ($skipped.Count -gt 0) {
    Write-Host "Skipped:" -ForegroundColor Yellow
    foreach ($item in $skipped) { Write-Host "  - $item" -ForegroundColor Yellow }
}

Write-Host ""
Write-Host "Done. Open Claude Code in $TargetResolved to use the skills." -ForegroundColor Cyan
Write-Host ""
