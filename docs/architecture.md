# Architecture

Aimlabb is organized around small gameplay subsystems that can be reused across training modes.

`Main.tscn` is the application entry point. It swaps between menu, training, and result screens.
The main menu exposes practice and entertainment categories. Practice modes and entertainment modes are routed through `Main.gd` but own their gameplay rules in separate scenes.

Training scenes own mode rules. `SixTargetUltimate.tscn` creates a `TrainingSession`, a `ScoreTracker`, and a `TargetSpawner`, then forwards state to the HUD.

The player subsystem owns movement, mouse capture, camera pitch/yaw, and raycast shooting. It emits shot events instead of knowing scoring rules.
`WeaponRaycast` remains compatible with training targets and can also apply damage to combat hitboxes for entertainment modes.

Targets are generic `Area3D` nodes. They emit a hit signal and can be respawned by the active training mode.

Entertainment deathmatch uses health components, damage hitboxes, simple bot controllers, and mode-local scoring. These systems do not own training scoring or target spawning rules.

UI scripts only display values and emit user intent. They should not own gameplay rules or scoring formulas.
