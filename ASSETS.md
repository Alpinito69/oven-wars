# Oven Wars — Assets

Code builds a full **Parts-composed** bakery plaza (layout, lighting, VFX skeleton). Optional Studio mesh/Toolbox imports polish further — **do not paste unverified asset IDs into source**.

## Code-provided (no external IDs)

| Layer | What |
|-------|------|
| Hub plaza | Floor inlay, fountain/cake pedestal, market stalls (tables, awnings, crates, SurfaceGui signs), benches, planters |
| Plots (×8) | Floor pad, half-walls, fabric roof/awning, counter, glass display case, oven group + PointLight, upgrade board, spawn doormat, name signs, hedges/fences |
| Pathways | Cobblestone paths hub→plots, street lamps with PointLights, grass ring |
| Lighting | Warm Ambient / ClockTime / Bloom / ColorCorrection / Atmosphere / subtle DoF (see `LightingService`) |
| VFX | Steam + heat sparks while baking; claim sparkles; sell coin burst; steal smoke + highlight; legendary celebration |
| UI | Cozy panel chrome, emoji glyphs, upgrade cards with level pips |

Safe built-ins used: `rbxasset://textures/particles/smoke_main.dds`, Materials (`Wood`, `Fabric`, `Glass`, `Neon`, `SmoothPlastic`, `Grass`, `Cobblestone`, etc.).

## Studio imports

> Parent / art pass: merge researched Toolbox / mesh swaps here. Until then, leave this stub.

### Suggested replacements (import in Studio, re-parent under existing names)

| Placeholder | Suggested Studio import | Keep API name |
|-------------|-------------------------|---------------|
| `Oven` | Oven / stove mesh | **Must be a `BasePart` named `Oven`** (not a Model-only swap). `ProximityGuard` / bake remotes require `FindFirstChild("Oven"):IsA("BasePart")`. Set `IsOven`; keep `BakeLight`, `SteamAttachment`. Mesh can be a child of that part or use a MeshPart as the `Oven` itself. |
| `DisplayCase` glass | Glass cabinet mesh | BasePart named `DisplayCase` with `IsDisplayCase` + `StealPrompt` |
| Stall crates | Sack / barrel / crate meshes | Keep `IsGatherNode` + `GatherNodeId` + `GatherItemId` on the prompt-host **BasePart** |
| Fountain cake | Decorative cake mesh | Optional cosmetic only |
| Street lamps | Lamp post models | Keep `PointLight` child |
| Sky | Lighting → Sky / Toolbox sky | Document asset ID here when chosen |

### Naming contract (gameplay)

Scripts look up by **name / attribute**. When replacing meshes:

- Plot models: `Plot_1` … `Plot_8` under `Workspace.Plots`
- `OwnerUserId`, `DisplayItemId`, `BakeryName`, `PlotIndex` attributes on plot model
- `Oven` **must be a `BasePart`** (MeshPart OK) named `Oven` with `IsOven` — not a Model without a BasePart child of that name. Optional `BakeLight` PointLight + `SteamAttachment`. Required by `ProximityGuard.requireNearOwnedPlotPart(..., "Oven")`
- `DisplayCase` BasePart + `StealPrompt` + `StealAttachment`
- `Counter` + `SellAttachment` (sell VFX)
- `UpgradeBoard` with `IsUpgradeBoard`
- `Spawn` marker part
- Hub gather hosts (prompt-host **BasePart**): `IsGatherNode` + **`GatherNodeId`** (stable id, e.g. `FlourStall`) + `GatherItemId` — `GatherService` looks up by `GatherNodeId`

## Sprint 1 status (2026-09-14) — World Artist

- Synced to latest `main` (gather proximity + plot interact range merges).
- **Blocked on this machine:** Roblox Studio is not available on the World Artist Linux VM. No meshes were inserted in-place.
- **Prep done:** `STUDIO_IMPORT_CHECKLIST.md` + CC0 Tiny Treats pack links below. Creator Store stall/cake IDs remain **PENDING** Free/license re-check in Studio.

### Tiny Treats CC0 (preferred for Oven / DisplayCase / Counter / cake)

| Pack | Use for | Get it |
|------|---------|--------|
| Charming Kitchen | `stove.fbx` → Oven; countertops → Counter | https://github.com/TinyTreats-Game-Assets/Tiny-Treats-Charming-Kitchen-1.0 |
| Baked Goods | `cake_birthday.fbx` / `cake_chocolate.fbx` → fountain cake | https://github.com/TinyTreats-Game-Assets/Tiny-Treats-Baked-Goods-1.0 |
| Bakery Interior | display / interior polish | https://tinytreats.itch.io/bakery-interior (CC0) |

### Pending Studio verification (do **not** treat as Verified yet)

