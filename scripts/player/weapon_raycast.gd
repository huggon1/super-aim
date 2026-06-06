class_name WeaponRaycast
extends Node

signal fired(was_hit: bool, target: AimTarget)

@export var camera_path: NodePath
@export var max_distance := 1000.0

@onready var camera: Camera3D = get_node(camera_path)


func fire() -> void:
	var origin := camera.global_position
	var end := origin + (-camera.global_transform.basis.z * max_distance)
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result := camera.get_world_3d().direct_space_state.intersect_ray(query)
	var target := _extract_target(result.get("collider"))
	var was_hit := target != null

	if was_hit:
		target.handle_hit()

	fired.emit(was_hit, target)


func _extract_target(collider: Variant) -> AimTarget:
	if collider is AimTarget:
		return collider
	return null
