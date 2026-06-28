class_name DeathmatchBot
extends CharacterBody3D

signal killed(bot: DeathmatchBot, source: Node)

@export var move_speed := 3.8
@export var sight_range := 24.0
@export var fire_interval := 0.38
@export var damage := 18.0
@export var aim_spread_degrees := 1.25
@export var reaction_time := 0.28
@export_range(0.0, 1.0) var accuracy := 0.58

@onready var health: HealthComponent = $HealthComponent
@onready var model_root: Node3D = $ModelRoot
@onready var muzzle_flash: Sprite3D = $ModelRoot/MuzzleFlash
@onready var shoot_audio: AudioStreamPlayer3D = $ShootAudio
@onready var hurt_audio: AudioStreamPlayer3D = $HurtAudio
@onready var destroy_audio: AudioStreamPlayer3D = $DestroyAudio

var target: Node3D
var patrol_points: Array[Vector3] = []
var _patrol_index := 0
var _fire_cooldown := 0.0
var _spawn_position := Vector3.ZERO
var _seen_timer := 0.0
var _last_seen_position := Vector3.ZERO
var _state := "idle"


func _ready() -> void:
	_spawn_position = global_position
	health.died.connect(_on_died)
	health.damaged.connect(_on_damaged)
	muzzle_flash.visible = false


func _physics_process(delta: float) -> void:
	_fire_cooldown = maxf(0.0, _fire_cooldown - delta)
	if not health.is_alive:
		velocity = Vector3.ZERO
		return

	if target != null and _can_see_target():
		_seen_timer += delta
		_last_seen_position = _get_target_position()
		_face_target()
		_set_state("aim")
		velocity = _get_strafe_velocity(delta)
		move_and_slide()
		if _seen_timer >= reaction_time:
			_try_fire()
		return

	_seen_timer = 0.0
	if _last_seen_position != Vector3.ZERO and global_position.distance_to(_last_seen_position) > 1.2:
		_move_to_last_seen()
		return

	_patrol(delta)


func respawn(at_position: Vector3) -> void:
	global_position = at_position
	_spawn_position = at_position
	visible = true
	model_root.scale = Vector3.ONE
	model_root.rotation_degrees = Vector3.ZERO
	set_physics_process(true)
	health.reset()
	_seen_timer = 0.0
	_last_seen_position = Vector3.ZERO
	_set_state("idle")


func handle_damage(amount: float, source: Node = null) -> void:
	health.apply_damage(amount, source)


func _patrol(_delta: float) -> void:
	if patrol_points.is_empty():
		velocity = Vector3.ZERO
		_set_state("idle")
		return

	var destination := patrol_points[_patrol_index]
	var to_destination := destination - global_position
	to_destination.y = 0.0
	if to_destination.length() < 0.35:
		_patrol_index = (_patrol_index + 1) % patrol_points.size()
		return

	velocity = to_destination.normalized() * move_speed
	look_at(global_position + velocity, Vector3.UP)
	_set_state("run")
	move_and_slide()


func _move_to_last_seen() -> void:
	var to_destination := _last_seen_position - global_position
	to_destination.y = 0.0
	if to_destination.length() < 1.2:
		_last_seen_position = Vector3.ZERO
		_set_state("idle")
		return

	velocity = to_destination.normalized() * move_speed * 1.08
	look_at(global_position + velocity, Vector3.UP)
	_set_state("run")
	move_and_slide()


func _can_see_target() -> bool:
	if target == null:
		return false

	var target_position := _get_target_position()
	if global_position.distance_to(target_position) > sight_range:
		return false

	var origin := global_position + Vector3.UP * 1.45
	var query := PhysicsRayQueryParameters3D.create(origin, target_position)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.exclude = _collect_own_rids()
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	var collider = result.get("collider")
	if collider == target:
		return true
	return collider is DamageHitbox and collider.health_component.get_parent() == target


func _face_target() -> void:
	var flat_target := _get_target_position()
	flat_target.y = global_position.y
	look_at(flat_target, Vector3.UP)


func _get_strafe_velocity(_delta: float) -> Vector3:
	var to_target := _get_target_position() - global_position
	to_target.y = 0.0
	var desired_distance := 8.0
	var forward := to_target.normalized()
	var right := forward.cross(Vector3.UP).normalized()
	var range_error := clampf(to_target.length() - desired_distance, -1.0, 1.0)
	var strafe := sin(Time.get_ticks_msec() * 0.002 + float(get_instance_id() % 17)) * 0.65
	return ((forward * range_error) + (right * strafe)).normalized() * move_speed


func _try_fire() -> void:
	if _fire_cooldown > 0.0:
		return

	_fire_cooldown = fire_interval
	var origin := global_position + Vector3.UP * 1.45
	var direction := (_get_target_position() - origin).normalized()
	direction = _apply_aim_spread(direction)
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * sight_range)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.exclude = _collect_own_rids()
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	var collider = result.get("collider")
	_play_shoot_feedback()
	if collider is Node and collider.has_method("handle_damage"):
		collider.handle_damage(damage, self)


func _apply_aim_spread(direction: Vector3) -> Vector3:
	var spread := deg_to_rad(aim_spread_degrees * lerpf(1.8, 0.45, accuracy))
	var x := randf_range(-spread, spread)
	var y := randf_range(-spread, spread)
	var right := direction.cross(Vector3.UP).normalized()
	if right.length() < 0.01:
		right = Vector3.RIGHT
	var up := right.cross(direction).normalized()
	return (direction + right * x + up * y).normalized()


func _get_target_position() -> Vector3:
	if target == null:
		return global_position
	if target.has_node("Head"):
		return target.get_node("Head").global_position
	return target.global_position + Vector3.UP * 1.3


func _collect_own_rids() -> Array[RID]:
	var rids: Array[RID] = []
	rids.append(get_rid())
	for child in get_children():
		if child is CollisionObject3D:
			rids.append(child.get_rid())
	return rids


func _set_state(next_state: String) -> void:
	if _state == next_state:
		return

	_state = next_state
	if _state == "idle":
		model_root.rotation_degrees = Vector3.ZERO
	elif _state == "run":
		model_root.rotation_degrees.z = 5.0
	elif _state == "aim":
		model_root.rotation_degrees.x = -4.0


func _play_shoot_feedback() -> void:
	_set_state("shoot")
	muzzle_flash.visible = true
	muzzle_flash.modulate.a = 1.0
	muzzle_flash.rotation_degrees.z = randf_range(-30.0, 30.0)
	shoot_audio.play()

	var tween := create_tween()
	tween.tween_property(muzzle_flash, "modulate:a", 0.0, 0.06)
	tween.tween_callback(func() -> void: muzzle_flash.visible = false)
	tween.parallel().tween_property(model_root, "rotation_degrees:x", -8.0, 0.03)
	tween.tween_property(model_root, "rotation_degrees:x", -4.0, 0.08)


func _on_damaged(_amount: float, _source: Node) -> void:
	hurt_audio.play()


func _on_died(source: Node) -> void:
	_set_state("death")
	destroy_audio.play()
	set_physics_process(false)
	var tween := create_tween()
	tween.tween_property(model_root, "rotation_degrees:z", 90.0, 0.18)
	tween.parallel().tween_property(model_root, "scale", Vector3.ONE * 0.35, 0.18)
	tween.tween_callback(func() -> void: visible = false)
	killed.emit(self, source)
