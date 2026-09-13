# Sky Vanguard Android Release Prep

This checklist prepares Sky Vanguard for a future Google Play Internal Testing upload. It must not contain keystore passwords, private keys, Play Console credentials, or signing secrets.

## Release Identity

- Package name: `com.dementedstudios.sky_vanguard`
- App label: `Sky Vanguard`
- Current Android preset: `Android Debug`
- Current export output: `exports/android/sky-vanguard-debug.apk`
- Release AAB preset: `Android Release AAB`
- Release AAB output: `exports/android/sky-vanguard-internal-0.1.0.aab`
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

The `Admob` node controls test vs production mode with `is_real`. The signed internal AAB release candidate sets `is_real = true` in `scenes/core/Main.tscn`, so the exported release uses the configured production AdMob IDs. For debug validation builds, switch this value back to false or remove the committed override before exporting so Google test ads are used again.

Do not click or repeatedly test real production ads. If testing before Play release, prefer the committed test-ad mode unless a production-ad validation task is explicitly approved. Do not add app-open ads, interstitial ads, native ads, consent flow, or additional ad formats without a separate approved task.

## Release Signing And Upload Key

Release signing secrets are not configured in the repository. Do not commit keystores, passwords, aliases, private keys, or local machine paths.

Recommended upload-key storage location:

```text
<outside-repository secure keys folder>\sky-vanguard-upload.jks
```

The upload key has been created outside the repository for this release-prep pass. Keep it backed up privately and do not copy it into the repository, `exports/`, `android/`, `.godot/`, or `test_artifacts/`.

The current repository workflow keeps the tracked release preset free of keystore paths and passwords. Godot 4.7 supports Android export environment variables that override export-menu keystore fields during export:

```text
GODOT_ANDROID_KEYSTORE_RELEASE_PATH
GODOT_ANDROID_KEYSTORE_RELEASE_USER
GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD
```

Use those values only in the local terminal session that performs the release export. Do not save them in Git, docs, screenshots, logs, shell profiles, or shared notes.

If a Godot export preset references a local keystore path, remember that `export_presets.cfg` is a tracked file in this repository. Prefer the environment-variable workflow above instead of storing a machine-specific signing path.

Before building an upload-ready AAB:

- Create or locate the Google Play upload key outside the repository.
- Confirm the keystore backup location.
- Enter signing values only in a local environment.
- Verify no credentials are printed in logs or written to docs.
- Verify `.gitignore` covers `*.jks`, `*.keystore`, `*.p12`, `*.pem`, `*.key`, and `*.idsig`.
- Switch `Admob.is_real` to true only in the reviewed release configuration.
- Confirm the Android manifest receives the production AdMob app ID during export.

## AAB Export Plan

Current debug preset exports an APK because `gradle_build/export_format=0`.

The tracked release preset is named `Android Release AAB` and is configured for Android App Bundle export because `gradle_build/export_format=1`.

For a future non-uploaded release-prep AAB:

- Use Gradle export with the `Android Release AAB` preset.
- Keep package name as `com.dementedstudios.sky_vanguard`.
- Keep app label as `Sky Vanguard`.
- Keep portrait orientation.
- Keep `android.permission.VIBRATE` only if haptics remain approved.
- Keep AdMob plugin files and production assets included.
- Export to `exports/android/sky-vanguard-internal-0.1.0.aab`.
- Do not upload to Google Play from this repository task.

Example local-only release export flow after the upload key exists:

```powershell
$env:GODOT_ANDROID_KEYSTORE_RELEASE_PATH = "<outside-repository secure keys folder>\sky-vanguard-upload.jks"
$env:GODOT_ANDROID_KEYSTORE_RELEASE_USER = "sky-vanguard-upload"
$env:GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD = "<type locally; do not paste into chat or commit>"
& "<Godot 4.7.1 console path>" --headless --path . --export-release "Android Release AAB" "exports/android/sky-vanguard-internal-0.1.0.aab"
Remove-Item Env:\GODOT_ANDROID_KEYSTORE_RELEASE_PATH
Remove-Item Env:\GODOT_ANDROID_KEYSTORE_RELEASE_USER
Remove-Item Env:\GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD
```

Only run the release export after `Admob.is_real = true` has been reviewed for the release candidate and the upload key exists outside the repository.

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
- `Admob.is_real` is intentionally set to true for the release candidate.
- AAB export succeeds with release signing.
- Package name is `com.dementedstudios.sky_vanguard`.
- Version code is higher than any previous Play upload.
- Version name is appropriate for internal testing.
- AAB signature is verified before upload.
- AAB manifest contains the production AdMob Android App ID.
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

## Pre-Upload Verification

Before any Google Play upload, verify:

```text
package: com.dementedstudios.sky_vanguard
versionName: 0.1.0
versionCode: 1
format: AAB
signed with upload key
production AdMob app ID in manifest
test_artifacts/docs/tests/debug excluded
```

Do not interact with real ads during this verification. Confirm only configuration and launch behavior unless a separate real-ad validation task is approved.

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
