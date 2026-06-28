class_name HealthComponent
extends Node

signal damaged(amount: float, source: Node)
signal died(source: Node)
signal respawned

@export var max_health := 100.0

var current_health := 100.0
var is_alive := true


func _ready() -> void:
	current_health = max_health


func apply_damage(amount: float, source: Node = null) -> void:
	if not is_alive:
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
