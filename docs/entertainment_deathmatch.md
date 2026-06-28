# Entertainment Deathmatch

`EntertainmentDeathmatch.tscn` is a local fake-multiplayer mode inspired by tactical shooter deathmatch pacing. It uses one rifle-like weapon, a compact sci-fi arena, four combat bots, health, respawns, and a timed score loop.

The mode intentionally avoids Valorant-owned assets, names, maps, sounds, and characters. The v2 visual pass imports CC0 Kenney FPS Starter Kit assets for the first-person rifle, bot model, muzzle/impact sprites, audio, and arena dressing modules.

Core rules:

- 90 second match timer.
- Player earns 100 score per bot kill and loses 25 score per death.
- Player and bots respawn after a short delay.
- Rifle fire has high first-shot accuracy, sustained-fire spread, movement inaccuracy, and small recoil.
- Bots patrol, line-of-sight check the player, react after a short delay, strafe, shoot with muzzle/audio feedback, chase the last seen player position, die with visual/audio feedback, and respawn.
- The player camera includes a first-person weapon viewmodel, muzzle flash, tracer, impact feedback, weapon kick, and shooting audio.
