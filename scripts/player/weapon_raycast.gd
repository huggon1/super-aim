class_name WeaponRaycast
extends Node

signal fired(was_hit: bool, target: AimTarget)
signal combat_hit(target: Node, hit_position: Vector3, damage: float, is_critical: bool)
signal shot_resolved(origin: Vector3, end: Vector3, was_hit: bool, is_critical: bool)

@export var camera_path: NodePath
@export var max_distance := 1000.0
@export var damage := 40.0
@export var critical_damage := 160.0
@export var fire_interval := 0.105
@export var base_spread_degrees := 0.08
@export var sustained_spread_degrees := 2.0

@onready var camera: Camera3D = get_node(camera_path)

var _cooldown := 0.0


func _process(delta: float) -> void:
	_cooldown = maxf(0.0, _cooldown - delta)


func fire(source: Node = null, spread_multiplier := 1.0) -> bool:
	if _cooldown > 0.0:
		return false

	_cooldown = fire_interval
	var origin := camera.global_position
	var direction := _get_shot_direction(spread_multiplier)
	var end := origin + (direction * max_distance)
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.exclude = _collect_source_rids(source)

	var result := camera.get_world_3d().direct_space_state.intersect_ray(query)
	var collider = result.get("collider")
	var target := _extract_target(collider)
	var was_hit := target != null
	var hit_position: Vector3 = result.get("position", end)
	var is_critical := false

	if was_hit:
		target.handle_hit()
	elif collider is Node and collider.has_method("handle_damage"):
		is_critical = collider is DamageHitbox and collider.is_critical
		var applied_damage := critical_damage if is_critical else damage
		collider.handle_damage(applied_damage, source)
		was_hit = true
		combat_hit.emit(collider, hit_position, applied_damage, is_critical)

	shot_resolved.emit(origin, hit_position, was_hit, is_critical)
	fired.emit(was_hit, target)
	return true


func _extract_target(collider: Variant) -> AimTarget:
	if collider is AimTarget:
		return collider
	return null


func _get_shot_direction(spread_multiplier: float) -> Vector3:
	var spread_degrees := base_spread_degrees + (sustained_spread_degrees * maxf(0.0, spread_multiplier - 1.0))
	var spread_radians := deg_to_rad(spread_degrees)
	var x := randf_range(-spread_radians, spread_radians)
	var y := randf_range(-spread_radians, spread_radians)
	var basis := camera.global_transform.basis
	return (-basis.z + basis.x * x + basis.y * y).normalized()


func _collect_source_rids(source: Node) -> Array[RID]:
	var rids: Array[RID] = []
	if source == null:
		return rids

	if source is CollisionObject3D:
		rids.append(source.get_rid())

	for child in source.get_children():
		if child is CollisionObject3D:
			rids.append(child.get_rid())

	return rids
