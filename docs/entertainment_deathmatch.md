# Entertainment Deathmatch

`EntertainmentDeathmatch.tscn` is a local horde survival mode inspired by FPS survival pacing. It uses one rifle-like weapon, a compact sci-fi arena, melee infected enemies, health, respawn protection, ongoing infected spawns, and a timed score loop.

The mode intentionally avoids Valorant-owned assets, names, maps, sounds, and characters. The v2 visual pass imports CC0 Kenney FPS Starter Kit assets for the first-person rifle, temporary infected model, muzzle/impact sprites, audio, and arena dressing modules.

Core rules:

- 90 second match timer.
- Player earns 100 score per infected kill and loses 25 score per death.
- Player respawns with a short invulnerability shield; infected continuously respawn from safer spawn points.
- Rifle fire has high first-shot accuracy, sustained-fire spread, movement inaccuracy, and small recoil.
- Infected patrol, line-of-sight check the player, react after a short delay, chase the last seen player position, attack only in melee range, die with visual/audio feedback, and return through the horde spawn system.
- The player camera includes a first-person weapon viewmodel, muzzle flash, tracer, impact feedback, weapon kick, and shooting audio.
