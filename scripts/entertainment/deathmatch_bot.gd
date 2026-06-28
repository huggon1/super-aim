class_name DeathmatchBot
extends CharacterBody3D

signal killed(bot: DeathmatchBot, source: Node)

@export var move_speed := 3.8
@export var chase_speed := 5.2
@export var sight_range := 18.0
@export var attack_range := 1.65
@export var field_of_view_degrees := 115.0
@export var attack_interval := 0.95
@export var attack_damage := 13.0
@export var reaction_time := 0.35
@export var zombie_skin: Texture2D

@onready var health: HealthComponent = $HealthComponent
@onready var model_root: Node3D = $ModelRoot
@onready var attack_flash: Sprite3D = $ModelRoot/AttackFlash
@onready var attack_audio: AudioStreamPlayer3D = $AttackAudio
@onready var hurt_audio: AudioStreamPlayer3D = $HurtAudio
@onready var destroy_audio: AudioStreamPlayer3D = $DestroyAudio

var target: Node3D
var patrol_points: Array[Vector3] = []
var _patrol_index := 0
var _attack_cooldown := 0.0
var _spawn_position := Vector3.ZERO
var _seen_timer := 0.0
var _last_seen_position := Vector3.ZERO
var _state := "idle"
var _combat_suppressed_until_msec := 0
var _is_active := true
var _model_initial_scale := Vector3.ONE
var _model_initial_rotation := Vector3.ZERO
var _model_initial_position := Vector3.ZERO
var _visual_time := 0.0
var _attack_animation_time := 0.0


func _ready() -> void:
	_spawn_position = global_position
	_model_initial_scale = model_root.scale
	_model_initial_rotation = model_root.rotation_degrees
	_model_initial_position = model_root.position
	health.died.connect(_on_died)
	health.damaged.connect(_on_damaged)
	attack_flash.visible = false
	_apply_zombie_skin()


func _physics_process(delta: float) -> void:
	if not _is_active:
		return

	_attack_cooldown = maxf(0.0, _attack_cooldown - delta)
	if not health.is_alive:
		velocity = Vector3.ZERO
		_update_visual_animation(delta)
		return

	if target != null and _can_see_target():
		_seen_timer += delta
		_last_seen_position = _get_target_position()
		_face_target()
		_set_state("chase")
		velocity = _get_chase_velocity()
		move_and_slide()
		if _seen_timer >= reaction_time and _can_attack_now():
			_try_melee_attack()
		_update_visual_animation(delta)
		return

	_seen_timer = 0.0
	if _last_seen_position != Vector3.ZERO and global_position.distance_to(_last_seen_position) > 1.2:
		_move_to_last_seen()
		_update_visual_animation(delta)
		return

	_patrol(delta)
	_update_visual_animation(delta)


func respawn(at_position: Vector3) -> void:
	global_position = at_position
	_spawn_position = at_position
	visible = true
	_is_active = true
	model_root.scale = _model_initial_scale
	model_root.rotation_degrees = _model_initial_rotation
	model_root.position = _model_initial_position
	set_physics_process(true)
	health.reset()
	_seen_timer = 0.0
	_last_seen_position = Vector3.ZERO
	_attack_animation_time = 0.0
	_set_state("idle")


func suppress_combat_for(duration_seconds: float) -> void:
	_combat_suppressed_until_msec = Time.get_ticks_msec() + int(duration_seconds * 1000.0)
	_seen_timer = 0.0
	_last_seen_position = Vector3.ZERO
	_set_state("idle")


func deactivate() -> void:
	_is_active = false
	visible = false
	set_physics_process(false)
	velocity = Vector3.ZERO


func is_active() -> bool:
	return _is_active


func handle_damage(amount: float, source: Node = null) -> void:
	if not _is_active:
		return
	if source != null:
		_last_seen_position = _get_target_position()
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

	velocity = to_destination.normalized() * chase_speed
	look_at(global_position + velocity, Vector3.UP)
	_set_state("chase")
	move_and_slide()


func _can_see_target() -> bool:
	if target == null:
		return false

	var target_position := _get_target_position()
	if global_position.distance_to(target_position) > sight_range:
		return false
	if not _is_target_in_view_cone(target_position):
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


