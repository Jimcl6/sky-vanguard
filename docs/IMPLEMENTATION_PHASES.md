# Sky Vanguard — Implementation Phases v0.1

## Purpose

This document defines the approved phase-by-phase implementation roadmap for Codex.

Codex must implement one phase at a time, stop, and report results for review.

---

## Global Codex Rules

For every phase:

```text
Read AGENTS.md
Read /docs files
Implement only the current phase
Do not add unapproved features
Do not add monetization
Do not add online systems
Do not skip ahead
Do not implement future phases early
Stop after the phase
Report changes and testing steps
```

Required Codex report format:

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

---

## Phase 0 — Project Setup & Technical Baseline

Purpose:

Create the Godot project foundation and repo structure.

Scope:

```text
Godot 4.x project
Project name: Sky Vanguard
Portrait-first settings
Base folder structure
Initial main scene placeholder
Documentation folder preserved
No gameplay implementation yet
```

Acceptance checklist:

```text
- [ ] Godot project opens without errors.
- [ ] Project name is Sky Vanguard.
- [ ] Folder structure exists.
- [ ] Main scene placeholder exists.
- [ ] Project is configured for portrait-first direction.
- [ ] No gameplay systems were added.
```

---

## Phase 1 — Core Scene Architecture & Game State Flow

Purpose:

Create the main scene flow and state structure.

Scope:

```text
Main.tscn
Game.tscn
Basic MainMenu
Basic GameOver placeholder
Game state enum/manager
Start run flow
Game Over placeholder transition
Restart placeholder flow
Return to Main Menu flow
```

Acceptance checklist:

```text
- [ ] App starts at Main Menu.
- [ ] Start enters Game scene.
- [ ] Game can transition to Game Over placeholder.
- [ ] Restart creates a clean run placeholder.
- [ ] Return to Main Menu works.
- [ ] Gameplay does not run behind Main Menu.
```

---

## Phase 2 — Player Controller & Touch Movement

Purpose:

Implement player movement foundation.

Scope:

```text
Player.tscn
Player placeholder visual
Touch/drag movement
Finger offset
Gameplay bounds clamp
Optional desktop debug movement
Player active only during PLAYING
Basic HP variables
DamageHitbox placeholder
PickupCollector placeholder
```

Acceptance checklist:

```text
- [ ] Player appears in Game scene.
- [ ] Touch/drag movement works.
- [ ] Finger offset works or is tunable.
- [ ] Player stays inside gameplay bounds.
- [ ] Movement stops outside PLAYING.
- [ ] DamageHitbox and PickupCollector are separate.
```

---

## Phase 3 — Weapon System, Basic Blaster & Projectiles

Purpose:

Create first firing loop.

Scope:

```text
WeaponController
Basic Blaster
Auto-fire only during PLAYING
Player projectile scene
Projectile movement
Projectile lifetime
Off-screen cleanup
ProjectileContainer
Projectile collision preparation
```

Acceptance checklist:

```text
- [ ] Player auto-fires during PLAYING.
- [ ] Auto-fire stops during Pause/Game Over.
- [ ] Basic Blaster fires one projectile upward.
- [ ] Projectiles move correctly.
- [ ] Projectiles clean up.
- [ ] Projectile count does not grow forever.
- [ ] No inventory/ammo/upgrade system was added.
```

---

## Phase 4 — Basic Enemy, Damage & Score Loop

Purpose:

Create first combat loop.

Scope:

```text
EnemyBasic.tscn
EnemyContainer
Basic downward movement
Enemy HP
Enemy hurtbox
Player projectile damages enemy
Enemy death once
ScoreSystem
Score update signal
Basic HUD score display
Off-screen enemy cleanup
```

Acceptance checklist:

```text
- [ ] Basic Enemy appears.
- [ ] Basic Enemy moves downward.
- [ ] Player projectile hits enemy.
- [ ] Enemy HP decreases.
- [ ] Enemy dies once.
- [ ] Score increases once on valid death.
- [ ] HUD score updates.
- [ ] Off-screen cleanup gives no score.
```

---

## Phase 5 — Shooter Enemy & Enemy Projectiles

Purpose:

Introduce enemy bullet pressure.

Scope:

```text
EnemyShooter.tscn
Shooter movement
Shooter fire cooldown
Enemy projectile scene
Enemy projectile movement
Enemy projectile cleanup
Enemy projectile damages player
Player HP update
Player invulnerability after damage
Basic player damage feedback
```

Acceptance checklist:

