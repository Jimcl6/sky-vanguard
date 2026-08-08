# Sky Vanguard — Lean Game Design Document v0.1

## 1. Game Identity

**Title:** Sky Vanguard  
**Genre:** Endless vertical shooting game  
**Platform:** Android-first  
**Orientation:** Portrait  
**Engine:** Godot 4.x  
**Language:** GDScript  
**Primary control:** Touch/drag movement  
**Primary camera/view:** Top-down vertical scrolling shooter  

---

## 2. Core Promise

Sky Vanguard is a mobile arcade shooter where the player controls one ship, dodges enemies and projectiles, collects weapon and booster pickups, and tries to survive as long as possible while earning score.

The core promise:

```text
Fast runs
Simple controls
Readable action
Weapon replacement decisions
Temporary booster support
Fair challenge
Quick restart
```

---

## 3. Core Gameplay Loop

```text
Start run
→ Move ship with touch/drag
→ Auto-fire at enemies
→ Dodge enemies and bullets
→ Destroy enemies
→ Collect optional pickups
→ Replace weapon or activate booster
→ Score points
→ Survive increasing pressure
→ Die
→ View score
→ Restart
```

---

## 4. Player Controls

Prototype control:

```text
Touch/drag movement
Auto-fire
Pause button
```

Later optional controls:

```text
Gyro/tilt movement
Touch sensitivity settings
Gyro sensitivity settings
Calibration
```

Gyro is not part of the first prototype unless explicitly promoted.

---

## 5. Player Ship

The player controls one ship.

Prototype player requirements:

```text
Responsive movement
Screen bounds clamp
HP or lives
Damage feedback
Temporary invulnerability after damage
Separate damage hitbox and pickup collector
```

The player should feel responsive and fair on Android.

---

## 6. Weapon System

The player has one active weapon at a time.

Weapon pickups replace the current weapon.

No inventory.

No stacking.

No ammo system in prototype.

Prototype weapons:

```text
Basic Blaster
Spread Shot
```

Version 1.0 candidate weapons:

```text
Basic Blaster
Spread Shot
Railgun
Laser Beam
```

---

## 7. Prototype Weapons

### Basic Blaster

Default weapon.

Behavior:

```text
Fires one projectile upward at a steady rhythm
Simple and reliable
Easy to read
```

### Spread Shot

Pickup weapon.

Behavior:

```text
Fires multiple projectiles in a spread pattern
Covers more horizontal space
Replaces current weapon
Does not stack with Basic Blaster
```

---

## 8. Booster System

Boosters are separate from weapons.

Boosters activate temporary support effects.

Prototype booster:

```text
Temporary Shield
```

Version 1.0 candidate boosters:

```text
Temporary Shield
Speed Boost
Vanguard Burst
```

---

## 9. Temporary Shield

Temporary Shield protects the player for a limited time.

Behavior:

```text
Collected as booster pickup
Activates shield visual
Blocks incoming damage while active
Does not replace weapon
Expires after duration
Shows feedback when damage is blocked
```

The shield should feel helpful but not permanent.

---

## 10. Pickups

Pickup categories:

```text
Weapon pickups
Booster pickups
```

Weapon pickups replace the current weapon.

Booster pickups activate a temporary effect.

Pickups should be optional and avoidable.

Pickups should not look like enemy bullets.

---

## 11. Enemy Roster

Prototype enemies:

```text
Basic Enemy
Shooter Enemy
DropCarrier Enemy
Seeker Enemy
```

### Basic Enemy

Simple downward movement.

Teaches movement and shooting.

### Shooter Enemy

Moves and fires enemy projectiles.

Teaches dodging bullets.

### DropCarrier Enemy

Drops weapon or booster pickups when destroyed.

Teaches pickup decisions.

### Seeker Enemy

Launches fair, readable, destructible homing missiles.

Teaches tactical pressure and counterplay.

---

## 12. Homing Missile

Homing missiles must be fair.

Rules:

```text
Readable warning
Distinct visual
Limited turn rate
Destructible by player projectiles
Limited active count
Cleanup by hit, destruction, lifetime, or off-screen
Shield can block damage
```

Homing missiles should pressure the player, not feel unavoidable.

---

## 13. Scoring

Score increases when enemies are destroyed.

Prototype score events may include:

```text
Basic Enemy destroyed
Shooter Enemy destroyed
DropCarrier Enemy destroyed
Seeker Enemy destroyed
Homing Missile destroyed, optional
```

Score should not increase when enemies simply leave the screen.

Score locks after Game Over.

Best score may save locally.

---

## 14. UI and HUD

Prototype UI:

```text
Main Menu
HUD
Pause Menu
Game Over Screen
```

HUD should show:

```text
Score
HP or lives
Current weapon
Active shield/booster state
Pause button
```

Game Over should show:

```text
Final score
Best score, if implemented
Restart
Main Menu
```

---

## 15. Game States

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

Gameplay should only run during `PLAYING`.

Pause and Game Over must stop gameplay consequences.

---

## 16. Game Feel

Prototype feedback should include:

```text
Player damage feedback
Enemy hit feedback
Enemy destroyed feedback
Pickup collected feedback
Weapon changed feedback
Shield active/block/expire feedback
Missile warning feedback
Button tap feedback
```

Camera shake and haptics are optional and must respect settings if implemented.

Feedback must not hide enemy bullets.

---

## 17. Visual Direction

The visual style should be simple, readable, and mobile-friendly.

Priority order:

```text
Enemy bullets
Player ship
Homing missiles
Pickups
Enemies
Player bullets
Effects
Background
```

Avoid visual clutter.

---

## 18. Audio Direction

Prototype audio may be placeholder or minimal.

Useful SFX:

```text
Player shot
Enemy shot
Enemy destroyed
Player hit
Pickup collected
Shield activated
Shield block
Missile warning
Game Over
UI tap
```

Avoid audio spam during auto-fire.

---

## 19. Android Performance Direction

Sky Vanguard should support a broad range of Android devices.

Performance priorities:

```text
Responsive input
Stable framerate
Limited object counts
Clean object cleanup
No heavy particles in prototype
No heavy shaders in prototype
APK testing
Pause/resume safety
Restart safety
```

---

## 20. Monetization Direction

No monetization in the first prototype.

Future monetization must be fair and optional.

Forbidden:

```text
Pay-to-win
Gacha
Loot boxes
Energy systems
Manipulative FOMO
Forced excessive ads
```

---

## 21. First Playable Prototype Definition

The prototype is complete when the player can:

```text
Launch the game
Start from Main Menu
Move with touch/drag
Auto-fire Basic Blaster
Destroy enemies
Collect Spread Shot
Replace current weapon
Collect Temporary Shield
Block damage
Dodge bullets and homing missiles
Score points
Take damage
Reach Game Over
Restart cleanly
Play again
```

The prototype should be tested on Android before being considered complete.

---

## 22. Parking Lot / Future Ideas

Future ideas that are not prototype scope:

```text
Railgun
Laser Beam
Speed Boost
Vanguard Burst
Additional enemy types
Bosses
Gyro controls
Achievements
Leaderboards
Cosmetics
Ads
Shop
Cloud saves
Daily challenges
```

Mentioned does not mean approved for immediate implementation.
