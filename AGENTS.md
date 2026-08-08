# AGENTS.md — Sky Vanguard

## Project Identity

Project name: **Sky Vanguard**

Sky Vanguard is an Android-first, portrait-oriented, endless vertical shooting game built in **Godot 4.x** using **GDScript**.

This project must be built carefully, one verified phase at a time.

---

## Primary Development Rules

1. Use Godot 4.x.
2. Use GDScript.
3. Treat Android as the primary platform.
4. Treat portrait orientation as the primary screen format.
5. Treat touch/drag movement as the primary control method.
6. Build one approved phase at a time.
7. Do not skip ahead.
8. Do not add unapproved features.
9. Do not add monetization during the prototype.
10. Do not add online systems during the prototype.
11. Do not add login, cloud save, leaderboard, analytics, or accounts during the prototype.
12. Do not add gacha, loot boxes, energy systems, pay-to-win upgrades, or manipulative monetization.
13. Prioritize readability, responsiveness, and Android performance over spectacle.
14. Keep systems modular and easy to review.
15. Stop after completing the requested phase.

---

## Required Project Documents

Before implementing any phase, read the documents in `/docs/`:

```text
/docs/PROJECT_CONSTITUTION.md
/docs/LEAN_GDD.md
/docs/TECHNICAL_DESIGN_DOCUMENT_INDEX.md
/docs/IMPLEMENTATION_PHASES.md
```

If the user prompt conflicts with these files, report the conflict before proceeding.

If something is unclear, make the safest minimal implementation that matches the approved current phase and document the assumption.

---

## Current Implementation Roadmap

Build in this order unless the product owner approves a change:

```text
Phase 0 — Project Setup & Technical Baseline
Phase 1 — Core Scene Architecture & Game State Flow
Phase 2 — Player Controller & Touch Movement
Phase 3 — Weapon System, Basic Blaster & Projectiles
Phase 4 — Basic Enemy, Damage & Score Loop
Phase 5 — Shooter Enemy & Enemy Projectiles
Phase 6 — Weapon Pickups & Spread Shot Replacement
Phase 7 — Temporary Shield Booster
Phase 8 — DropCarrier Enemy & Pickup Drops
Phase 9 — Seeker Enemy & Homing Missile
Phase 10 — Spawn/Wave Progression
Phase 11 — HUD, Pause & Game Over UI
Phase 12 — Save Data & Settings
Phase 13 — Game Feel, Audio & Feedback Hooks
Phase 14 — Android Export & Device Testing
Phase 15 — Prototype Stabilization & Bug Fixing
Phase 16 — Version 1.0 Expansion Planning
```

---

## Current Phase Rule

Always identify the current phase before making changes.

If the user prompt does not clearly state the current phase, ask for clarification or make no code changes.

Never implement multiple phases at once unless explicitly instructed.

---

## Core Game Rules

Sky Vanguard is an endless vertical shooter.

The player controls one ship.

The player uses one active weapon at a time.

Weapon pickups replace the current weapon.

Weapon pickups must not stack.

Weapon pickups must not create an inventory system.

Booster pickups activate temporary support effects.

Booster pickups must not replace the current weapon.

---

## Prototype Scope

The first playable prototype focuses on:

```text
Basic Blaster
Spread Shot
Temporary Shield
Basic Enemy
Shooter Enemy
DropCarrier Enemy
Seeker Enemy
Homing Missile
Score
HUD
Pause
Game Over
Restart
Local Best Score
Android Testing
```

Do not implement Version 1.0 content unless explicitly instructed.

---

## One-Active-Weapon Rule

Approved prototype weapons:

```text
Basic Blaster
Spread Shot
```

Approved later Version 1.0 weapons:

```text
Basic Blaster
Spread Shot
Railgun
Laser Beam
```

Do not implement Railgun or Laser Beam during the prototype unless explicitly instructed.

Do not implement:

```text
Weapon inventory
Weapon stacking
Ammo
Weapon levels
Weapon fusion
Paid weapons
```

---

## Booster Rule

Approved prototype booster:

```text
Temporary Shield
```

Approved later Version 1.0 boosters:

```text
Temporary Shield
Speed Boost
Vanguard Burst
```

Do not implement Speed Boost or Vanguard Burst during the prototype unless explicitly instructed.

Boosters should activate temporary effects and must remain separate from weapons.

---

## Enemy Rule

Approved prototype enemies:

```text
Basic Enemy
Shooter Enemy
DropCarrier Enemy
Seeker Enemy
```

The Seeker may launch fair, readable, destructible homing missiles.

Homing missiles must have:

```text
Readable warning
Limited turn rate
Cleanup rules
Active missile limit
Destructible behavior
Fair damage behavior
```

Do not create boss enemies during the prototype.

Do not create extra enemy types unless explicitly instructed.

---

## Android-First Rule

The game must be designed for broad Android compatibility.

Prioritize:

```text
Stable framerate
Responsive touch input
Readable bullets
Low object buildup
Clean restarts
Safe pause/resume behavior
Minimal permissions
APK testing
```

Avoid:

```text
Heavy particles
Heavy shaders
Excessive overdraw
Unlimited bullets
Unlimited enemies
Uncontrolled effects
Unnecessary permissions
Online dependencies
Desktop-only assumptions
```

If something works in the Godot editor but feels bad on Android, it is not done.

---

## Scene Organization Direction

Recommended high-level structure:

