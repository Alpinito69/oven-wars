# Oven Wars — Studio import checklist (Sprint 1)

Prefer free / verified Creator Store + **Tiny Treats CC0**. Re-check Free + license in Studio before publish.

**Source:** `ASSETS.md` (research 2026-09-14).

---

## Preflight

- [ ] `rojo serve` → sync so code plaza exists (`Hub`, `Plots`, `LightingHelpers`)
- [ ] Play once on Parts world (baseline cozy look)
- [ ] Confirm no unverified asset IDs committed to Luau source

## Priority mesh targets

| Order | Placeholder | Suggested import | Keep API |
|------:|-------------|------------------|----------|
| 1 | Plot `Oven` group | Tiny Treats Charming Kitchen `stove.fbx` (CC0) / Bakery Interior oven | Part or PrimaryPart named `Oven` + `IsOven`; keep `BakeLight`, `SteamAttachment` |
| 2 | `DisplayCase` | Glass cabinet / Tiny Treats Bakery Interior display | BasePart `DisplayCase` + `IsDisplayCase` + `StealPrompt` + `StealAttachment` |
| 3 | `Counter` | Tiny Treats countertop FBX | Keep `Counter` + `SellAttachment` |
| 4 | Fountain cake | Tiny Treats Baked Goods `cake_birthday.fbx` / Creator Store cakes (re-verify Free) | Cosmetic only; pedestal stay |
| 5 | Hub stalls | Market Stall `5626984031`, Beverage Market Stall `17641160`, Shop Stand `128117050019864` | Keep gather hosts: `IsGatherNode` + `GatherItemId` |
| 6 | Stall crates / barrels | Tiny Treats / UpDraft free sampler | Same gather attrs on prompt host |
| 7 | Street lamps | Lamp post models | Keep child `PointLight` |
| 8 | Sky | Lighting → Sky / Toolbox sky | Document ID in ASSETS Verified IDs when chosen |

Optional later: hedges, cobble path meshes (search terms in `ASSETS.md`).

## Safety (every insert)

- [ ] Prefer mesh-only / strip all Scripts, LocalScripts, ModuleScripts from free models
- [ ] Reject anything with `require(assetId)` from unknown authors
- [ ] Avoid scripted “Cooking System” free models and random Toolbox kitchens
- [ ] Avoid paid KW kits unless purchased; no blog Sound ID dumps

## Naming contract (gameplay must not break)

- Plots: `Plot_1` … `Plot_8` under `Workspace.Plots`
- Plot attrs: `OwnerUserId`, `DisplayItemId`, `BakeryName`, `PlotIndex`
- `Oven` + optional `BakeLight` + `SteamAttachment`
- `DisplayCase` + `StealPrompt` + `StealAttachment`
- `Counter` + `SellAttachment`
- `UpgradeBoard` with `IsUpgradeBoard`
- `Spawn` marker part

## After each swap

- [ ] Re-parent under existing names (don’t rename API parts away)
- [ ] Playtest: gather → bake steam → claim → sell coins → steal poof
- [ ] Record final Asset IDs + license note in `ASSETS.md` → Verified IDs table

## Out of scope for first import pass

- Hard-coding Sound IDs in repo
- Replacing built-in `VFXService` particles (already shipping)
- UI kit / itch `.rbxm` until scripts audited

## Agent note (2026-09-14)

Roblox Studio is **not** available on the World Artist Linux VM. Docs + CC0 pack links are prepared; actual Insert / 3D Importer / strip-scripts / playtest must run on Windows or Mac Studio.
