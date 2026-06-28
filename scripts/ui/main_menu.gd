class_name MainMenu
extends Control

const APP_SETTINGS := preload("res://scripts/app/app_settings.gd")

signal start_training_requested
signal start_deathmatch_requested
signal settings_changed(settings)

@onready var start_training_button: Button = %StartTrainingButton
@onready var start_deathmatch_button: Button = %StartDeathmatchButton
@onready var sensitivity_spin_box: SpinBox = %SensitivitySpinBox
@onready var fov_spin_box: SpinBox = %FovSpinBox
@onready var save_settings_button: Button = %SaveSettingsButton

var _settings


func _ready() -> void:
	start_training_button.pressed.connect(_start_training)
	start_deathmatch_button.pressed.connect(_start_deathmatch)
	save_settings_button.pressed.connect(_save_settings)


func set_settings(settings) -> void:
	_settings = settings
	if not is_node_ready():
		await ready

	sensitivity_spin_box.value = _settings.mouse_sensitivity
	fov_spin_box.value = _settings.fov


func _save_settings() -> void:
	if _settings == null:
		_settings = APP_SETTINGS.new()

	_settings.mouse_sensitivity = float(sensitivity_spin_box.value)
	_settings.fov = float(fov_spin_box.value)
	_settings.clamp_values()
	settings_changed.emit(_settings)


func _start_training() -> void:
	_save_settings()
	start_training_requested.emit()


func _start_deathmatch() -> void:
	_save_settings()
	start_deathmatch_requested.emit()
