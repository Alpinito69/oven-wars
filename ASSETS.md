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
| `Oven` part group | Oven / stove mesh | Part or PrimaryPart named `Oven` with `IsOven` |
| `DisplayCase` glass | Glass cabinet mesh | BasePart named `DisplayCase` with `IsDisplayCase` + `StealPrompt` |
| Stall crates | Sack / barrel / crate meshes | Keep `IsGatherNode` + `GatherItemId` on prompt host |
| Fountain cake | Decorative cake mesh | Optional cosmetic only |
| Street lamps | Lamp post models | Keep `PointLight` child |
| Sky | Lighting → Sky / Toolbox sky | Document asset ID here when chosen |

### Naming contract (gameplay)

Scripts look up by **name / attribute**. When replacing meshes:

- Plot models: `Plot_1` … `Plot_8` under `Workspace.Plots`
- `OwnerUserId`, `DisplayItemId`, `BakeryName`, `PlotIndex` attributes on plot model
- `Oven` BasePart + optional `BakeLight` PointLight + `SteamAttachment`
- `DisplayCase` BasePart + `StealPrompt` + `StealAttachment`
- `Counter` + `SellAttachment` (sell VFX)
- `UpgradeBoard` with `IsUpgradeBoard`
- `Spawn` marker part
- Hub gather hosts: `IsGatherNode` + `GatherItemId`

### Verified IDs (fill after review)

| Purpose | Asset ID | Source / license note |
|---------|----------|------------------------|
| _(none yet)_ | — | Parent merges research here |

## Sky note

`LightingService` sets ClockTime, Atmosphere, Bloom, ColorCorrection, DepthOfField, SunRays. A custom **Sky** instance is best added in Studio (Toolbox) — Rojo code avoids unverified skybox texture IDs.
