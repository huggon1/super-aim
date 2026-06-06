# Architecture

Aimlabb is organized around small gameplay subsystems that can be reused across training modes.

`Main.tscn` is the application entry point. It swaps between menu, training, and result screens.

Training scenes own mode rules. `SixTargetUltimate.tscn` creates a `TrainingSession`, a `ScoreTracker`, and a `TargetSpawner`, then forwards state to the HUD.

The player subsystem owns movement, mouse capture, camera pitch/yaw, and raycast shooting. It emits shot events instead of knowing scoring rules.

Targets are generic `Area3D` nodes. They emit a hit signal and can be respawned by the active training mode.

UI scripts only display values and emit user intent. They should not own gameplay rules or scoring formulas.
