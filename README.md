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

1. **Join** — auto-assigned a bakery plot (hub at origin, plots in a ring)
2. **Gather** — walk to hub Flour / Butter / Sugar nodes → ProximityPrompt
3. **Bake** — HUD inventory → **Bake** on a recipe (needs ingredients)
4. **Claim** — when oven timer finishes → **Claim Bake**
5. **Sell** — **Sell** on a baked good for cash
6. **Display** — **Display** a baked good on your case (steal bait / flex)
7. **Steal** — walk to another player's **Display Case** → Steal prompt (~8s cooldown)
8. **Upgrade** — your plot **Upgrade Board** (or press **U**) → spend cash on speed/storage/luck/security

## Project layout

```
oven-wars/
├── aftman.toml              # pins rojo
├── default.project.json     # Rojo tree → Roblox services
├── DESIGN.md                # GDD
├── README.md
└── src/
    ├── ReplicatedStorage/Shared/
    │   ├── Catalog.luau     # items Common→Legendary
    │   ├── Constants.luau
    │   ├── Remotes.luau
    │   └── Types.luau
    ├── ServerScriptService/
    │   ├── Main.server.luau
    │   └── Services/        # Plot, Inventory, Bake, Steal, Economy, Upgrade, DataStore
    └── StarterPlayer/StarterPlayerScripts/
        ├── ClientRemotes.client.luau
        ├── HUD.client.luau
        ├── StealPrompt.client.luau
        └── UpgradeShop.client.luau
```

## Design notes

- **Server-authoritative** cash, inventory, bake timers, steals, upgrades
- Plots / hub / oven / display / upgrade board are **placeholder Parts** spawned by `PlotService`
- DataStore is a **stub** with memory fallback for Studio offline
- See `DESIGN.md` for economy, monetization, and MVP scope

## Assumptions

- Single server / ~8 plots for MVP (`Constants.PLOT_COUNT`)
- One active bake job per player
- Hub gathers only Common/Uncommon ingredients
- Steal validates distance to target display case; security upgrade can block
- No GitHub push from this scaffold — wire remotes/CI separately

## License / IP

Original Oven Wars concept for this scaffold. Do not copy names, assets, or UI from existing Roblox hits.
