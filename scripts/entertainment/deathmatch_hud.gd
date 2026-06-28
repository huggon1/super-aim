class_name DeathmatchHud
extends Control

signal resume_requested
signal restart_requested
signal menu_requested

@onready var time_label: Label = %TimeLabel
@onready var score_label: Label = %ScoreLabel
@onready var kills_label: Label = %KillsLabel
@onready var deaths_label: Label = %DeathsLabel
@onready var accuracy_label: Label = %AccuracyLabel
@onready var health_label: Label = %HealthLabel
@onready var pause_overlay: Control = %PauseOverlay
@onready var resume_button: Button = %ResumeButton
@onready var restart_button: Button = %RestartButton
@onready var menu_button: Button = %MenuButton


func _ready() -> void:
	resume_button.pressed.connect(func() -> void: resume_requested.emit())
	restart_button.pressed.connect(func() -> void: restart_requested.emit())
	menu_button.pressed.connect(func() -> void: menu_requested.emit())


func set_stats(time_left: float, score: DeathmatchScore, health: float) -> void:
	time_label.text = "%02d" % int(ceil(time_left))
	score_label.text = "Score: %d" % score.get_score()
	kills_label.text = "Kills: %d" % score.kills
	deaths_label.text = "Deaths: %d" % score.deaths
	accuracy_label.text = "Accuracy: %.1f%%" % score.get_accuracy_percent()
	health_label.text = "HP: %d" % int(ceil(health))


func set_paused(is_paused: bool) -> void:
	pause_overlay.visible = is_paused
