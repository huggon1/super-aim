# Training Modes

Every training mode should follow the same lifecycle:

1. Prepare the scene, config, player, spawner, HUD, and score tracker.
2. Start a `TrainingSession`.
3. Record shots and mode-specific events while the session is running.
4. Finish when the session timer expires or the mode requests completion.
5. Emit a result dictionary for the app shell to display.

Mode scripts can have unique spawn rules and scoring modifiers, but shared timing and basic score tracking should stay reusable.
