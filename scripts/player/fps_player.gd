class_name FPSPlayer
extends CharacterBody3D

signal fired(was_hit: bool, target: AimTarget)
signal combat_hit(target: Node, hit_position: Vector3, damage: float, is_critical: bool)

@export var input_settings: InputSettings

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var weapon: WeaponRaycast = $WeaponRaycast
@onready var view_model: Node = $Head/Camera3D/FirstPersonViewModel

var _pitch := 0.0
var _is_trigger_held := false
var _sustained_fire := 0.0


func _ready() -> void:
	if input_settings == null:
		input_settings = InputSettings.new()

	Input.use_accumulated_input = false
	apply_input_settings(input_settings)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	weapon.fired.connect(_on_weapon_fired)
	weapon.combat_hit.connect(_on_weapon_combat_hit)
	weapon.shot_resolved.connect(_on_weapon_shot_resolved)


func _physics_process(delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (global_transform.basis * Vector3(input_vector.x, 0.0, input_vector.y)).normalized()
	velocity.x = direction.x * input_settings.move_speed
	velocity.z = direction.z * input_settings.move_speed
	move_and_slide()

	if _is_trigger_held and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if weapon.fire(self, _get_weapon_spread_multiplier()):
			_sustained_fire = minf(1.0, _sustained_fire + 0.12)
			_apply_recoil()
	else:
		_sustained_fire = maxf(0.0, _sustained_fire - delta * 3.0)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var mouse_delta: Vector2 = event.screen_relative
		rotate_y(-mouse_delta.x * input_settings.mouse_sensitivity)
		_pitch = clampf(
			_pitch - mouse_delta.y * input_settings.mouse_sensitivity,
			deg_to_rad(-input_settings.max_pitch_degrees),
			deg_to_rad(input_settings.max_pitch_degrees)
		)
		head.rotation.x = _pitch

	if event.is_action_pressed("shoot") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_is_trigger_held = true

	if event.is_action_released("shoot"):
		_is_trigger_held = false


func _on_weapon_fired(was_hit: bool, target: AimTarget) -> void:
	fired.emit(was_hit, target)


func _on_weapon_combat_hit(target: Node, hit_position: Vector3, damage: float, is_critical: bool) -> void:
	combat_hit.emit(target, hit_position, damage, is_critical)


func _on_weapon_shot_resolved(origin: Vector3, end: Vector3, was_hit: bool, is_critical: bool) -> void:
	view_model.play_fire_feedback(origin, end, was_hit, is_critical)


func apply_input_settings(settings: InputSettings) -> void:
	input_settings = settings
	camera.fov = input_settings.fov


func reset_fire_state() -> void:
	_is_trigger_held = false
	_sustained_fire = 0.0


func handle_damage(amount: float, source: Node = null) -> void:
	if has_node("HealthComponent"):
		$HealthComponent.apply_damage(amount, source)


func _get_weapon_spread_multiplier() -> float:
	var movement_penalty := 0.55 if Vector2(velocity.x, velocity.z).length() > 0.25 else 0.0
	return 1.0 + _sustained_fire + movement_penalty


func _apply_recoil() -> void:
	_pitch = clampf(
		_pitch - deg_to_rad(0.18 + 0.16 * _sustained_fire),
		deg_to_rad(-input_settings.max_pitch_degrees),
		deg_to_rad(input_settings.max_pitch_degrees)
	)
	head.rotation.x = _pitch
