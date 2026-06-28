# Entertainment Deathmatch

`EntertainmentDeathmatch.tscn` is a local fake-multiplayer mode inspired by tactical shooter deathmatch pacing. It uses one rifle-like weapon, a compact sci-fi arena, four combat bots, health, respawns, and a timed score loop.

The mode intentionally avoids Valorant-owned assets, names, maps, sounds, and characters. The current arena and bot visuals are built from Godot primitive meshes and project-authored materials so the first playable version has no third-party licensing risk.

Core rules:

- 90 second match timer.
- Player earns 100 score per bot kill and loses 25 score per death.
- Player and bots respawn after a short delay.
- Rifle fire has high first-shot accuracy, sustained-fire spread, movement inaccuracy, and small recoil.
- Bots patrol, line-of-sight check the player, strafe, shoot, die, and respawn.
