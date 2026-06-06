class_name TrainingHud
extends Control

signal resume_requested
signal restart_requested
signal menu_requested

@onready var time_label: Label = %TimeLabel
@onready var score_label: Label = %ScoreLabel
@onready var hits_label: Label = %HitsLabel
@onready var shots_label: Label = %ShotsLabel
@onready var accuracy_label: Label = %AccuracyLabel
@onready var pause_overlay: Control = %PauseOverlay
@onready var resume_button: Button = %ResumeButton
@onready var restart_button: Button = %RestartButton
@onready var menu_button: Button = %MenuButton


func _ready() -> void:
	resume_button.pressed.connect(func() -> void: resume_requested.emit())
	restart_button.pressed.connect(func() -> void: restart_requested.emit())
	menu_button.pressed.connect(func() -> void: menu_requested.emit())


func set_stats(remaining_seconds: float, score: int, hits: int, shots: int, accuracy_percent: float) -> void:
	time_label.text = "%02d" % ceili(remaining_seconds)
	score_label.text = "Score: %d" % score
	hits_label.text = "Hits: %d" % hits
	shots_label.text = "Shots: %d" % shots
	accuracy_label.text = "Accuracy: %.1f%%" % accuracy_percent


func set_paused(is_paused: bool) -> void:
	pause_overlay.visible = is_paused