```text
- [ ] Shooter appears and moves.
- [ ] Shooter fires only during PLAYING.
- [ ] Enemy projectiles move correctly.
- [ ] Enemy projectiles clean up.
- [ ] Enemy projectiles damage player.
- [ ] Player HP decreases.
- [ ] Invulnerability prevents rapid repeated damage.
- [ ] Projectile density remains readable.
```

---

## Phase 6 — Weapon Pickups & Spread Shot Replacement

Purpose:

Implement weapon replacement mechanic.

Scope:

```text
PickupWeapon.tscn
PickupContainer
Weapon pickup movement
Pickup lifetime/cleanup
Player PickupCollector detection
Spread Shot weapon pattern
Weapon replacement through WeaponController
weapon_changed signal
HUD current weapon display
No inventory
```

Acceptance checklist:

```text
- [ ] Spread Shot pickup appears.
- [ ] Pickup uses PickupCollector.
- [ ] Collecting Spread Shot replaces Basic Blaster.
- [ ] HUD updates current weapon.
- [ ] Projectile pattern changes.
- [ ] Pickup applies once.
- [ ] No inventory exists.
- [ ] No stacking occurs.
```

---

## Phase 7 — Temporary Shield Booster

Purpose:

Implement first booster.

Scope:

```text
PickupBooster.tscn
BoosterController
Temporary Shield
Shield duration
Shield visual
Shield block logic
Shield expiration
Shield HUD indicator
Shield refresh behavior
Booster timer pause behavior
```

Acceptance checklist:

```text
- [ ] Shield pickup appears.
- [ ] Shield activates without replacing weapon.
- [ ] Current weapon remains unchanged.
- [ ] Shield visual appears.
- [ ] HUD shows shield active.
- [ ] Shield blocks damage.
- [ ] HP does not decrease when shield blocks.
- [ ] Shield expires.
- [ ] Shield resets on Game Over/Restart.
```

---

## Phase 8 — DropCarrier Enemy & Pickup Drops

Purpose:

Connect enemy destruction with pickup opportunities.

Scope:

```text
EnemyDropCarrier.tscn
Distinct DropCarrier visual
DropCarrier HP/score
Drop request signal
Pickup spawn on death
Controlled Spread Shot drop
Optional Shield drop after Spread test
Pickup fairness spacing
```

Acceptance checklist:

```text
- [ ] DropCarrier appears distinct.
- [ ] DropCarrier can be destroyed.
- [ ] Drop request emits once.
- [ ] Pickup appears at valid position.
- [ ] Pickup is optional/avoidable.
- [ ] Pickup does not spawn directly on player.
- [ ] Score and drop events happen once.
```

---

## Phase 9 — Seeker Enemy & Homing Missile

Purpose:

Introduce homing missile threat and counterplay.

Scope:

```text
EnemySeeker.tscn
Seeker movement
Missile warning/telegraph
Homing missile scene
Limited turn-rate tracking
Missile lifetime/cleanup
Missile damages player
Missile destructible by player projectiles
Missile destroyed feedback
Active missile limit
```

Acceptance checklist:

```text
- [ ] Seeker appears and moves.
- [ ] Seeker telegraphs missile launch.
- [ ] Missile launches only during PLAYING.
- [ ] Missile tracks with limited turn rate.
- [ ] Missile is readable.
- [ ] Missile can damage player.
- [ ] Shield can block missile damage.
- [ ] Player projectiles can destroy missile.
- [ ] Missile cleans up.
- [ ] Active missile limit works.
```

---

## Phase 10 — Spawn/Wave Progression

Purpose:

Implement structured enemy pacing.

Scope:

```text
SpawnManager
Time-based run phases
Basic enemy spawning
Shooter introduction
DropCarrier introduction
Seeker introduction
Spawn lanes
Active enemy limits
Active missile awareness
Spawn cooldown tuning
Stop spawning on Pause/Game Over
Reset spawning on Restart
```

Acceptance checklist:

```text
- [ ] SpawnManager exists.
- [ ] Enemies spawn into EnemyContainer.
- [ ] Spawning only during PLAYING.
- [ ] Spawning stops during Pause/Game Over.
- [ ] Spawn phase progresses by run time.
- [ ] Enemy types are introduced gradually.
- [ ] No early missile spam.
- [ ] Restart resets spawn phase.
```

---

## Phase 11 — HUD, Pause & Game Over UI

Purpose:

Complete readable UI and state-safe menus.

Scope:

```text
HUD
Score display
HP display
Current weapon display
Shield/booster display
Pause button
PauseMenu
Resume
Restart
Main Menu
GameOver screen
Final score
Best score placeholder/integration
Touch-safe UI layout
```

