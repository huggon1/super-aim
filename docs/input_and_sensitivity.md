# Input and Sensitivity

V1 uses captured mouse input for FPS camera control.

- `Escape` releases the mouse.
- Left mouse button fires a raycast from the camera.
- WASD moves the player on the ground plane.
- Sensitivity, move speed, FOV, and max pitch are stored in `InputSettings`.
- Mouse look uses `InputEventMouseMotion.screen_relative` so aiming is not affected by viewport/content scaling.
- `Input.use_accumulated_input` is disabled while the player is active, allowing mouse motion events to be processed as often as possible instead of being merged once per rendered frame.
- Menu settings are saved to `user://aimlabb_settings.cfg`.

Future work can add persistent settings, scoped sensitivity, ADS multipliers, and cm/360 conversion.
