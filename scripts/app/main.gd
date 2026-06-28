extends Node

const MAIN_MENU_SCENE := preload("res://scenes/ui/MainMenu.tscn")
const TRAINING_SCENE := preload("res://scenes/training/SixTargetUltimate.tscn")
const DEATHMATCH_SCENE := preload("res://scenes/entertainment/EntertainmentDeathmatch.tscn")
const RESULT_SCENE := preload("res://scenes/ui/ResultScreen.tscn")
const APP_SETTINGS := preload("res://scripts/app/app_settings.gd")

var _current_scene: Node
var _settings


func _ready() -> void:
	_settings = APP_SETTINGS.new()
	_settings.load_from_disk()
	show_menu()


func show_menu() -> void:
	var menu := MAIN_MENU_SCENE.instantiate() as MainMenu
	_current_scene = SceneRouter.replace_child(self, _current_scene, menu)
	menu.set_settings(_settings)
	menu.start_training_requested.connect(start_training)
	menu.start_deathmatch_requested.connect(start_deathmatch)
	menu.settings_changed.connect(_on_settings_changed)


func start_training() -> void:
	var training := TRAINING_SCENE.instantiate()
	training.input_settings = _settings.to_input_settings()
	_current_scene = SceneRouter.replace_child(self, _current_scene, training)
	training.training_finished.connect(show_results)
	training.restart_requested.connect(start_training)
	training.menu_requested.connect(show_menu)


func start_deathmatch() -> void:
	var deathmatch := DEATHMATCH_SCENE.instantiate()
	deathmatch.input_settings = _settings.to_input_settings()
	_current_scene = SceneRouter.replace_child(self, _current_scene, deathmatch)
	deathmatch.match_finished.connect(show_deathmatch_results)
	deathmatch.restart_requested.connect(start_deathmatch)
	deathmatch.menu_requested.connect(show_menu)


func show_results(results: Dictionary) -> void:
	var result_screen := RESULT_SCENE.instantiate() as ResultScreen
	_current_scene = SceneRouter.replace_child(self, _current_scene, result_screen)
	result_screen.set_results(results)
	result_screen.restart_requested.connect(start_training)
	result_screen.menu_requested.connect(show_menu)


func show_deathmatch_results(results: Dictionary) -> void:
	var result_screen := RESULT_SCENE.instantiate() as ResultScreen
	_current_scene = SceneRouter.replace_child(self, _current_scene, result_screen)
	result_screen.set_results(results)
	result_screen.restart_requested.connect(start_deathmatch)
	result_screen.menu_requested.connect(show_menu)


func _on_settings_changed(settings) -> void:
	_settings = settings
	_settings.save_to_disk()
