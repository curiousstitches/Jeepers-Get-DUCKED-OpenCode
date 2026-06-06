# GO.ps1 — extract newest zip to Desktop\Ducky-1 → push to GitHub → start Rojo
$ErrorActionPreference = "Continue"
$dl   = "$env:USERPROFILE\Downloads"
$proj = "C:\Users\thego\Desktop\Ducky-1"
$repo = "https://github.com/curiousstitches/Jeepers-Get-DUCKED-OpenCode.git"
$rojo = "$env:USERPROFILE\Downloads\rojo\rojo.exe"

Write-Host "`n[1/3] Extracting newest zip to Desktop\Ducky-1..." -ForegroundColor Cyan
$zip = Get-ChildItem $dl -Filter "*.zip" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($zip) {
  Remove-Item "$proj\_tmp" -Recurse -Force -ErrorAction SilentlyContinue
  New-Item -ItemType Directory -Path $proj -Force | Out-Null
  Expand-Archive $zip.FullName "$proj\_tmp" -Force
  $src = Get-ChildItem "$proj\_tmp" -Recurse -Filter default.project.json | Select-Object -First 1
  if ($src) {
    Remove-Item "$proj\*" -Recurse -Force -ErrorAction SilentlyContinue
    Copy-Item "$($src.DirectoryName)\*" $proj -Recurse -Force
    Write-Host "    Updated from $($zip.Name)" -ForegroundColor Green
  } else { Write-Host "    Zip had no default.project.json - skipped." -ForegroundColor Yellow }
  Remove-Item "$proj\_tmp" -Recurse -Force -ErrorAction SilentlyContinue
} else { Write-Host "    No zip found - using existing files." -ForegroundColor Yellow }

Write-Host "`n[2/3] Pushing to OpenCode repo..." -ForegroundColor Cyan
Set-Location $proj
if (-not (Test-Path ".git")) { git init | Out-Null; git branch -M main }
git remote remove origin 2>$null; git remote add origin $repo
git add -A; git commit -m ("update " + (Get-Date -Format "yyyy-MM-dd HH:mm")) 2>$null
git push -u origin main --force
Write-Host "    Push attempted (see above)." -ForegroundColor Green

Write-Host "`n[3/3] Starting Rojo... leave this window OPEN." -ForegroundColor Cyan
if (-not (Test-Path $rojo)) {
  irm https://github.com/rojo-rbx/rojo/releases/download/v7.5.1/rojo-7.5.1-windows-x86_64.zip -OutFile "$dl\rojo.zip"
  Expand-Archive "$dl\rojo.zip" "$env:USERPROFILE\Downloads\rojo" -Force
}
Write-Host "`n  In Studio now: Rojo plugin -> Connect -> Play  `n" -ForegroundColor Yellow
& $rojo serve "$proj\default.project.json"

$colors = @("Red","Yellow","Green","Cyan","Blue","Magenta"); $i=0
1..20 | ForEach-Object { $c = $colors[($i++) % $colors.Length]; Write-Host "  __..  QUACK" -ForegroundColor $c }
Write-Host " .('    '." -ForegroundColor $colors[($i++) % $colors.Length]
Write-Host "/  _  ||" -ForegroundColor $colors[($i++) % $colors.Length]
Write-Host "' ||_/'" -ForegroundColor $colors[($i++) % $colors.Length]
Write-Host "   U U" -ForegroundColor $colors[($i++) % $colors.Length]
Write-Host "====================" -ForegroundColor White
Write-Host " ALL 20 QUACKS DONE " -ForegroundColor Green
Write-Host "====================" -ForegroundColor White
