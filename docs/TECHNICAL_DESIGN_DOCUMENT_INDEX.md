# Sky Vanguard — Technical Design Document Index v0.1

## Purpose

This file is the local repo index for the approved Technical Design Document.

The full detailed TDD is stored in Notion. This local file gives Codex the approved technical direction and section map so implementation can proceed without relying on ChatGPT conversation history.

If more detail is needed for a specific section, ask the product owner to provide or export that section before implementing.

---

## Approved Technical Foundation

Project:

```text
Sky Vanguard
Godot 4.x
GDScript
Android-first
Portrait orientation
Touch/drag movement
Endless vertical shooter

Development style:

```text
Phase-by-phase
Reviewed after each phase
No scope creep
No monetization during prototype
No online systems during prototype
Performance-conscious
```

---

## TDD Section Map

Approved TDD sections:

```text
1. Technical Purpose & Implementation Rules
2. Godot Project Configuration
3. Core Scene Architecture
4. Game State Flow
5. Player Controller
6. Weapon System
7. Projectile & Object Pooling System
8. Enemy System
9. Spawn & Wave System
10. Pickups & Boosters System
11. Damage, Collision & Hitbox Rules
12. UI, HUD & Menus
13. Score, Save Data & Settings
14. Game Feel, Audio & Feedback Hooks
15. Android Performance & Export Rules
16. Testing, Debug Tools & Acceptance Checklists
17. Codex Implementation Phases
```

---

## Core Architecture Direction

Recommended high-level scene structure:

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

---

## Runtime Containers

Runtime objects should be organized under clear containers:

```text
EnemyContainer
ProjectileContainer
PickupContainer
EffectContainer
```

Do not spawn gameplay objects randomly under root.

---

## Game State Direction

Approved states:

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

Gameplay logic should run only during `PLAYING`.

Pause and Game Over must stop gameplay consequences.

---

## Player Controller Direction

Prototype player controller should support:

```text
Touch/drag movement
Finger offset
Gameplay bounds clamp
Auto-fire compatibility
HP/lives support
DamageHitbox
PickupCollector
Temporary invulnerability after damage
Android touch testing
```

Do not implement gyro during the prototype unless explicitly approved.

---

## Weapon System Direction

Rules:

```text
One active weapon at a time
Weapon pickups replace current weapon
No stacking
No inventory
No ammo
No weapon leveling during prototype
```

Prototype weapons:

```text
Basic Blaster
Spread Shot
```

Version 1.0 candidates:

```text
Railgun
Laser Beam
```

---

## Projectile Direction

Projectile system should support:

```text
Player projectiles
Enemy projectiles
Homing missiles
Movement
Damage
Lifetime
Off-screen cleanup
Collision layers/masks
Pooling-ready structure
ProjectileContainer
```

Frequent projectiles should be pooling-ready.

---

## Enemy Direction

Prototype enemies:

```text
Basic Enemy
Shooter Enemy
DropCarrier Enemy
Seeker Enemy
```

Enemy rules:

```text
Enemies should emit signals for death/drops
Enemies should not directly update HUD score
Enemies should clean up off-screen
Enemies should not spawn unlimited projectiles
```

---

## Spawn/Wave Direction

SpawnManager should control enemy spawning.

Prototype spawn pacing:

```text
Basic enemies first
Shooter enemies after basic movement/combat is understood
DropCarrier after pickup systems exist
Seeker and homing missiles later
No early missile spam
Controlled active enemy limits
```

---

## Pickups and Boosters Direction

Pickup categories:

```text
Weapon pickup
Booster pickup
```

Weapon pickup:

```text
Replaces current weapon
Does not stack
Does not create inventory
```

Booster pickup:

```text
Activates temporary effect
Does not replace weapon
Does not create inventory
```

Prototype booster:

```text
Temporary Shield
```

---

## Damage and Collision Direction

Use clear collision ownership.

Important separation:

```text
Player DamageHitbox receives damage
Player PickupCollector collects pickups
Enemy hurtbox receives player projectile hits
Projectiles should not directly award score
Shield can block damage before HP decreases
Invulnerability prevents rapid repeated damage
```

Collision must feel fair.

---

## UI Direction

Prototype UI:

```text
Main Menu
HUD
Pause Menu
Game Over Screen
How To Play, optional
Settings, optional
```

HUD:

```text
Score
HP/lives
Current weapon
Active shield/booster state
Pause button
```

UI taps should not move the player.

---

## Score, Save, and Settings Direction

Score:

```text
Only ScoreSystem modifies current score
HUD displays score
Score resets at run start
Score locks after Game Over
No score after Game Over
```

Save:

```text
Use SaveManager
Local user://save_data.json
Best score persists locally
Missing/invalid save falls back safely
No cloud save during prototype
```

Settings:

```text
Use SettingsManager
music_volume
sfx_volume
haptics_enabled
camera_shake_enabled
```

---

## Feedback Direction

Feedback should be lightweight and readable.

Include hooks for:

```text
Player firing
Enemy hit
Enemy destroyed
Player damaged
Player death
Pickup collected
Weapon changed
Shield activated
Shield block
Shield expired
Missile warning
Missile destroyed
UI tap
```

Do not hide bullets with effects.

Do not overuse camera shake or haptics.

---

## Android Performance Direction

Performance rules:

```text
Limit active projectiles
Limit active enemies
Limit active missiles
Limit active pickups
Limit active effects
Clean up off-screen objects
Avoid heavy particles in prototype
Avoid heavy shaders in prototype
Avoid unnecessary permissions
Test on Android early
Use APK for prototype testing
```

Frame drops are gameplay bugs.

---

## Testing Direction

Each phase must end with:

```text
Summary of changes
Files created
Files modified
How to test
Acceptance checklist
Known issues
What was intentionally not implemented
Suggested next phase
```

Do not claim Android testing passed unless it was tested on an Android device.

---

## Technical Non-Negotiables

```text
Android-first
Portrait-first
Touch-first
Godot 4.x
GDScript
One active weapon
Boosters separate from weapons
No monetization in prototype
No online systems in prototype
No inventory in prototype
No scope creep
Phase-by-phase implementation
Testing before approval
```
```
