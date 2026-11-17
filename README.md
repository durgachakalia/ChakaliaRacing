# Chakalia Racing — Chakalia Systems

An Android OpenGL ES 2.0 arcade-driving prototype with career and endless modes, traffic, collectible coins, accelerometer steering, touch steering, throttle, brake, nitro, pause and a low-poly 3D city/vehicle scene.

## Build a real APK with GitHub Actions

1. Create a GitHub repository named `ChakaliaRacing`.
2. Upload the **contents** of this folder (including the hidden `.github` folder) to the repository root.
3. Open **Actions** and run **Build and verify Chakalia Racing APK** (or push to `main`).
4. Wait for the green workflow result. The workflow checks that the APK exists, is larger than 500 KB, verifies its Android signing certificate, and checks the package/app label.
5. Open the completed run and download the `Chakalia-Racing-Verified-APK` artifact. Extract it and install `app-debug.apk` on an Android device.

## Important verification note

The GitHub workflow performs an actual Android Gradle build and APK/signature/package checks. This source package has not been run on a physical Android phone in this workspace. A successful workflow verifies packaging and signing, not every gameplay interaction or device-specific performance. Test steering, pause/resume, collision handling and screen scaling on your phone before public release.

## Game scope

This is a lightweight, original low-poly arcade driving game, not a clone of Dr. Driving and not a photorealistic simulator. Cars, road, buildings and street furniture are drawn procedurally with OpenGL ES. It does not bundle commercial game assets.

Developer: **Chakalia Systems**
