# Jeepers-Get-DUCKED-OpenCode

A Roblox pet-collection game. This folder contains everything you need
to update, package, and push the project to GitHub.

## What's inside

| File / Folder | What it is |
|---|---|
| `Ducky-v1.0\` | The actual game code (unzipped, ready to edit) |
| `Ducky-v1.0.zip` | Same as above, but zipped for sharing or backup |
| `ducky-run.bat` | **Double-click this** to run the full pipeline |
| `jeepers-remix.ps1` | The pipeline script that does all the work |
| `version.txt` | Tracks the current version number (1.0, 1.1, 1.2...) |
| `CHANGELOG.md` | Running list of every change, in order |
| `README.md` | This file — explains everything |

## How it works

Every time you get a new `.zip` from the original game repo (put it in
your Downloads folder), double-click `ducky-run.bat`. It will:

1. Read the current version from `version.txt`
2. Bump it up by 0.1 (so 1.0 → 1.1 → 1.2)
3. Grab the newest zip from your Downloads and extract it
4. Save a fresh copy into `Ducky-v{new version}\`
5. Make a matching `Ducky-v{new version}.zip`
6. Write today's date and what happened into `CHANGELOG.md`
7. Push everything to GitHub (the zip, the folder, the changelog, everything)
8. Start Rojo so you can connect from Studio

Just let it run — the PowerShell window will show each step.

## Where things live

- **Local files**: `C:\Users\thego\Desktop\Ducky-1\`
- **GitHub repo**: `https://github.com/curiousstitches/Jeepers-Get-DUCKED-OpenCode`
- **Source zips**: Drop them in `~/Downloads/` — the script finds them automatically

## Going back to an old version

Each version is saved as both a folder and a zip. So v1.0's code is in
`Ducky-v1.0\` and `Ducky-v1.0.zip`. You can open any old folder
or unzip any old zip to get that exact state of the game.
