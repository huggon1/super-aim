class_name FPSPlayer
extends CharacterBody3D

signal fired(was_hit: bool, target: AimTarget)

@export var input_settings: InputSettings

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var weapon: WeaponRaycast = $WeaponRaycast

var _pitch := 0.0


func _ready() -> void:
	if input_settings == null:
		input_settings = InputSettings.new()

	Input.use_accumulated_input = false
	apply_input_settings(input_settings)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	weapon.fired.connect(_on_weapon_fired)


func _physics_process(_delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (global_transform.basis * Vector3(input_vector.x, 0.0, input_vector.y)).normalized()
	velocity.x = direction.x * input_settings.move_speed
	velocity.z = direction.z * input_settings.move_speed
	move_and_slide()


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
		weapon.fire()


func _on_weapon_fired(was_hit: bool, target: AimTarget) -> void:
	fired.emit(was_hit, target)


func apply_input_settings(settings: InputSettings) -> void:
	input_settings = settings
	camera.fov = input_settings.fov
