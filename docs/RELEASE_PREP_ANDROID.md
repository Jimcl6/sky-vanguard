# Sky Vanguard Android Release Prep

This checklist prepares Sky Vanguard for a future Google Play Internal Testing upload. It must not contain keystore passwords, private keys, Play Console credentials, or signing secrets.

## Release Identity

- Package name: `com.dementedstudios.sky_vanguard`
- App label: `Sky Vanguard`
- Current Android preset: `Android Debug`
- Current export output: `exports/android/sky-vanguard-debug.apk`
- Current version name: `0.1.0`
- Current version code: `1`
- Recommended first internal-test label if a release preset is created: `0.1.0-internal.1`

## AdMob Configuration

Current test IDs are configured on `scenes/core/Main.tscn` under `Main/AdsManager/Admob`.

- Android debug app ID: Google sample/test app ID
- Android debug banner unit: Google sample/test banner unit
- Android debug rewarded unit: Google sample/test rewarded unit
- Production Android app ID: provided and configured
- Production banner unit ID: provided and configured
- Production rewarded unit ID: provided and configured

The production IDs are configured in the same `Admob` node using:

```text
android_real_application_id
android_real_banner_id
android_real_rewarded_id
```

The Google test IDs remain configured in:

```text
android_debug_application_id
android_debug_banner_id
android_debug_rewarded_id
```

The `Admob` node controls test vs production mode with `is_real`. The current committed scene leaves `is_real` unset/false, so debug/internal validation continues to use Google test ads. For a production release build, set `is_real = true` in `scenes/core/Main.tscn` as part of a separately reviewed release-mode change, then verify the export before upload.

Do not click or repeatedly test real production ads. If testing before Play release, prefer the committed test-ad mode unless a production-ad validation task is explicitly approved. Do not add app-open ads, interstitial ads, native ads, consent flow, or additional ad formats without a separate approved task.

## Release Signing And Upload Key

Release signing is not configured in the repository. Do not commit keystores, passwords, aliases, private keys, or local machine paths.

Recommended upload-key storage location:

```text
<outside-repository secure keys folder>\sky-vanguard-upload.jks
```

If a Godot export preset references a local keystore path, remember that `export_presets.cfg` is a tracked file in this repository. Prefer either a local-only workflow that does not commit the path, or a separately reviewed release preset policy before storing any machine-specific signing path.

Before building an upload-ready AAB:

- Create or locate the Google Play upload key outside the repository.
- Confirm the keystore backup location.
- Enter signing values only in a local environment.
- Verify no credentials are printed in logs or written to docs.
- Verify `.gitignore` covers `*.jks`, `*.keystore`, `*.p12`, `*.pem`, `*.key`, and `*.idsig`.
- Switch `Admob.is_real` to true only in the reviewed release configuration.
- Confirm the Android manifest receives the production AdMob app ID during export.

## AAB Export Plan

Current preset exports an APK because `gradle_build/export_format=0`.

For a future non-uploaded release-prep AAB:

- Use Gradle export.
- Change export format to Android App Bundle in a reviewed release preset.
- Keep package name as `com.dementedstudios.sky_vanguard`.
- Keep app label as `Sky Vanguard`.
- Keep portrait orientation.
- Keep `android.permission.VIBRATE` only if haptics remain approved.
- Keep AdMob plugin files and production assets included.
- Export to `exports/android/sky-vanguard-release-prep.aab`.
- Do not upload to Google Play from this repository task.

## Export Packaging

The Android export preset should continue excluding:

```text
test_artifacts/*
tests/*
docs/*
debug/*
.phase13_smoke_user/*
```

Before export, verify generated or local-only files are not packaged:

- `test_artifacts/`
- screenshots
- logs
- previous APKs
- previous AABs
- `exports/`
- `android/build/`
- `.godot/`
- generated evidence textures

Do not remove production assets, AdMob plugin files, scenes, scripts, resources, launcher icons, or `.import` files for real bundled assets.

## Internal Testing Checklist

- Production AdMob Android App ID supplied and reviewed.
- Production banner ad unit supplied and reviewed.
- Production rewarded ad unit supplied and reviewed.
- Upload key exists outside the repository.
- AAB export succeeds with release signing.
- Package name is `com.dementedstudios.sky_vanguard`.
- Version code is higher than any previous Play upload.
- Version name is appropriate for internal testing.
- App launches on Android hardware.
- Portrait orientation holds.
- Touch movement works.
- Main Menu banner behavior is checked.
- Tutorial hides and restores banner as intended.
- Rewarded revive grants only after earned reward plus ad close.
- One revive per run remains enforced.
- Restart resets Score, HP, weapon, enemies, pickups, projectiles, and missiles.
- Filtered Android logs show no fatal crash, ANR, script error, or collision cleanup warning.
- AAB is not committed.
- AAB is not uploaded until the product owner explicitly approves upload.

## Known Non-Blocking Log Noise

Previous Android checks have seen harmless AdMob banner-hide diagnostics and Godot shutdown/resource-leak style warnings. Treat these separately from fatal crashes, ANRs, script errors, and collision cleanup warnings.

## Do Not Commit

- Keystores or upload keys
- Passwords or passphrases
- Private keys or certificates
- Machine-specific signing paths unless separately approved
- Production AdMob IDs unless deliberately reviewed for release
- APKs
- AABs
- `.idsig` files
- `exports/`
- generated Android build output
- `.godot/`
- `test_artifacts/`
