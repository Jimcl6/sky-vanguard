# Phase 15A: Tutorial Level and Onboarding

Approved scope: Control Flight, selectable on the Main Menu, with a generated
ocean background matching the existing top-down arcade treatment.

## Behavior

1. Touch near the ship inside the white circle (same 150-unit radius as Game).
2. Drag left to a gold marker.
3. Drag right.
4. Drag up.
5. Drag down.
6. Drag to the left screen bound.
7. Pause, then resume to finish. Choose PLAY RUN or MAIN MENU.

The player may release and re-grab throughout training. There is no time limit.
Pause allows returning to the menu at any point. Escape/Android Back toggles
pause. Losing application focus pauses training but does not complete the pause
lesson. Training starts fresh every time and never writes completion data.

The tutorial instantiates the existing Player but no Game, ScoreSystem,
SpawnManager, enemies, projectiles, or pickups. Fire, damage, and collection stay
disabled. Its local pause clears dragging and freezes movement and scrolling.
Normal GameStateManager.is_gameplay_allowed() remains PLAYING-only. The approved
TUTORIAL state is an isolated movement-only exception, documented in the roadmap.
Existing saved audio preferences apply through Main's AudioManager.

## Asset

Final asset: `assets/backgrounds/ocean_training_vertical_arcade.png`.
Created with the built-in image generation tool. Reference: existing city
background, inspected before generation. The original generated bitmap is
preserved; Godot scales it to the viewport. A vertically flipped second sprite
joins matching edges, following the existing city background technique. Two
sprites repeat with a period of twice the viewport height, at 150 units/second.
Markers use lightweight draw calls, without particles or shaders.

Generation prompt:

> Use case: stylized-concept. Create a new portrait bitmap background for Sky
> Vanguard, a top-down vertical arcade aircraft shooter. Match the restrained
> painterly detailed arcade rendering of the reference city image visible in
> conversation, but depict ONLY open ocean viewed straight down from high
> altitude. Muted blue-green water, subtle small wave streaks and gentle currents,
> sparse wispy clouds along the outer edges. Even subdued contrast for a bright
> player ship and tutorial markers to remain readable. No horizon, no perspective
> tilt, no land, buildings, boats, aircraft, text or UI. Seamlessly tile vertically:
> top and bottom edges must match in water tone and wave texture; no big focal
> object. Portrait 1024x1792 if supported. This is a production game background,
> full bleed.

## Verification

Recorded on 2026-09-10 using Godot 4.7.1:

- Editor import completed without parse errors.
- Headless tutorial test: `TUTORIAL_TEST failures=0`, clean shutdown.
- Rendered tutorial test: `TUTORIAL_TEST failures=0`, clean shutdown.
- Rendered captures reviewed at 720x1280 and 720x1600: menu entry, instructions,
  player, markers, pause menu, and completion actions readable without overlap.
- Existing spawn regression: `SPAWN_RANDOMIZATION_PASS checks=28016`, seven
  simulated ten-minute runs.
- `git diff --check`: passed.
- Android Tested on Samsung Galaxy S24 FE `SM_S721B` / `R5CXA2P294E`, physical
  size `1080x2340`, density `450`.
- Fresh debug APK exported to `exports/android/sky-vanguard-debug.apk`
  (`111445546` bytes, 2026-09-10 12:04 local time), installed with
  `adb install -r`, and launched through
  `com.jimcl6.skyvanguard/com.godot.game.GodotAppLauncher`.
- Android process/focus checks passed: package had a live PID and Android
  reported `GodotAppLauncher` as the focused activity.
- Device screenshots reviewed: Main Menu TUTORIAL entry, tutorial start, lesson
  progression, left screen-bound lesson, pause modal, completion screen, and
  PLAY RUN handoff into normal gameplay were visible and readable.
- Filtered Android logcat after the run returned no fatal crash or ANR matches.
- Export note: Godot printed `[ DONE ] export` and produced the current APK, but
  also printed shutdown resource-leak warnings and the console process did not
  exit until interrupted. Treat this as a tooling/cleanup issue to investigate
  before release packaging; it did not block installation or launch.

Reproduce:

- Run `tests/tutorial_level_test.gd` with Godot's `--headless --script` option.
- Run the same script without headless and with `-- --capture` to render portrait
  screenshots in user:// at 720x1280 and 720x1600.
- Automated checks send touch/drag events through the viewport and test lesson
  progression, rejected distant touches, pause UI input, focus-loss semantics,
  completion, run transition, menu exit, reentry, normal run pause/game-over/
  restart, and best-score preservation.
- Physical Android: tap TUTORIAL, complete each lesson, release/re-grab, check
  screen edges and notch readability, background the app, resume, use Back,
  return to menu, reenter, and start a normal run from completion.
- Android status: Android Tested for APK export, install, launch, tutorial
  entry, ADB-driven tutorial completion, pause/resume, and PLAY RUN handoff.
  Needs manual finger-feel review before final phase approval.

Cleanup retest on 2026-09-10:

- Tutorial text was shortened to arcade-style prompts for mobile readability.
- The left screen-bound lesson now uses the same forgiving 44-unit arrival
  radius as the other movement targets after Android testing showed the ship
  could visibly reach the edge without advancing.
- `TutorialLevel.tscn` no longer depends on the separate local UI theme work;
  this keeps the tutorial source safe to publish without mixing in unrelated
  UI/theme cleanup.
- `git diff --check`, 27-script parse sweep, and headless
  `TUTORIAL_TEST failures=0` passed after cleanup.
- Fresh APK exported to `exports/android/sky-vanguard-tutorial-test.apk`
  (`111445686` bytes, SHA256
  `67BFD3490111E60B0D3B25B0E1CA12E9B2EB50CAC5B8E315C2E7F69EC9400244`),
  installed on Samsung Galaxy S24 FE `SM_S721B` / `R5CXA2P294E`, and launched
  through `com.jimcl6.skyvanguard/com.godot.game.GodotAppLauncher`.
- Android retest confirmed Main Menu tutorial entry, tutorial start, left-edge
  lesson completion, pause/resume, completion screen, PLAY RUN handoff into
  normal gameplay, live process/focused activity, and no filtered fatal crash
  or ANR logcat matches.

## File Inventory

Created:

- `scenes/gameplay/TutorialLevel.tscn`
- `scripts/gameplay/tutorial_level.gd` and Godot UID metadata
- `assets/backgrounds/ocean_training_vertical_arcade.png` and import metadata
- `tests/tutorial_level_test.gd`
- `docs/PHASE15A_TUTORIAL.md`

Modified for this phase:

- `scripts/core/main.gd`: tutorial entry, exit, cleanup, existing audio routing.
- `scripts/core/game_state_manager.gd`: appended TUTORIAL state.
- `scripts/player/player.gd`: drag-start notification for touch and mouse.
- `scripts/ui/main_menu.gd`: tutorial request signal.
- `scenes/ui/MainMenu.tscn`: tutorial button within the current menu design.
- `docs/IMPLEMENTATION_PHASES.md`: approved Phase 15A scope and state exception.

Other dirty files predate this implementation and were preserved. Publication
was separately authorized after Android tutorial acceptance.

## Scope and Review

No combat lessons, score, saved completion flag, new weapons, boosters, enemies,
ads integration, or online features. Existing unrelated worktree changes remain.
Suggested next step: manual finger-feel acceptance and product-owner review of
Phase 15A. Combat/pickup onboarding is a parking-lot candidate requiring
separate approval.
