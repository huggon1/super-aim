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
@onready var health_bar: ProgressBar = %HealthBar
@onready var shield_label: Label = %ShieldLabel
@onready var feedback_label: Label = %FeedbackLabel
@onready var hit_marker: Control = %HitMarker
@onready var pause_overlay: Control = %PauseOverlay
@onready var resume_button: Button = %ResumeButton
@onready var restart_button: Button = %RestartButton
@onready var menu_button: Button = %MenuButton


func _ready() -> void:
	resume_button.pressed.connect(func() -> void: resume_requested.emit())
	restart_button.pressed.connect(func() -> void: restart_requested.emit())
	menu_button.pressed.connect(func() -> void: menu_requested.emit())
	feedback_label.visible = false
	hit_marker.visible = false


func set_stats(time_left: float, score: DeathmatchScore, health: float, max_health: float, shield_seconds: float) -> void:
	time_label.text = "%02d" % int(ceil(time_left))
	score_label.text = "Score: %d" % score.get_score()
	kills_label.text = "Kills: %d" % score.kills
	deaths_label.text = "Deaths: %d" % score.deaths
	accuracy_label.text = "Accuracy: %.1f%%" % score.get_accuracy_percent()
	health_label.text = "HP: %d" % int(ceil(health))
	health_bar.max_value = max_health
	health_bar.value = health
	shield_label.visible = shield_seconds > 0.0
	shield_label.text = "RESPAWN SHIELD %.1fs" % shield_seconds


func set_paused(is_paused: bool) -> void:
	pause_overlay.visible = is_paused


func show_hit_feedback(is_critical: bool) -> void:
	hit_marker.visible = true
	hit_marker.modulate = Color(1.0, 0.25, 0.12, 1.0) if is_critical else Color(0.15, 0.95, 1.0, 1.0)
	var tween := create_tween()
	tween.tween_property(hit_marker, "modulate:a", 0.0, 0.16)
	tween.tween_callback(func() -> void: hit_marker.visible = false)


func show_kill_feedback(is_critical: bool) -> void:
	feedback_label.visible = true
	feedback_label.text = "HEADSHOT" if is_critical else "ELIMINATED"
	feedback_label.modulate = Color(1.0, 0.25, 0.12, 1.0) if is_critical else Color(0.15, 0.95, 1.0, 1.0)
	var tween := create_tween()
	tween.tween_interval(0.45)
	tween.tween_property(feedback_label, "modulate:a", 0.0, 0.25)
	tween.tween_callback(func() -> void: feedback_label.visible = false)
