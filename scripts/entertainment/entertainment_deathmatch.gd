extends Node3D

signal match_finished(results: Dictionary)
signal restart_requested
signal menu_requested

const MATCH_DURATION_SECONDS := 90.0
const RESPAWN_DELAY_SECONDS := 1.4
const RESPAWN_INVULNERABILITY_SECONDS := 2.75
const BOT_SPAWN_SUPPRESSION_SECONDS := 2.0
const INITIAL_INFECTED_COUNT := 2
const MAX_ACTIVE_INFECTED := 4
const INFECTED_SPAWN_INTERVAL_SECONDS := 2.6

@onready var player: FPSPlayer = $FPSPlayer
@onready var player_health: HealthComponent = $FPSPlayer/HealthComponent
@onready var hud: DeathmatchHud = $HudLayer/DeathmatchHud
@onready var bots_root: Node3D = $Bots
@onready var bot_spawns_root: Node3D = $BotSpawns
@onready var player_spawns_root: Node3D = $PlayerSpawns
@onready var patrol_points_root: Node3D = $PatrolPoints

var input_settings: InputSettings
var score := DeathmatchScore.new()
var _remaining_seconds := MATCH_DURATION_SECONDS
var _is_paused := false
var _is_finished := false
var _rng := RandomNumberGenerator.new()
var _spawn_timer := 0.0


func _ready() -> void:
	_rng.randomize()
	if input_settings != null:
		player.apply_input_settings(input_settings)

	player.fired.connect(_on_player_fired)
	player.combat_hit.connect(_on_player_combat_hit)
	player_health.died.connect(_on_player_died)
	hud.resume_requested.connect(resume_match)
	hud.restart_requested.connect(_request_restart)
	hud.menu_requested.connect(_request_menu)

	var patrol_points := _collect_positions(patrol_points_root)
	for bot in bots_root.get_children():
		if bot is DeathmatchBot:
			bot.target = player
			bot.patrol_points = patrol_points
			bot.killed.connect(_on_bot_killed)
			bot.deactivate()

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_spawn_player()
	for i in INITIAL_INFECTED_COUNT:
		_spawn_infected()
	_update_hud()


func _process(delta: float) -> void:
	if _is_paused or _is_finished:
		return

	_remaining_seconds = maxf(0.0, _remaining_seconds - delta)
	_spawn_timer = maxf(0.0, _spawn_timer - delta)
	if _spawn_timer <= 0.0 and _get_active_infected_count() < MAX_ACTIVE_INFECTED:
		_spawn_infected()
		_spawn_timer = INFECTED_SPAWN_INTERVAL_SECONDS

	_update_hud()
	if _remaining_seconds <= 0.0:
		_finish_match()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not _is_finished:
		if _is_paused:
			resume_match()
		else:
			pause_match()
		get_viewport().set_input_as_handled()


func pause_match() -> void:
	if _is_paused:
		return
	_is_paused = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	hud.process_mode = Node.PROCESS_MODE_ALWAYS
	hud.set_paused(true)


func resume_match() -> void:
	if not _is_paused:
		return
	_is_paused = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hud.set_paused(false)


func _request_restart() -> void:
	get_tree().paused = false
	restart_requested.emit()


func _request_menu() -> void:
	get_tree().paused = false
	menu_requested.emit()


func _on_player_fired(was_hit: bool, _target: AimTarget) -> void:
	if _is_paused or _is_finished:
		return
	score.record_shot(was_hit)


func _on_player_combat_hit(_target: Node, _hit_position: Vector3, _damage: float, is_critical: bool) -> void:
	if _is_paused or _is_finished:
		return
	hud.show_hit_feedback(is_critical)


func _on_player_died(_source: Node) -> void:
	if _is_finished:
		return
	score.record_death()
	player.reset_fire_state()
	player.visible = false
	player.set_physics_process(false)
	player.set_process_unhandled_input(false)
	await get_tree().create_timer(RESPAWN_DELAY_SECONDS).timeout
	if not _is_finished:
		_spawn_player()


func _on_bot_killed(_bot: DeathmatchBot, source: Node) -> void:
	if source == player:
		score.record_kill()
		hud.show_kill_feedback(false)


func _spawn_player() -> void:
	player.visible = true
	player.set_physics_process(true)
	player.set_process_unhandled_input(true)
	player.global_position = _pick_spawn_position(player_spawns_root)
	player.velocity = Vector3.ZERO
	player_health.reset()
	player_health.set_invulnerable(RESPAWN_INVULNERABILITY_SECONDS)
	player.reset_fire_state()
	_suppress_all_bots(BOT_SPAWN_SUPPRESSION_SECONDS)


func _pick_spawn_position(root: Node3D) -> Vector3:
	var children := root.get_children()
	if children.is_empty():
		return Vector3.ZERO
	return (children[_rng.randi_range(0, children.size() - 1)] as Node3D).global_position


func _pick_safe_infected_spawn_position() -> Vector3:
	var children := bot_spawns_root.get_children()
	if children.is_empty():
		return Vector3.ZERO

	var safe_positions: Array[Vector3] = []
	var best_position := (children[0] as Node3D).global_position
	var best_distance := -1.0
	for child in children:
		if child is Node3D:
			var candidate: Vector3 = child.global_position
			var distance := candidate.distance_to(player.global_position)
			if distance >= 10.0:
				safe_positions.append(candidate)
			if distance > best_distance:
				best_distance = distance
				best_position = candidate

	if not safe_positions.is_empty():
		return safe_positions[_rng.randi_range(0, safe_positions.size() - 1)]

	return best_position


func _collect_positions(root: Node3D) -> Array[Vector3]:
	var positions: Array[Vector3] = []
	for child in root.get_children():
		if child is Node3D:
			positions.append(child.global_position)
	return positions


func _suppress_all_bots(duration_seconds: float) -> void:
	for bot in bots_root.get_children():
		if bot is DeathmatchBot:
			bot.suppress_combat_for(duration_seconds)


func _spawn_infected() -> void:
	for bot in bots_root.get_children():
		if bot is DeathmatchBot and not bot.is_active():
			bot.respawn(_pick_safe_infected_spawn_position())
			bot.suppress_combat_for(BOT_SPAWN_SUPPRESSION_SECONDS)
			return


func _get_active_infected_count() -> int:
	var count := 0
	for bot in bots_root.get_children():
		if bot is DeathmatchBot and bot.is_active() and bot.health.is_alive:
			count += 1
	return count


func _finish_match() -> void:
	_is_finished = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	match_finished.emit(score.get_results(MATCH_DURATION_SECONDS))


func _update_hud() -> void:
	hud.set_stats(
		_remaining_seconds,
		score,
		player_health.current_health,
		player_health.max_health,
		player_health.get_invulnerability_remaining()
	)