| Purpose | Candidate | Source | Status |
|---------|-----------|--------|--------|
| Oven mesh | Charming Kitchen `stove.fbx` | Tiny Treats GitHub CC0 | PENDING Studio import |
| Counter | Charming Kitchen `countertop_*.fbx` | Tiny Treats GitHub CC0 | PENDING Studio import |
| DisplayCase | Bakery Interior glass/cabinet | Tiny Treats itch CC0 | PENDING download + import |
| Fountain cake | `cake_birthday.fbx` (or Creator Store cakes below) | Tiny Treats / Creator Store | PENDING |
| Hub stall | Market Stall `5626984031` | Creator Store — re-verify Free | PENDING |
| Hub stall | Beverage Market Stall `17641160` | Creator Store — re-verify Free | PENDING |
| Hub stall alt | Shop Stand `128117050019864` | Creator Store — re-verify Free | PENDING |
| Fountain cake alt | Birthday Cake `570557430` | Creator Store — re-verify Free | PENDING |
| Fountain cake alt | Baking Cake `1842724735` | Creator Store — re-verify Free | PENDING |
| Fountain cake alt | Chocolate Birthday Cake `5470704206` | Creator Store — re-verify Free | PENDING |

### Exact Studio steps (Windows / Mac)

1. `aftman install && rojo serve` → Rojo plugin Sync into Studio
2. Download Tiny Treats Charming Kitchen + Baked Goods (GitHub) and Bakery Interior (itch)
3. **3D Importer**: `stove.fbx` → result must leave a **`BasePart` named `Oven`** on each plot (MeshPart OK); set `IsOven`; keep `BakeLight`, `SteamAttachment`
4. Import display mesh → `DisplayCase` + `IsDisplayCase` + `StealPrompt` + `StealAttachment`
5. Import countertop → `Counter` + `SellAttachment`
6. Insert Market/Beverage stall models on hub gather hosts; keep `IsGatherNode` + `GatherNodeId` + `GatherItemId` on the prompt-host BasePart; **strip ALL scripts**
7. Place cake on fountain pedestal (cosmetic only)
8. Playtest: gather → bake steam → claim → sell coins → steal poof
9. Move confirmed rows into **Verified IDs** below; open follow-up PR

---

## Verified IDs (fill after review)

| Purpose | Asset ID | Source / license note |
|---------|----------|------------------------|
| _(none yet)_ | — | Parent merges research here |

## Sky note

`LightingService` sets ClockTime, Atmosphere, Bloom, ColorCorrection, DepthOfField, SunRays. A custom **Sky** instance is best added in Studio (Toolbox) — Rojo code avoids unverified skybox texture IDs.

---

## Curated free / low-risk imports (research 2026-09-14)

Prefer **Creator Store / verified creators**. Re-check Free + license in Studio before publishing. **Never** insert random Toolbox models that ship unknown scripts — strip scripts or use mesh-only.

### Top bakery props (free / CC0)

| Asset | Notes | How to get |
|-------|--------|------------|
| Tiny Treats — Bakery Interior / Baked Goods / Charming Kitchen / Bakery Building | CC0 packs, great mesh swaps | Studio **3D Importer** / Tiny Treats CC0 |
| UpDraft free sampler | Free sampler props | Creator / UpDraft free sampler |
| Birthday Cake | Creator Store prop | Asset `570557430` — re-verify Free |
| Baking Cake | Creator Store | Asset `1842724735` |
| Chocolate Birthday Cake | Creator Store | Asset `5470704206` |
| Market Stall | Plaza / hub stalls | Asset `5626984031` |
| Beverage Market Stall | Hub variety | Asset `17641160` |
| Shop Stand | Stall alternative | Asset `128117050019864` |

### VFX

| Asset | Notes |
|-------|--------|
| Effect Designer Suite (plugin) | Free plugin `109890065116916` (iGottic) — design particles in Studio |
| DogmathPan Free VFX Pack | `8621531267` — audit before use |
| **Built-in (already in game)** | Steam / sparkle / coin / smoke / legendary bursts via `VFXService` |

### UI & audio

| Need | Guidance |
|------|----------|
| UI kit | Zxgly free cartoony `.rbxm` on itch — **audit scripts**; don’t redistribute |
| SFX | Toolbox **Audio** search: `oven ding`, `whoosh`, `cash register`, `bakery` — no hard-coded IDs in repo |

### Toolbox search terms

`bakery counter`, `display case glass`, `oven stove`, `market stall awning`, `cake pedestal`, `lamp post`, `hedge`, `cobblestone path`, `particle steam`, `confetti burst`

### Avoid

- Paid KW Studio kitchen kits (unless you buy them)
- Scripted “Cooking System” free models (backdoor / require risks)
- Random Toolbox kitchens with embedded scripts
- Blog dump lists of Sound IDs (often invalid or stolen)
- Anything that asks you to `require(assetId)` from an unknown author

### Suggested Studio workflow

1. `rojo serve` → sync code world first (already cozy)
2. Insert free meshes → re-parent under existing `Oven` / `DisplayCase` / stall names (see naming contract above)
3. Delete or disable any scripts that came with free models
4. Playtest gather → bake steam → sell coins → steal poof
5. Record final asset IDs in the “Verified IDs” table above
