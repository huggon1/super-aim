class_name HealthComponent
extends Node

signal damaged(amount: float, source: Node)
signal died(source: Node)
signal respawned
signal invulnerability_changed(is_invulnerable: bool)

@export var max_health := 100.0

var current_health := 100.0
var is_alive := true
var _invulnerable_until_msec := 0


func _ready() -> void:
	current_health = max_health


func _process(_delta: float) -> void:
	if _invulnerable_until_msec > 0 and Time.get_ticks_msec() >= _invulnerable_until_msec:
		_invulnerable_until_msec = 0
		invulnerability_changed.emit(false)


func apply_damage(amount: float, source: Node = null) -> void:
	if not is_alive:
		return
	if is_invulnerable():
		return

	current_health = maxf(0.0, current_health - amount)
	damaged.emit(amount, source)

	if current_health <= 0.0:
		is_alive = false
		died.emit(source)


func reset() -> void:
	current_health = max_health
	is_alive = true
	respawned.emit()


func set_invulnerable(duration_seconds: float) -> void:
	if duration_seconds <= 0.0:
		if _invulnerable_until_msec > 0:
			_invulnerable_until_msec = 0
			invulnerability_changed.emit(false)
		return

	_invulnerable_until_msec = Time.get_ticks_msec() + int(duration_seconds * 1000.0)
	invulnerability_changed.emit(true)


func is_invulnerable() -> bool:
	return _invulnerable_until_msec > Time.get_ticks_msec()


func get_invulnerability_remaining() -> float:
	if not is_invulnerable():
		return 0.0
	return float(_invulnerable_until_msec - Time.get_ticks_msec()) / 1000.0
