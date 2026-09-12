# Standalone Phase 10 revision: randomized spawning

## Changes and scope

SpawnManager now samples enemy types without replacement from stage-specific pools, chooses continuous horizontal entry positions, and varies each normal spawn interval by +/-15%. The first two enemies remain Basic. DropCarrier unlocks at 20 seconds and Seeker at 45 seconds of active gameplay. Existing stage pool ratios and mean delays (2.4 / 2.0 / 1.6 seconds) are retained.

Blocked special-enemy entries remain in the pool; Basic fills in if all remaining entries are capped. Consecutive Shooters are avoided when the remaining eligible pool has an alternative. A stage transition replaces the old pool and pending choice. A crowded entry retries after 0.35 seconds without consuming its pending choice. Random draws without replacement provide the shuffled-pool behavior without using the global random generator.

Entry positions preserve the 84-pixel screen margins and 72-pixel above-screen offset. Successive entries differ by at least 70 design pixels horizontally; entry clearance is a 100-design-pixel radial distance from existing enemies. Eight candidate attempts bound work per spawn attempt. On narrow viewports, the history distance shrinks to half the usable width; a collapsed width uses the center while still respecting enemy clearance.

`reset_spawning(run_seed: int = -1)` remains compatible with existing callers. The default generates a fresh seed; an explicit seed supports reproducible tests given identical gameplay inputs. Pause, Game Over, and revive preserve random state. New runs reset it. No save schema or UI changes.

Restart cleanup now treats a new run as a full runtime boundary. Before a Game scene is discarded or reset, gameplay is disabled, runtime containers are deactivated/queued for cleanup, and deferred DropCarrier pickup requests are guarded by the run generation that created them. This preserves rewarded revive as an in-run continuation while preventing stale enemies, pickups, projectiles, homing missiles, or delayed drops from leaking into a restarted run.

## Files

Modified: `scripts/systems/spawn_manager.gd`, `scripts/core/main.gd`, `scripts/gameplay/game.gd`, and `export_presets.cfg`.

Created: `tests/spawn_randomization_test.gd` (plus Godot-generated UID), and this report.

## Automated verification

Run Godot 4.7.1 with:

```text
--headless --path . --script tests/spawn_randomization_test.gd
```

Result after restart-cleanup coverage: `SPAWN_RANDOMIZATION_PASS checks=28041 simulated_runs=7 minutes_per_run=10`.

The simulation controls enemy movement and cleanup to exercise spawning; it is not an Android performance benchmark or a full combat simulation. It covers seeds, unlock thresholds, timing bounds, position bounds/history spacing, pool composition, special and total enemy caps, crowded-entry retries, fallback recovery, and no catch-up bursts. The actual Game and Main scenes are instantiated to verify pause/death/revive state preservation, second-death revive lockout, restart cleanup after rewarded revive, fresh-run score/HP/weapon state, old-object detachment, and first-two-Basic post-restart spawning. SpawnManager's Godot parse check and Git whitespace check passed.

## Acceptance checklist / how to test

- [x] Spawn sequences differ by seed and reproduce with identical seed/inputs.
- [x] Basic opening and gradual advanced-enemy unlocks remain.
- [x] Spawn caps, bounded retries, timing ranges, and lifecycle checks pass automatically.
- [x] Android focused restart-after-revive retest passed on Samsung SM-S721B / R5CXA2P294E.
- [x] Android spawn sanity after restart passed: varied X positions, readable Shooter pressure, reachable DropCarrier opportunities, manageable crowding, and fair late Seeker pressure.

Android hands-on acceptance: **Focused Retest Passed** for spawn randomization, rewarded revive compatibility, and restart-after-revive cleanup. This was not a separate full five-run exploratory balance pass beyond the focused acceptance already requested.

## Known limitations and intentionally excluded work

Randomness permits occasional similar encounters; it does not promise every local sequence is unique. Active caps and entry retries may lengthen effective intervals. Blocked pool entries can persist until their active cap clears. Enemy movement, attacks, HP, damage, score, missile warning/limits, starter pickups, and DropCarrier reward order are unchanged. No new enemies, weapons, rewards, adaptive difficulty, settings, or online systems were added. Local Android evidence remains outside the commit.

## Next step

Proceed only with exact-scope spawn randomization publication. Do not advance to another roadmap phase automatically.

## Android build/install evidence

On 2026-09-09, exported `exports/android/sky-vanguard-randomized-spawns.apk` (109,888,925 bytes), installed with data-preserving `adb install -r` (Success), and launched via the package's resolved `GodotAppLauncher` activity (Status: ok). Device: Samsung SM-S721B, serial R5CXA2P294E. Game process PID 10377 remained present after launch. Godot 4.7.1 startup appeared in the device log. Java 17 and ETC2/ASTC configuration were verified before export.

On 2026-09-12, the focused Android retest passed on the same Samsung SM-S721B / R5CXA2P294E device. The approved path covered rewarded revive, HP 3 revive state, preserved score after revive, projectile/missile cleanup, second-death one-revive lockout, restart after revive, clean Score 0 / HP 5 / Basic Blaster restart, no mixed-run enemies/pickups/projectiles/missiles, post-restart opening fairness, spawn variation sanity, Main Menu, Tutorial, Settings, and another clean run start. Filtered device logs showed no fatal crash, ANR, script error, or collision cleanup warning.

On 2026-09-12, APK size audit found `test_artifacts/` evidence imported into the 355,140,747-byte restart-fix APK as many `.godot/imported` screenshot/contact-sheet textures. `export_presets.cfg` now excludes `test_artifacts/*`, `tests/*`, `docs/*`, `debug/*`, and `.phase13_smoke_user/*` from Android export packaging. The clean rebuilt APK was `exports/android/sky-vanguard-spawn-randomization-clean.apk` at 110,514,219 bytes, SHA256 `9931F4E8C5932B04F84290DADE9674266964A6FE6CB3E3D6DA9B83ADA8FC5C04`; content inspection confirmed local evidence, screenshots/logs, tests/docs/debug resources, previous APKs, exports, and Android build output were not packaged.

The exporter child exited after generating the APK, but its console wrapper remained waiting with closed input; that verified wrapper was stopped. Therefore this was a generated-and-installed APK verification, not a clean exporter-process exit. No unrelated Godot/editor process was stopped.
