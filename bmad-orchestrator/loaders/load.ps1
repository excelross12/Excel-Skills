# load.ps1 — One-click loader for Windows (PowerShell)
# Usage:
#   .\load.ps1                         # interactive
#   .\load.ps1 -Ide cursor             # direct
#   .\load.ps1 -Auto                   # auto-detect
#   .\load.ps1 -List                   # list IDEs
#   .\load.ps1 -AddIde <name>          # scaffold new IDE template
#   .\load.ps1 -Target <path>          # target project dir

param(
    [string]$Ide,
    [switch]$Auto,
    [switch]$List,
    [string]$AddIde,
    [string]$Target = (Get-Location).Path
)

$ErrorActionPreference = "Stop"
$ScriptDir = $PSScriptRoot
$LoaderPy = Join-Path $ScriptDir "load.py"

if (-not (Test-Path $LoaderPy)) {
    Write-Error "load.py not found at $LoaderPy"
    exit 1
}

# Find Python (prefer python3, then python, then py launcher)
$PyCmd = $null
foreach ($candidate in @("python3", "python", "py")) {
    if (Get-Command $candidate -ErrorAction SilentlyContinue) {
        $PyCmd = $candidate
        break
    }
}
if (-not $PyCmd) {
    Write-Error "Python not found. Install Python 3.10+ from python.org and re-run."
    exit 1
}

# Build args
$pyArgs = @($LoaderPy)
if ($List)              { $pyArgs += "--list" }
if ($AddIde)            { $pyArgs += @("--add-ide", $AddIde) }
if ($Ide)               { $pyArgs += @("--ide", $Ide) }
if ($Auto)              { $pyArgs += "--auto" }
if ($Target)            { $pyArgs += @("--target", $Target) }

& $PyCmd @pyArgs
exit $LASTEXITCODE