func _is_target_in_view_cone(target_position: Vector3) -> bool:
	var to_target := target_position - global_position
	to_target.y = 0.0
	if to_target.length() < 0.01:
		return true

	var forward := -global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var angle := rad_to_deg(acos(clampf(forward.dot(to_target.normalized()), -1.0, 1.0)))
	return angle <= field_of_view_degrees * 0.5


func _face_target() -> void:
	var flat_target := _get_target_position()
	flat_target.y = global_position.y
	look_at(flat_target, Vector3.UP)


func _get_chase_velocity() -> Vector3:
	var to_target := _get_target_position() - global_position
	to_target.y = 0.0
	if to_target.length() <= attack_range * 0.82:
		return Vector3.ZERO
	return to_target.normalized() * chase_speed


func _try_melee_attack() -> void:
	if _attack_cooldown > 0.0:
		return
	if global_position.distance_to(_get_target_position()) > attack_range:
		return

	_attack_cooldown = attack_interval
	_play_attack_feedback()
	if target != null and target.has_method("handle_damage"):
		target.handle_damage(attack_damage, self)


func _can_attack_now() -> bool:
	return Time.get_ticks_msec() >= _combat_suppressed_until_msec


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


func _update_visual_animation(delta: float) -> void:
	if _state == "death":
		return

	_visual_time += delta
	_attack_animation_time = maxf(0.0, _attack_animation_time - delta)

	var target_position := _model_initial_position
	var target_rotation := _model_initial_rotation
	var speed_amount := clampf(velocity.length() / maxf(chase_speed, 0.01), 0.0, 1.0)

	if _state == "idle":
		target_position.y += sin(_visual_time * 2.4) * 0.025
		target_rotation.x += sin(_visual_time * 1.7) * 1.5
	elif _state == "run" or _state == "chase":
		var stride := _visual_time * lerpf(7.5, 10.5, speed_amount)
		target_position.y += absf(sin(stride)) * 0.11
		target_rotation.x += lerpf(-4.0, -10.0, speed_amount)
		target_rotation.z += sin(stride) * lerpf(5.0, 9.0, speed_amount)

	if _attack_animation_time > 0.0:
		var attack_progress := 1.0 - (_attack_animation_time / 0.22)
		var pulse := sin(clampf(attack_progress, 0.0, 1.0) * PI)
		target_position.z -= 0.32 * pulse
		target_rotation.x -= 18.0 * pulse

	var blend := 1.0 - pow(0.001, delta)
	model_root.position = model_root.position.lerp(target_position, blend)
	model_root.rotation_degrees = model_root.rotation_degrees.lerp(target_rotation, blend)


func _play_attack_feedback() -> void:
	_set_state("attack")
	_attack_animation_time = 0.22
	attack_flash.visible = true
	attack_flash.modulate.a = 1.0
	attack_flash.rotation_degrees.z = randf_range(-30.0, 30.0)
	attack_audio.play()

	var tween := create_tween()
	tween.tween_property(attack_flash, "modulate:a", 0.0, 0.08)
	tween.tween_callback(func() -> void: attack_flash.visible = false)


func _on_damaged(_amount: float, _source: Node) -> void:
	hurt_audio.play()


func _on_died(source: Node) -> void:
	_set_state("death")
	destroy_audio.play()
	set_physics_process(false)
	var tween := create_tween()
	tween.tween_property(model_root, "rotation_degrees:z", 90.0, 0.18)
	tween.parallel().tween_property(model_root, "scale", _model_initial_scale * 0.35, 0.18)
	tween.tween_callback(deactivate)
	killed.emit(self, source)


func _apply_zombie_skin() -> void:
	if zombie_skin == null:
		return
	_apply_zombie_skin_to_node(model_root)


func _apply_zombie_skin_to_node(node: Node) -> void:
	if node is MeshInstance3D:
		var material := StandardMaterial3D.new()
		material.albedo_texture = zombie_skin
		material.roughness = 0.75
		node.material_override = material

	for child in node.get_children():
		_apply_zombie_skin_to_node(child)
