# REMIX.ps1 — copy from PREVIOUS version → push → start Rojo serving from versioned folder
$ErrorActionPreference = "Continue"
$proj = "C:\Users\thego\Desktop\Ducky-1"
$repo = "https://github.com/curiousstitches/Jeepers-Get-DUCKED-OpenCode.git"
$rojo = "$env:USERPROFILE\Downloads\rojo\rojo.exe"

# find the latest version folder (Ducky-vX.Y)
$versionDirs = Get-ChildItem $proj -Directory -Filter "Ducky-v*" | Sort-Object Name -Descending
if (-not $versionDirs) {
    Write-Host "No version folder found. Create Ducky-v1.0 first." -ForegroundColor Red
    exit 1
}
$latest = $versionDirs[0].FullName
$version = $versionDirs[0].Name
Write-Host "[1/3] Copying from $version to working root..." -ForegroundColor Cyan

# copy everything from the version folder to the project root (except .git)
Remove-Item "$proj\*" -Recurse -Force -ErrorAction SilentlyContinue
Get-ChildItem $latest -Exclude ".git" | ForEach-Object {
    Copy-Item $_.FullName "$proj\" -Recurse -Force
}
Write-Host "    Copied $version to $proj" -ForegroundColor Green

# ---- FAILSAFE: auto-patch known bug patterns ----
Write-Host "    Running failsafe patches..." -ForegroundColor Cyan
$srcPath = "$proj\src"

# 1) ColorCorrection -> ColorCorrectionEffect (line 37 of SkyLobby.lua)
$skyLobby = "$srcPath\server\SkyLobby.lua"
if (Test-Path $skyLobby) {
    (Get-Content $skyLobby) -replace '\bColorCorrection\b(?!Effect)', 'ColorCorrectionEffect' | Set-Content $skyLobby
}

# 2) type annotation fix: 'local var' -> 'local' on assignments (Luau doesn't allow `local var: Type = val`)
$allLua = Get-ChildItem $srcPath -Recurse -Filter "*.lua"
foreach ($f in $allLua) {
    $lines = Get-Content $f.FullName
    $changed = $false
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $lines[$i] = [regex]::Replace($lines[$i], '\blocal var\b', 'local')
        if ($lines[$i] -match '\blocal\s+\w+\s*:\s*\w+\s*=\s*Instance\.new') {
            $changed = $true
        }
    }
    if ($changed) { Set-Content $f.FullName $lines }
}

# 3) fix absolute paths like ReplicatedStorage.Shared.DuckModelBuilder -> relative require
foreach ($f in $allLua) {
    $text = [System.IO.File]::ReadAllText($f.FullName)
    $text = $text -replace 'ReplicatedStorage\.Shared\.(\w+)', 'script.Parent.$1'
    [System.IO.File]::WriteAllText($f.FullName, $text)
}

Write-Host "    Failsafe complete." -ForegroundColor Green
# ---- END FAILSAFE ----

Write-Host "[2/3] Pushing to OpenCode repo..." -ForegroundColor Cyan
Set-Location $proj
if (-not (Test-Path ".git")) { git init | Out-Null; git branch -M main }
git remote remove origin 2>$null
git remote add origin $repo
git add -A
git commit -m ("update $version " + (Get-Date -Format "yyyy-MM-dd HH:mm")) 2>$null
git push -u origin main --force
Write-Host "    Push attempted (see above)." -ForegroundColor Green

Write-Host "[3/3] Starting Rojo... leave this window OPEN." -ForegroundColor Cyan
if (-not (Test-Path $rojo)) {
    Write-Host "    Rojo not found - installing..." -ForegroundColor Yellow
    irm https://github.com/rojo-rbx/rojo/releases/download/v7.5.1/rojo-7.5.1-windows-x86_64.zip -OutFile "$env:USERPROFILE\Downloads\rojo.zip"
    Expand-Archive "$env:USERPROFILE\Downloads\rojo.zip" "$env:USERPROFILE\Downloads\rojo" -Force
}
Write-Host "`n  In Studio now: Rojo plugin -> Connect -> Play  `n" -ForegroundColor Yellow
& $rojo serve "$proj\default.project.json"

# ---- RAINBOW DUCK ----
$colors = @("Red","Yellow","Green","Cyan","Blue","Magenta"); $i=0
1..20 | ForEach-Object { $c = $colors[($i++) % $colors.Length]; Write-Host "  __..  QUACK" -ForegroundColor $c }
Write-Host " .('    '." -ForegroundColor $colors[($i++) % $colors.Length]
Write-Host "/  _  ||" -ForegroundColor $colors[($i++) % $colors.Length]
Write-Host "' ||_/'" -ForegroundColor $colors[($i++) % $colors.Length]
Write-Host "   U U" -ForegroundColor $colors[($i++) % $colors.Length]
Write-Host "====================" -ForegroundColor White
Write-Host " ALL 20 QUACKS DONE " -ForegroundColor Green
Write-Host "====================" -ForegroundColor White
