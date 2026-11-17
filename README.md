# Chakalia Racing — Complete Godot 4 Project
**Developer / brand:** Chakalia Systems  
**Package ID target:** `com.chakalia.racing`

This archive contains the complete editable Godot project source for a 3D driving prototype.

## Included
- Procedural 3D city road environment, sidewalks, buildings, windows, crosswalk and parking-bay markings
- Player vehicle assembled from 3D meshes, metallic paint, glass, wheels and lights
- Chase camera and cockpit-style camera position toggle
- Keyboard and on-screen touch controls
- Traffic vehicles with collision bodies
- Collectible coins
- Career checkpoints and endless mode toggle
- Basic car colour selection and reset
- Android export preset and a GitHub Actions workflow starter

## Honest scope and asset note
This is a complete **prototype source project**, not a finished commercial-quality game. The cars and city are generated from Godot primitive meshes; they are not photorealistic imported car models. The current prototype does not include licensed high-detail vehicle models, full cockpit interiors, polished parking mission scoring, advanced traffic AI, engine audio, tyre physics, or a production garage/upgrades economy. Those require additional 3D assets, audio, gameplay iteration and device testing.

The ZIP is intentionally a source project. A tiny ZIP or APK is not made realistic by increasing file size. A properly asset-rich game will become substantially larger after adding model, texture, animation and audio packs.

## Open in Godot
1. Install Godot 4.x (4.3 or newer recommended).
2. Extract this ZIP.
3. Open Godot Project Manager → Import.
4. Select the extracted `project.godot`.
5. Open the project and press F6/F5.

### Desktop controls
- W / Up: accelerate
- S / Down: brake / reverse
- A / Left and D / Right: steer
- Space: handbrake
- C: camera toggle (touch button is also available)

### Mobile controls
On-screen touch buttons are included for steering, accelerator, brake/reverse, handbrake, camera, mode, reset and car colour selection.

## Android export
1. In Godot, install the matching Export Templates (Editor → Manage Export Templates).
2. Configure Android SDK and Java SDK paths in Editor Settings → Export → Android.
3. Open Project → Export, choose Android, and export `Chakalia-Racing.apk`.
4. Test the APK on a real Android device.

The included GitHub workflow is a starter workflow and may need runner/toolchain adjustments. No successful Android build or physical-device test is claimed by this archive.

## Project structure
- `project.godot` — project settings and input actions
- `scenes/Main.tscn` — main scene
- `scripts/Game.gd` — world, missions, traffic, UI and gameplay orchestration
- `scripts/Vehicle.gd` — arcade vehicle movement and touch input
- `scripts/CameraRig.gd` — chase/cockpit camera
- `scripts/TrafficVehicle.gd` — traffic movement
- `scripts/Coin.gd` — coin pickup logic
- `export_presets.cfg` — Android package/export preset
