class_name ResultScreen
extends Control

signal restart_requested
signal menu_requested

@onready var score_label: Label = %ScoreLabel
@onready var hits_label: Label = %HitsLabel
@onready var shots_label: Label = %ShotsLabel
@onready var accuracy_label: Label = %AccuracyLabel
@onready var restart_button: Button = %RestartButton
@onready var menu_button: Button = %MenuButton


func _ready() -> void:
	restart_button.pressed.connect(func() -> void: restart_requested.emit())
	menu_button.pressed.connect(func() -> void: menu_requested.emit())


func set_results(results: Dictionary) -> void:
	score_label.text = "Score: %d" % results.get("score", 0)
	hits_label.text = "Hits: %d" % results.get("hits", 0)
	shots_label.text = "Shots: %d" % results.get("shots", 0)
	accuracy_label.text = "Accuracy: %.1f%%" % results.get("accuracy_percent", 0.0)
