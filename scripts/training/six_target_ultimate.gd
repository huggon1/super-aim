extends Node3D

signal training_finished(results: Dictionary)
signal restart_requested
signal menu_requested

const CONFIG := preload("res://resources/training/six_target_ultimate_config.tres")
const TARGET_SCENE := preload("res://scenes/targets/Target.tscn")

@onready var player: FPSPlayer = $FPSPlayer
@onready var spawner: TargetSpawner = $TargetSpawner
@onready var hud: TrainingHud = $HudLayer/TrainingHud

var session: TrainingSession
var score_tracker: ScoreTracker
var input_settings: InputSettings
var _has_emitted_results := false
var _is_paused := false


func _ready() -> void:
	if input_settings != null:
		player.apply_input_settings(input_settings)

	score_tracker = ScoreTracker.new()
	session = TrainingSession.new(CONFIG.duration_seconds)
	session.finished.connect(_finish_training)

	spawner.setup(TARGET_SCENE, CONFIG)
	spawner.spawn_initial_targets()

	for target in spawner.active_targets:
		target.hit.connect(_on_target_hit)

	player.fired.connect(_on_player_fired)
	hud.resume_requested.connect(resume_training)
	hud.restart_requested.connect(func() -> void: restart_requested.emit())
	hud.menu_requested.connect(func() -> void: menu_requested.emit())
	session.start()
	_update_hud()


func _process(delta: float) -> void:
	if _is_paused:
		return
	session.tick(delta)
	_update_hud()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and session.is_running():
		if _is_paused:
			resume_training()
		else:
			pause_training()
		get_viewport().set_input_as_handled()


func pause_training() -> void:
	if _is_paused or not session.is_running():
		return

	_is_paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	hud.set_paused(true)


func resume_training() -> void:
	if not _is_paused:
		return

	_is_paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hud.set_paused(false)


func _on_player_fired(was_hit: bool, _target: AimTarget) -> void:
	if _is_paused or not session.is_running():
		return
	score_tracker.record_shot(was_hit)


func _on_target_hit(target: AimTarget) -> void:
	if _is_paused or not session.is_running():
		return
	spawner.respawn_target(target)


func _finish_training() -> void:
	if _has_emitted_results:
		return
	_has_emitted_results = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	training_finished.emit(score_tracker.get_results(CONFIG.duration_seconds))


func _update_hud() -> void:
	hud.set_stats(
		session.get_remaining_seconds(),
		score_tracker.get_score(),
		score_tracker.hits,
		score_tracker.shots,
		score_tracker.get_accuracy_percent()
	)
