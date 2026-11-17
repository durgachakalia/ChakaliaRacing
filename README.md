# Chakalia Racing

**Developer: Chakalia Systems**

A native Android low-poly 3D arcade racing prototype built with Java and OpenGL ES 2.0.

## Features
- 3D road, lane markers, player car, traffic vehicles, roadside scenery and collectible coins.
- Career mode with score-based level progression.
- Endless mode focused on surviving and collecting coins.
- Touch steering, accelerator, brake and nitro controls.
- Optional accelerometer tilt steering.
- Pause, return to menu, score and coin counter.
- Custom launcher icon.
- GitHub Actions workflow builds a debug APK.

## Build an APK with GitHub
1. Create a repository named `ChakaliaRacing`.
2. Extract this ZIP and upload the **contents** of the `ChakaliaRacing` folder to the repository root (not the ZIP itself).
3. Commit to the `main` branch.
4. Open **Actions** and select **Build Chakalia Racing APK**.
5. Wait for the green success check.
6. Open the successful run, scroll to **Artifacts**, and download `Chakalia-Racing-APK`.
7. Extract the artifact ZIP and install `app-debug.apk` on your Android phone. Allow installs from your file manager if Android asks.

## Controls
- Hold ◀ / ▶ to steer.
- Hold GAS to accelerate; BRAKE to slow down.
- Hold NITRO for a speed boost.
- Tap TILT OFF to enable accelerometer steering; tilt your phone left/right in landscape.
- Tap Ⅱ to pause/resume; MENU returns to mode selection.

## Technical details
- App name: Chakalia Racing
- Package: `com.chakalia.racing`
- Minimum Android: 6.0 (API 23)
- Android Gradle Plugin 8.6.1, Gradle 8.7, JDK 17
- OpenGL ES 2.0; no third-party game engine or runtime libraries.

This is a playable low-poly arcade prototype, not a photorealistic commercial racing simulator. Career mode currently uses score-based level progression.