Acceptance checklist:

```text
- [ ] HUD shows score.
- [ ] HUD shows HP.
- [ ] HUD shows current weapon.
- [ ] HUD shows shield state.
- [ ] Pause works.
- [ ] Pause stops gameplay.
- [ ] Game Over shows final score.
- [ ] Restart works.
- [ ] Main Menu works.
- [ ] UI taps do not move player.
```

---

## Phase 12 — Save Data & Settings

Purpose:

Add local persistence.

Scope:

```text
SaveManager
user://save_data.json
Best score load/save
Final score comparison
New Best detection
SettingsManager defaults
Optional basic settings persistence
Missing save fallback
Invalid save fallback if practical
```

Acceptance checklist:

```text
- [ ] SaveManager loads defaults if no save exists.
- [ ] Best score saves locally.
- [ ] Best score persists after restart.
- [ ] Restart does not erase best score.
- [ ] Game Over displays best score.
- [ ] New Best detection works.
- [ ] SettingsManager provides defaults.
- [ ] Save does not happen every frame.
```

---

## Phase 13 — Game Feel, Audio & Feedback Hooks

Purpose:

Add lightweight feedback.

Scope:

```text
Enemy hit feedback
Enemy destroyed feedback
Player damage feedback
Player death feedback
Weapon pickup feedback
Weapon changed feedback
Shield activation feedback
Shield block feedback
Shield expiration feedback
Missile warning feedback
Missile destroyed feedback
Button feedback
Optional SFX hooks
Optional haptic hooks
Optional subtle camera shake
```

Acceptance checklist:

```text
- [ ] Enemy hit feedback is visible.
- [ ] Enemy destroyed feedback is visible.
- [ ] Player damage feedback is clear.
- [ ] Shield block feedback is distinct.
- [ ] Weapon pickup feedback is clear.
- [ ] Booster feedback differs from weapon feedback.
- [ ] Missile warning is readable.
- [ ] Effects clean up.
- [ ] Feedback does not hide bullets.
```

---

## Phase 14 — Android Export & Device Testing

Purpose:

Prove the prototype works on Android hardware.

Scope:

```text
Android export setup
APK debug export
Install on Android device
Portrait orientation test
Touch movement test
UI tap test
Safe-area check
Performance check
Pause/resume check
Restart check
Save/load check if implemented
Device notes
```

Acceptance checklist:

```text
- [ ] APK exports successfully.
- [ ] APK installs on Android device.
- [ ] Game launches.
- [ ] Portrait orientation works.
- [ ] Touch movement works.
- [ ] UI buttons are tappable.
- [ ] Gameplay is readable.
- [ ] No major frame drops in normal play.
- [ ] Pause/resume works.
- [ ] Restart works.
```

---

## Phase 15 — Prototype Stabilization & Bug Fixing

Purpose:

Stabilize the First Playable Prototype.

Scope:

```text
Crashes
Scene errors
Signal bugs
Restart bugs
Pause bugs
Game Over bugs
Collision bugs
Score bugs
Save bugs
Touch issues
Performance spikes
Object cleanup issues
Android-specific issues
```

Acceptance checklist:

```text
- [ ] Core loop works repeatedly.
- [ ] Restart works repeatedly.
- [ ] Pause works reliably.
- [ ] Game Over works reliably.
- [ ] No duplicate scoring.
- [ ] No duplicate damage bugs.
- [ ] Objects clean up correctly.
- [ ] No major frame spikes in normal play.
- [ ] Prototype feels playable.
```

---

## Phase 16 — Version 1.0 Expansion Planning

Purpose:

Plan the next development stage after the prototype is stable.

Scope:

```text
Prototype review
Fun factor review
Fairness review
Performance review
Version 1.0 candidate features
Parking Lot review
Next roadmap approval
```

Candidate Version 1.0 features:

```text
Railgun
Laser Beam
Speed Boost
Vanguard Burst
Additional enemies
More polished menus
Better settings
More audio/visual polish
Fair monetization later
```

Acceptance checklist:

```text
- [ ] Prototype review completed.
- [ ] Major bugs identified.
- [ ] Performance status reviewed.
- [ ] Player feel reviewed.
- [ ] Combat readability reviewed.
- [ ] Version 1.0 candidates listed.
- [ ] Parking Lot reviewed.
- [ ] Next roadmap approved.
```

---

## Final Implementation Rule

Do not start coding by building the whole game.

Start with:

```text
Phase 0 — Project Setup & Technical Baseline
```

Then stop for review.
