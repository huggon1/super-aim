class_name AppSettings
extends RefCounted

const INPUT_SETTINGS := preload("res://scripts/player/input_settings.gd")
const SETTINGS_PATH := "user://aimlabb_settings.cfg"
const INPUT_SENSITIVITY_SCALE := 0.001

var mouse_sensitivity := 2.5
var fov := 90.0


func load_from_disk() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return

	mouse_sensitivity = float(config.get_value("input", "mouse_sensitivity", mouse_sensitivity))
	fov = float(config.get_value("video", "fov", fov))
	clamp_values()


func save_to_disk() -> void:
	clamp_values()
	var config := ConfigFile.new()
	config.set_value("input", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("video", "fov", fov)
	config.save(SETTINGS_PATH)


func clamp_values() -> void:
	mouse_sensitivity = clampf(mouse_sensitivity, 0.1, 20.0)
	fov = clampf(fov, 60.0, 120.0)


func to_input_settings():
	var input_settings = INPUT_SETTINGS.new()
	input_settings.mouse_sensitivity = mouse_sensitivity * INPUT_SENSITIVITY_SCALE
	input_settings.fov = fov
	return input_settings
