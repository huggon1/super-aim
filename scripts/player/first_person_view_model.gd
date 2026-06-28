class_name FirstPersonViewModel
extends Node3D

@export var tracer_lifetime := 0.08
@export var impact_lifetime := 0.18
@export var max_visual_tracer_length := 42.0

@onready var weapon_root: Node3D = $WeaponRoot
@onready var muzzle_flash: Sprite3D = $MuzzleFlash
@onready var shoot_audio: AudioStreamPlayer3D = $ShootAudio

var _base_position := Vector3.ZERO
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	_base_position = weapon_root.position
	muzzle_flash.visible = false


func play_fire_feedback(origin: Vector3, end: Vector3, was_hit: bool, is_critical: bool) -> void:
	_play_muzzle_flash()
	_play_weapon_kick()
	_spawn_tracer(origin, end)
	_spawn_impact(end, was_hit, is_critical)
	shoot_audio.play()


func _play_muzzle_flash() -> void:
	muzzle_flash.visible = true
	muzzle_flash.rotation_degrees.z = _rng.randf_range(-25.0, 25.0)
	muzzle_flash.scale = Vector3.ONE * _rng.randf_range(0.08, 0.13)

	var tween := create_tween()
	tween.tween_property(muzzle_flash, "modulate:a", 1.0, 0.01)
	tween.tween_property(muzzle_flash, "modulate:a", 0.0, 0.045)
	tween.tween_callback(func() -> void: muzzle_flash.visible = false)


func _play_weapon_kick() -> void:
	weapon_root.position = _base_position + Vector3(
		_rng.randf_range(-0.012, 0.012),
		_rng.randf_range(0.008, 0.02),
		_rng.randf_range(0.05, 0.075)
	)
	weapon_root.rotation_degrees.x = _rng.randf_range(-4.0, -2.0)
	weapon_root.rotation_degrees.z = _rng.randf_range(-1.0, 1.0)

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(weapon_root, "position", _base_position, 0.08)
	tween.parallel().tween_property(weapon_root, "rotation_degrees", Vector3.ZERO, 0.08)


func _spawn_tracer(origin: Vector3, end: Vector3) -> void:
	var tracer := MeshInstance3D.new()
	var mesh := ImmediateMesh.new()
	var material := StandardMaterial3D.new()
	var visual_end := origin + (end - origin).limit_length(max_visual_tracer_length)
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.2, 0.95, 1.0, 0.85)
	material.emission_enabled = true
	material.emission = Color(0.2, 0.95, 1.0)

	mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	mesh.surface_add_vertex(origin)
	mesh.surface_add_vertex(visual_end)
	mesh.surface_end()
	tracer.mesh = mesh
	get_tree().current_scene.add_child(tracer)

	var tween := tracer.create_tween()
	tween.tween_property(material, "albedo_color:a", 0.0, tracer_lifetime)
	tween.tween_callback(tracer.queue_free)


func _spawn_impact(hit_position: Vector3, was_hit: bool, is_critical: bool) -> void:
	if not was_hit:
		return

	var impact := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	var material := StandardMaterial3D.new()
	mesh.radius = 0.05 if not is_critical else 0.075
	mesh.height = mesh.radius * 2.0
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.1, 0.9, 1.0, 1.0) if not is_critical else Color(1.0, 0.25, 0.12, 1.0)
	material.emission_enabled = true
	material.emission = material.albedo_color
	impact.mesh = mesh
	impact.material_override = material
	get_tree().current_scene.add_child(impact)
	impact.global_position = hit_position

	var tween := impact.create_tween()
	tween.tween_property(impact, "scale", Vector3.ONE * 2.5, impact_lifetime)
	tween.parallel().tween_property(material, "albedo_color:a", 0.0, impact_lifetime)
	tween.tween_callback(impact.queue_free)
