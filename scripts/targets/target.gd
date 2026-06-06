class_name AimTarget
extends Area3D

signal hit(target: AimTarget)

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	add_to_group("targets")


func set_radius(radius: float) -> void:
	var safe_radius := maxf(0.05, radius)
	scale = Vector3.ONE * safe_radius

	var sphere_shape := collision_shape.shape as SphereShape3D
	if sphere_shape != null:
		sphere_shape.radius = 1.0


func handle_hit() -> void:
	hit.emit(self)
