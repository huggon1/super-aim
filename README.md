# Super Aim

Super Aim is a Godot 4.6 desktop aim trainer prototype. The first training mode is Six Target Ultimate: six active targets, a timed session, scoring, pause/restart flow, mouse sensitivity, and FOV settings.

## Requirements

- Godot 4.6.3 or newer compatible 4.6 build.
- Windows is the current target platform.

## Run Locally

Open `project.godot` in Godot and run the main scene.

From a terminal with Godot available:

```powershell
godot --path . --editor
godot --path .
```

## Controls

- WASD: move
- Mouse: aim
- Left click: shoot
- Esc: pause/resume menu

## Release Builds

The repository includes a GitHub Actions workflow that runs on every push to `main`. It downloads Godot 4.6.3 and official export templates, exports the `Windows Desktop` preset, and publishes a portable Windows release asset.

The Windows preset embeds the PCK into the executable, so the primary output is a no-installer `.exe`.
