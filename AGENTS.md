# AGENTS.md

## Project Goal

Build an Aim Lab style trainer in Godot. The current priority is a playable v1 of Six Target Ultimate: 60 seconds, six active targets, instant respawn on hit, and basic results.

## Tech Stack

- Godot 4.6.
- GDScript only for v1.
- 3D FPS training scenes.
- Jolt Physics.

## Code Style

- Use `snake_case` for GDScript files, variables, functions, and signals.
- Use `PascalCase` for scene files and Godot class names.
- Keep scripts grouped by subsystem under `scripts/`.
- Keep scene files grouped by feature under `scenes/`.
- Keep gameplay logic out of UI scripts. UI scripts should display state and emit user intent.

## Architecture

- Training modes are coordinated by a session script and mode-specific scene.
- Player input and raycast shooting are owned by the player subsystem.
- Target spawning is owned by the training subsystem.
- Scoring is owned by `ScoreTracker` and should remain testable without loading a scene.
- UI receives formatted state from the training mode and should not calculate rules.

## Do Not

- Do not edit or commit `.godot/`.
- Do not commit exported builds.
- Do not leave temporary debug logic in `Main.tscn` or the main scene script.
- Do not introduce C# or plugins for v1 unless the project direction changes explicitly.

## Verification

- Prefer running Godot editor or headless checks when available.
- At minimum, manually verify menu start, six active targets, hit respawn, countdown, session finish, and results display.
- Add focused tests for pure logic where practical.

## Current Priority

Finish the Six Target Ultimate playable loop before investing in art polish, leaderboards, settings persistence, replays, or advanced analytics.