```text
Main.tscn
  MainMenu
  Game

Game.tscn
  World
    Player
    EnemyContainer
    ProjectileContainer
    PickupContainer
    EffectContainer
  Systems
    GameStateManager
    SpawnManager
    ScoreSystem
    FeedbackSystem
  CanvasLayer
    HUD
    PauseMenu
    GameOverScreen
```

Runtime objects should be placed in clear containers:

```text
EnemyContainer
ProjectileContainer
PickupContainer
EffectContainer
```

Do not spawn gameplay objects randomly under root nodes.

Do not create one massive “God script” that controls everything.

---

## Folder Structure Direction

Use or preserve this folder direction:

```text
res://scenes/
res://scenes/core/
res://scenes/gameplay/
res://scenes/player/
res://scenes/enemies/
res://scenes/projectiles/
res://scenes/pickups/
res://scenes/ui/
res://scenes/effects/

res://scripts/
res://scripts/core/
res://scripts/gameplay/
res://scripts/player/
res://scripts/weapons/
res://scripts/enemies/
res://scripts/projectiles/
res://scripts/pickups/
res://scripts/boosters/
res://scripts/ui/
res://scripts/systems/
res://scripts/utilities/

res://autoload/
res://resources/
res://assets/
res://debug/
res://tests/
res://docs/
```

---

## Game State Rules

Gameplay should only run during `PLAYING`.

Expected states:

```text
BOOT
MAIN_MENU
STARTING_RUN
PLAYING
PAUSED
GAME_OVER
RESTARTING
RETURNING_TO_MENU
```

During Pause:

```text
Player movement stops
Auto-fire stops
Enemy movement stops
Projectile movement stops
Spawning stops
Damage does not apply
Booster timers pause
UI remains usable
```

During Game Over:

```text
Score locks
Gameplay consequences stop
Auto-fire stops
Spawning stops
Damage stops
Pickups stop applying
Restart is allowed
Return to Main Menu is allowed
```

---

## Score Rules

Only `ScoreSystem` should modify the current score.

Enemies may provide score values, but enemies should not directly modify HUD score.

HUD displays score.

HUD does not calculate score.

Projectiles do not directly award score.

Score resets at run start.

Score locks after Game Over begins.

Best score is saved locally through `SaveManager`.

Do not implement online leaderboards during the prototype.

---

## Save and Settings Rules

Use local save data only.

Recommended save path:

```text
user://save_data.json
```

Prototype save data may include:

```text
best_score
settings
```

Settings may include:

```text
music_volume
sfx_volume
haptics_enabled
camera_shake_enabled
```

Do not save every frame.

Do not require login.

Do not require internet.

Do not implement cloud save during the prototype.

If the save file is missing or invalid, the game should fall back safely to defaults.

---

## UI Rules

The UI should be readable in portrait orientation.

Prototype UI should include:

```text
Main Menu
HUD
Pause Menu
Game Over Screen
How To Play, optional
Settings, optional
```

HUD should display:

```text
Score
HP
Current weapon
Active booster/shield state
Pause button
```

UI taps should not accidentally move the player.

Do not add shop UI during the prototype.

Do not add ads UI during the prototype.

Do not add leaderboard UI during the prototype.

---

## Feedback Rules

Feedback should improve clarity.

Use lightweight feedback for:

```text
Player firing
Enemy hit
Enemy destroyed
Player damaged
Player death
Weapon pickup collected
Weapon changed
Shield activated
Shield block
Shield expired
Homing missile warning
Homing missile destroyed
Game Over
Button taps
```

Do not hide enemy bullets with effects.

Do not overuse camera shake.

Do not spam haptics.

Do not spam audio.

Respect settings such as:

```text
haptics_enabled
camera_shake_enabled
music_volume
sfx_volume
```

---

## Debug Rules

Debug tools are allowed during development.

Debug tools may include:

```text
FPS display
Active object counts
Spawn enemy buttons
Force weapon buttons
Force shield button
Trigger Game Over
Reset save, debug only
Show hitboxes
Stress test tools
```

Debug tools must be gated, toggleable, or removable.

Debug tools must not appear in release gameplay.

Debug tools must not accidentally alter normal gameplay.

---

## Testing Report Requirement

After each implementation phase, report:

```text
1. Summary of changes
2. Files created
3. Files modified
4. How to test
5. Acceptance checklist
6. Known issues
7. What was intentionally not implemented
8. Suggested next phase
```

Do not only say “done.”

Do not proceed beyond the approved phase.

Do not claim Android testing passed unless Android device testing actually happened.

Use these labels when relevant:

```text
Not Tested
Editor Tested
Android Tested
Android Issue Found
Android Passed
Needs Retest
```

---

## Scope Control Rules

Do not add unapproved features.

Specifically, do not add:

```text
Inventory
Shop
Currency
Gacha
Loot boxes
Energy system
Pay-to-win upgrades
Online leaderboard
Cloud save
Login
Accounts
Analytics
Ads SDK
Daily rewards
Achievements
Bosses
Extra weapons
Extra enemies
Extra boosters
Complex progression
```

Unless explicitly approved for the current phase.

If a useful future idea appears, document it as a Parking Lot candidate instead of implementing it.

---

## Final Instruction to Codex

You are not here to “just build a game.”

You are here to implement **Sky Vanguard** according to the approved plan.

Protect the architecture.

Protect Android performance.

Protect the one-active-weapon rule.

Protect the booster-vs-weapon distinction.

Protect testing discipline.

Protect the project from scope creep.

Build one verified phase at a time.
