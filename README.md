# Oven Wars (Rojo + Luau MVP)

Steal-and-defend lite bakery sim. Gather or steal ingredients/recipes, bake on a server timer, sell or flex on your display case, upgrade your kitchen, raid rivals.

> Not a Steal An Egg / brainrot clone — original bakery theme and systems.

## Prerequisites

- [Roblox Studio](https://create.roblox.com/)
- [Aftman](https://github.com/LPGhatguy/aftman) (recommended) **or** a local [Rojo](https://rojo.space/) 7.4+ install
- Rojo Studio plugin matching your Rojo CLI version

## Setup

```bash
cd oven-wars
aftman install          # installs rojo 7.4.4 from aftman.toml
rojo serve              # default http://localhost:34872
```

In Roblox Studio:

1. File → New (or open an empty baseplate)
2. Install/open the **Rojo** plugin → **Connect** → use the port from `rojo serve`
3. Click **Sync** / connect so `src/` maps into the DataModel
4. Press **Play** (server + client)

### One-shot place file (optional)

```bash
rojo build -o OvenWars.rbxlx
# then open OvenWars.rbxlx in Studio
```

## Playtest loop (MVP click-through)

1. **Join** — auto-assigned a bakery plot (hub plaza, 8 distinct bakeries in a ring)
2. **Gather** — walk to hub market stalls (Flour / Butter / Sugar) → ProximityPrompt
3. **Bake** — HUD pantry → **Bake** on a recipe (needs ingredients); watch oven steam + glow
4. **Claim** — when oven timer finishes → **Claim Bake** (sparkle VFX; bigger burst if Legendary)
5. **Sell** — **Sell** on a baked good for cash (coin burst at counter)
6. **Display** — **Show** a baked good on your glass case (steal bait / flex)
7. **Steal** — walk to another player's **Display Case** → Steal prompt (~8s cooldown; poof VFX)
8. **Upgrade** — your plot **Upgrade Board** (or press **U**) → card shop with owned levels

## World & visuals

Code spawns a readable **cozy bakery plaza** (no greybox-only map):

| Folder | Contents |
|--------|----------|
| `Workspace.Hub` | Plaza floor, fountain/cake pedestal, 3 market stalls (awnings, crates, signs), benches, planters |
| `Workspace.Plots` | 8 bakeries — floor, half-walls, roof, oven, glass case, counter, upgrade board, spawn, name signs, hedges; per-plot accent colors |
| `Workspace.LightingHelpers` | Pathways, street lamps (`PointLight`), grass ring |

- **Lighting** (`LightingService`): warm Ambient/OutdoorAmbient, golden-hour `ClockTime`, Bloom, warm ColorCorrection, Atmosphere haze, subtle DepthOfField
- **VFX** (`VFXService`): bake steam, claim sparkles, sell coins, steal poof + highlight, legendary celebration — server-spawned for fairness
- **UI**: warmer rounded panels, emoji glyphs, themed steal prompt, upgrade cards with level pips

**Mesh / Toolbox assets** are imported in Studio; Luau provides layout + VFX skeleton. See `ASSETS.md` for naming contracts and a Studio-imports stub (parent merges research there). Do not commit unverified asset IDs.

### How to see the polish in Studio

1. `rojo serve` → Sync → Play
2. Look around the hub fountain and stalls; follow a cobblestone path to your colored bakery
3. Bake a recipe → oven window glows + steam; claim → sparkles
4. Sell → yellow particle burst on counter; steal a rival display → smoke + red flash
5. Press **U** for the card-style upgrade shop

## Project layout

```
oven-wars/
├── aftman.toml
├── default.project.json
├── DESIGN.md
├── ASSETS.md                # Studio imports stub + naming contract
├── README.md
└── src/
    ├── ReplicatedStorage/Shared/
    │   ├── Catalog.luau
    │   ├── Constants.luau
    │   ├── Remotes.luau
    │   ├── Theme.luau       # bakery palette + plot accents
    │   └── Types.luau
    ├── ServerScriptService/
    │   ├── Main.server.luau
    │   └── Services/
    │       ├── WorldBuilder.luau
    │       ├── PlotService.luau
    │       ├── LightingService.luau
    │       ├── VFXService.luau
    │       ├── Bake / Steal / Economy / Upgrade / Inventory / DataStore…
    └── StarterPlayer/StarterPlayerScripts/
        ├── ClientRemotes.client.luau
        ├── HUD.client.luau
        ├── StealPrompt.client.luau
        └── UpgradeShop.client.luau
```

## Design notes

- **Server-authoritative** cash, inventory, bake timers, steals, upgrades
- World is **Parts composition** from `WorldBuilder` / `PlotService` (replaceable with Studio meshes)
- DataStore is a **stub** with memory fallback for Studio offline
- See `DESIGN.md` for economy, monetization, and MVP scope

## Assumptions

- Single server / ~8 plots for MVP (`Constants.PLOT_COUNT`)
- One active bake job per player
- Hub gathers only Common/Uncommon ingredients
- Steal validates distance to target display case; security upgrade can block
- No GitHub push from visual polish work — parent handles remote push

## License / IP

Original Oven Wars concept for this scaffold. Do not copy names, assets, or UI from existing Roblox hits.
