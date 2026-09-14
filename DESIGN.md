# Oven Wars — Game Design (MVP)

## Pitch
Steal rare recipes and ingredients, bake them into cash and flex, upgrade your kitchen, raid rivals, defend your bakery. Proven steal-and-defend dopamine with an original food theme (not eggs/brainrot clones).

## Why this can trend
- Rides the #1 platform lane (sim / steal / collect hybrids)
- Differentiated skin + clear kid-friendly fantasy
- Short sessions, mobile-friendly, Mild maturity
- Obvious gamepasses and cosmetic flex

## Core loop (30–90 sec)
1. **Gather / Steal** — take ingredients or recipes from world nodes or another player's display case
2. **Bake** — queue a recipe; server timer; claim finished goods
3. **Sell / Flex** — sell for cash or display for prestige / steal bait
4. **Upgrade** — ovens (speed), shelves (storage), locks (security), whisk (luck/rarity)
5. **Raid / Defend** — enter another plot, steal displayed goods; others can steal yours

## MVP scope (v0.1)
### In
- Join → auto-assign bakery plot (hub + ring of placeholder plots)
- Catalog: 16 entries (6 ingredients, 5 recipes, 5 baked) across Common → Legendary
- Bake with server-authoritative timer (`GetServerTimeNow`)
- Sell baked goods / ingredients for cash
- Steal from another player's display (8s cooldown, rate limit, proximity)
- 4 upgrades: Oven Speed, Storage, Luck, Security (cash costs)
- HUD: cash, inventory (Bake/Sell/Display), bake queue, steal prompt, upgrade shop
- DataStore stub for cash + inventory + upgrades

### Out (later)
- Trading economy, trading plaza
- Seasonal events / limited recipes
- Full tycoon droppers
- Complex combat; keep steal as prompt + cooldown
- UGC clothing
- Luck affecting world drop tables (hook reserved on upgrade)

## Plots & map
- One hub plaza + ring of 8 bakery plots (`Constants.PLOT_COUNT`)
- Each plot: oven, counter/display case, upgrade board, spawn pad
- Placeholder Parts spawned in `PlotService` (no external map asset required)

## Catalog rarities (MVP)
| Tier | Examples | Bake time (base) | Sell (baked) |
|------|----------|------------------|--------------|
| Common | Flour, Crusty Roll | ~5s | ~20 |
| Uncommon | Sugar Dust, Butter Cookie | ~8s | ~45 |
| Rare | Cocoa Nibs, Sugar Bun | ~12s | ~80 |
| Epic | Moon Honey, Cocoa Loaf | ~25s | ~220 |
| Legendary | Star Yeast, Moon Cake | ~45s | ~550 |

## Economy (starting numbers — tune in playtest)
- Starter cash: 100
- Starter inventory: Flour×5, Butter×3, Crusty Roll + Butter Cookie recipes
- Steal cooldown: 8s personal; rate limit 3 requests / 2s
- Steal range: 12 studs to display case
- Security: ~8% block chance per level (cap 50%)
- Oven speed: −10% bake time per level (floor 50% time)

## Monetization
- Gamepasses: Faster Ovens, Extra Shelves, Lucky Whisk, Iron Lock
- Cosmetics: oven skins, apron, display neon, trail on successful legendary bake
- Dev products: cash packs (light), skip bake once

## Progression milestones
- First bake sold
- First successful steal
- Own a Rare recipe
- Max one upgrade branch
- Display a Legendary (flex moment)

## Anti-abuse (MVP)
- Server validates all inventory / cash mutations
- Steal range + owner checks; no self-steal
- Rate limits + cooldown on steal remotes
- No client-trusted prices or timers
- Gather limited to Common/Uncommon hub nodes

## Tech (Rojo)
- `ReplicatedStorage.Shared` — Catalog, Constants, Types, Remotes
- `ServerScriptService` — Main + Services (authoritative)
- `StarterPlayerScripts` — HUD, UpgradeShop, StealPrompt, ClientRemotes
- Sync with `rojo serve` + Studio plugin (see README)

## Success metrics to watch post-launch
- D1 retention, avg session length, steal attempts / session, % buyers of any pass
