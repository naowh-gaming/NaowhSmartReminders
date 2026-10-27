# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

The real surface is the World of Warcraft Retail in-game UI (Lua frames, textures and FontStrings), not a browser. `web` is the nearest value the schema allows; apply web guidance as design principles only.

## Users

Inferred from the repo, not yet confirmed: Retail players of every spec doing raids and Mythic+, who want to know what to press before a boss ability lands without reading timers themselves.

## Product Purpose

Naowh Smart Reminders "calls out what to press when the boss timeline says an ability is coming. All specs." It is free on CurseForge and Wago. Naowh's own profile is a subscriber perk, signed to the player's BattleTag and downloaded from naowh.gg.

## Positioning

"A new modern way to keep track of your cooldowns!" It only calls out abilities that are actually available: "It will never tell you to use a cooldown that is not available."

## Operating Context

- Opens with `/nsr` (also `/smartreminders`, `/naowh`, `/nao`) and from the addon compartment.
- Reads the boss timeline; integrates with BigWigs and DBM when present (optional dependencies).
- Packs from naowh.gg are signed and verified on import; older packs must be downloaded again after a key change.
- The NaowhUI installer can import Naowh's profile and put every character on the account on it.
- Supports per-spec profile switching and account-wide profile import.

## Capabilities and Constraints

- Callouts, raid reminders, notes, packs, and Call Together (shows every ready ability in the group side by side with one shared callout line; Hide After Casting dims each icon as it is pressed).
- Retail only (Interface 120000-120100).
- Localized: enUS, deDE, ruRU.
- Combat-time reads must survive secret values and combat lockdown.
- Changelog is player-facing prose (`CHANGELOG.md`).

## Brand Commitments

- Title `|cff0091edNaowh|r Smart Reminders`; Naowh Blue #0091ED.
- Icon `Media/LogoAddon.tga`; NaowhUI_Media optional.
- Voice: plain, player-facing, explains what changes for the player.

## Evidence on Hand

- CHANGELOG.md with full release history.
- No user counts, testimonials or press in this repo; do not fabricate them.

## Product Principles

1. Never call out something the player cannot press.
2. Read at a glance in combat.
3. Works for every spec out of the box.
4. Naowh's profile is the reference setup; the addon stays useful without it.

## Accessibility & Inclusion

No formal standard. Signals: Russian and German translations.
