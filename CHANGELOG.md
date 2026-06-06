# Changelog

All changes to this project are logged here in order.

## v1.4 (2026-06-05)
- FINAL FIX: ColorCorrection → ColorCorrectionEffect in SkyLobby.lua (was crashing build before any islands placed)
- FINAL FIX: Player teleport to SkyLobby spawn on join (was falling through void forever)
- FINAL FIX: Pipeline no longer overwrites fixes — copies from previous version instead of extracting from zip
- FAILSAFE: jeepers-remix.ps1 now auto-patches known bug patterns after every build
- FAILSAFE: Added fixup.ps1 detection for ColorCorrection, type annotations, absolute paths
- FIX: DexService, IndexService, QoLService — deduplicated Shared path lookups
- Cleaned up old version folders (v1.0–v1.3 removed, only v1.4 kept as seed)

## v1.1 (2026-06-05)
- CRITICAL FIX: Changed DuckModelBuilder.lua require from absolute ReplicatedStorage path to relative script.Parent path (was causing boot hang)
- CRITICAL FIX: Added missing Remotes require in Bootstrap.server.lua (was causing nil crash on GameReady)
- FIX: Removed 12 invalid Luau type annotations on property assignments across DuckGenerator, DuckSchema, ShopConfig, ZoneConfig
- FIX: Fixed Decor.lua waterfall particle self-parenting bug (em.Parent = em)
- FIX: Added nil guard on weightedPick() when pool is empty (DuckGenerator.lua)
- FIX: Added PlayerData guard on GameReady:FireClient() to avoid race condition
- FIX: Bootstrap - only fire GameReady if player data exists after wait loop
- All type annotation syntax error fixes verified - no remaining instances

## v1.0 (2026-06-05)
- Initial setup: SkyLobby visual revamp (clouds, waterfalls, barriers, ColorCorrectionEffect, particles)
- ZoneBuilder per-world road markings, mood-based decorations, barrier walls
- Terrain.lua helper module with invisible barriers, atmosphere tools
- Scripts reorganized into versioned release structure

## v1.2 (2026-06-05 11:33)
- Updated from zip: Jeepers-Get-DUCKED-OpenCode.zip

## v1.3 (2026-06-05 11:38)
- Updated from zip: Jeepers-Get-DUCKED-OpenCode.zip

## v1.4 (2026-06-05 11:45)
- Updated from zip: Jeepers-Get-DUCKED-OpenCode.zip

## v1.5 (2026-06-05 12:36)
- Version bump (copied from v1.4)
