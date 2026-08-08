# Sky Vanguard — Project Constitution v0.1

## 1. Project Identity

**Sky Vanguard** is an Android-first, portrait-oriented, endless vertical shooting game built in **Godot 4.x** using **GDScript**.

The game is intended to be a small, disciplined, publishable mobile game that helps build development experience and may help support larger future projects.

This project must remain focused, lightweight, and phase-driven.

---

## 2. Product Promise

Sky Vanguard should deliver a fast, readable, satisfying mobile arcade shooter experience where the player:

```text
Controls one ship
Dodges enemy attacks
Auto-fires continuously
Collects weapon pickups
Replaces the current weapon
Collects boosters
Survives as long as possible
Scores points
Restarts quickly
```

The game should be easy to understand but difficult to master.

---

## 3. Core Design Pillars

### 3.1 Android-First

Sky Vanguard is designed for Android first.

Desktop testing is useful, but Android usability is the real target.

The game must prioritize:

```text
Touch responsiveness
Portrait readability
Stable framerate
Clean UI tap targets
Battery-conscious performance
Safe pause/resume behavior
APK testing
```

### 3.2 One Ship, One Active Weapon

The player controls one ship and uses one active weapon at a time.

Weapon pickups replace the current weapon.

Weapons do not stack.

There is no prototype weapon inventory.

This keeps gameplay fast and readable.

### 3.3 Boosters Are Separate From Weapons

Booster pickups activate temporary support effects.

Boosters do not replace the current weapon.

Boosters do not create an inventory system during the prototype.

### 3.4 Readability Over Spectacle

The player must always be able to read:

```text
Player position
Enemy bullets
Homing missiles
Pickups
Active weapon behavior
Shield state
Damage feedback
```

Effects, sounds, camera shake, and haptics must never hide threats.

### 3.5 Performance Is Gameplay

Frame drops, input lag, object buildup, and restart leaks are gameplay problems.

The project should support a broad range of Android devices, old and new.

### 3.6 Phase-by-Phase Development

The project must be built one verified phase at a time.

No phase is complete until it has been tested and reviewed.

---

## 4. Prototype Scope

The First Playable Prototype includes:

```text
Android portrait orientation
Touch/drag player movement
Auto-fire
Basic Blaster
Spread Shot weapon pickup
Temporary Shield booster
Basic Enemy
Shooter Enemy
DropCarrier Enemy
Seeker Enemy
Destructible homing missile
Score
HUD
Pause
Game Over
Restart
Local best score, if implemented
Basic feedback
Android APK test
```

The prototype should prove the core loop before any expansion.

---

## 5. Version 1.0 Candidate Scope

Version 1.0 may include:

```text
Basic Blaster
Spread Shot
Railgun
Laser Beam
Temporary Shield
Speed Boost
Vanguard Burst
Small enemy roster
Score and best score
Settings
Audio and feedback polish
Android performance pass
Fair monetization, only if approved separately
```

Version 1.0 content should not be implemented until the prototype is stable and reviewed.

---

## 6. Monetization Constitution

Sky Vanguard may eventually use fair monetization, but monetization is not part of the first prototype.

Allowed future monetization directions may include:

```text
Optional rewarded ads
Optional cosmetic purchases
Optional remove-ads purchase
Optional fair support purchase
```

Forbidden monetization directions:

```text
Pay-to-win
Gacha
Loot boxes
Energy systems that block play
Manipulative FOMO
Required ads after every run
Paid weapon power advantages
```

The game must remain trustworthy.

---

## 7. Technical Constitution

The project must use:

```text
Godot 4.x
GDScript
Android-first export direction
Portrait orientation
Local save data
Modular scene architecture
```

The project must avoid:

```text
Unnecessary online dependencies
Unnecessary permissions
Heavy shaders in prototype
Heavy particles in prototype
Unlimited object spawning
Uncontrolled scene growth
God scripts
Unreviewed architecture rewrites
```

---

## 8. AI-Assisted Development Constitution

Codex may implement the game, but the project owner remains the decision-maker.

Codex must:

```text
Follow AGENTS.md
Read /docs before implementation
Implement only the current approved phase
Stop after the phase
Report files created and modified
Provide testing steps
Provide acceptance checklist
List known issues
Avoid unapproved features
```

Codex must not:

```text
Build the whole game in one pass
Skip ahead
Invent extra systems
Add monetization early
Add online services early
Ignore Android performance
Claim Android success without Android testing
```

---

## 9. Review and Approval Rule

Each phase ends with one decision:

```text
Approved
Needs Fixes
Needs Revision
Rejected / Rebuild Phase
```

Do not move to the next phase unless the current phase is approved.

---

## 10. Final Principle

Sky Vanguard should be small, disciplined, readable, performant, and trustworthy.

The project succeeds not by adding everything, but by building the right things in the right order.
