---
name: run
description: Build and launch the Callory Flutter app on an Android emulator on this Windows machine. Use whenever asked to run, launch, or screenshot the app.
---

# Running Callory

Flutter app. No backend. Windows desktop build and web build are **not
viable** here — see "Why not other targets" below. Android emulator is
the only working target on this machine.

## One-time environment setup

Skip any step whose artifact already exists.

### 1. Android SDK (cmdline-tools only, no Android Studio)

SDK root on this machine: `E:\work\android` (already has cmdline-tools,
platform-tools, build-tools 34/36, platforms 34/35/36, one system image).
If missing, follow https://github.com/maiz-an/AVD-Setup-without-Andriod-Studio
to lay down `cmdline-tools/latest`, `platform-tools`, a `system-images`
entry, and license acceptances under that root.

Point Flutter at it once:

```bash
flutter config --android-sdk "E:\work\android"
```

### 2. Create the AVD (once)

```bash
export ANDROID_SDK_ROOT=/e/work/android
export ANDROID_HOME=/e/work/android
export JAVA_HOME="D:\Program Files\java\jdk-17.0.2"   # avdmanager needs a real JDK, not the ancient default
echo "no" | "E:/work/android/cmdline-tools/latest/bin/avdmanager.bat" create avd \
  -n callory_avd \
  -k "system-images;android-34;google_apis;x86_64" \
  -d pixel_6
```

Verify: `flutter emulators` should list `callory_avd`.

### 3. Gradle/Kotlin build config fixes (already committed, don't redo)

Three real bugs, not one-off flukes — fixed in the repo, listed here so
nobody "fixes" them again or reverts them by accident:

- `android/gradle.properties` has `kotlin.incremental=false`. Without it,
  the Kotlin daemon crashes computing a relative path between the pub
  cache (`C:\Users\...`) and the project (`E:\work\...`) — a Windows-only
  cross-drive bug in Kotlin's incremental compiler. Symptom:
  `IllegalArgumentException: this and base files have different roots`.
- `android/app/build.gradle.kts` hardcodes `compileSdk = 36` instead of
  `flutter.compileSdkVersion`.
- `android/build.gradle.kts` force-bumps every Android-library subproject
  to `compileSdk = 36` via an `afterEvaluate` hook. `file_picker` ships
  compiled against API 34, but its transitive dep
  `flutter_plugin_android_lifecycle` requires 36+. Without the hook,
  `file_picker:checkDebugAarMetadata` fails.

If `flutter run` fails with any of the errors above, the fix already
exists in these three files — check `git log` on them before touching
anything.

## Every run

`JAVA_HOME` on this machine defaults to a Java 8 build so old its cacert
store can't TLS-handshake `services.gradle.org` (`PKIX path building
failed`). Always override it to a real JDK for Gradle:

```bash
export JAVA_HOME="D:\Program Files\java\jdk-17.0.2"
export ANDROID_SDK_ROOT=/e/work/android
export ANDROID_HOME=/e/work/android
```

Boot the emulator and wait for it, rather than racing `flutter run`
against a still-booting device:

```bash
flutter emulators --launch callory_avd   # run in background
export PATH="/e/work/android/platform-tools:$PATH"
adb wait-for-device
until [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ]; do sleep 3; done
```

Then launch (run in background — this is a long-lived hot-reload
session, it won't exit on its own):

```bash
flutter run -d emulator-5554
```

First build after a clean/cache-wipe takes several minutes (Gradle
distribution download, NDK, extra SDK platforms auto-install). Watch the
output file for `BUILD FAILED`, `error:`, or the `Syncing files to
device` / `Installing build` success markers rather than guessing a
sleep duration.

## Interacting / screenshotting

```bash
export PATH="/e/work/android/platform-tools:$PATH"
adb exec-out screencap -p > screenshot.png
```

Use `adb shell input tap X Y` / `adb shell input text "..."` to drive
the UI, or hot-reload by sending `r` to the running `flutter run`
process.

## Why not other targets

- **Windows desktop** (`flutter run -d windows`): needs Developer Mode
  enabled (symlink support) *and* Visual Studio's "Desktop development
  with C++" workload. Neither installed on this machine as of the setup
  above.
- **Chrome/web** (`flutter run -d chrome`): architecturally impossible,
  not just unconfigured — `lib/db/database.dart` uses `dart:io`
  (`File`, `path_provider`) directly via Drift's `NativeDatabase`. That
  import doesn't compile for web at all. Would need a separate
  `WasmDatabase`/`drift/wasm` code path, which doesn't exist in this
  codebase.
