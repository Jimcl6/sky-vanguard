# Sky Vanguard Android Release Prep

This checklist prepares Sky Vanguard for a future Google Play Internal Testing upload. It must not contain keystore passwords, private keys, Play Console credentials, or production AdMob values until those values are intentionally supplied and reviewed.

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
- Production Android app ID: not supplied
- Production banner unit ID: not supplied
- Production rewarded unit ID: not supplied

Do not replace the test IDs with guessed values. A production Play export must use real IDs from the AdMob account:

- Android App ID format: `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`
- Banner Ad Unit format: `ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ`
- Rewarded Ad Unit format: `ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ`

Keep debug/internal exports on Google test IDs until the production IDs are available. Do not add app-open ads, interstitial ads, native ads, consent flow, or additional ad formats without a separate approved task.

## Release Signing And Upload Key

Release signing is not configured in the repository. Do not commit keystores, passwords, aliases, private keys, or local machine paths.

Recommended upload-key storage location:

```text
C:\Users\ai.pc\Documents\Godot Release Keys\sky-vanguard-upload.jks
```

If a Godot export preset references a local keystore path, remember that `export_presets.cfg` is a tracked file in this repository. Prefer either a local-only workflow that does not commit the path, or a separately reviewed release preset policy before storing any machine-specific signing path.

Before building an upload-ready AAB:

- Create or locate the Google Play upload key outside the repository.
- Confirm the keystore backup location.
- Enter signing values only in a local environment.
- Verify no credentials are printed in logs or written to docs.
- Verify `.gitignore` covers `*.jks`, `*.keystore`, `*.p12`, `*.pem`, `*.key`, and `*.idsig`.

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
