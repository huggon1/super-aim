class_name TargetSpawner
extends Node3D

@export var target_scene: PackedScene
@export var config: SixTargetUltimateConfig

var active_targets: Array[AimTarget] = []
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()


func setup(spawn_target_scene: PackedScene, spawn_config: SixTargetUltimateConfig) -> void:
	target_scene = spawn_target_scene
	config = spawn_config


func spawn_initial_targets() -> void:
	clear_targets()
	for i in range(config.target_count):
		_spawn_target()


func clear_targets() -> void:
	for target in active_targets:
		if is_instance_valid(target):
			target.queue_free()
	active_targets.clear()


func respawn_target(target: AimTarget) -> void:
	if not is_instance_valid(target):
		return

	target.global_position = _get_spawn_position(target)


func get_active_target_count() -> int:
	var count := 0
	for target in active_targets:
		if is_instance_valid(target):
			count += 1
	return count


func _spawn_target() -> void:
	var target := target_scene.instantiate() as AimTarget
	add_child(target)
	target.set_radius(config.target_radius)
	target.global_position = _get_spawn_position(target)
	active_targets.append(target)


func _get_spawn_position(target_to_ignore: AimTarget = null) -> Vector3:
	var best_position := Vector3.ZERO
	for attempt in range(32):
		var candidate := _random_position()
		if _is_position_valid(candidate, target_to_ignore):
			return candidate
		best_position = candidate
	return best_position


func _random_position() -> Vector3:
	var angle := deg_to_rad(_rng.randf_range(-config.horizontal_angle_degrees, config.horizontal_angle_degrees))
	var distance := _rng.randf_range(config.min_spawn_distance, config.max_spawn_distance)
	var height := _rng.randf_range(config.min_height, config.max_height)
	return Vector3(sin(angle) * distance, height, -cos(angle) * distance)


func _is_position_valid(candidate: Vector3, target_to_ignore: AimTarget) -> bool:
	for target in active_targets:
		if target == target_to_ignore or not is_instance_valid(target):
			continue
		if candidate.distance_to(target.global_position) < config.min_target_spacing:
			return false
	return true
