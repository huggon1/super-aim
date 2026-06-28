class_name DamageHitbox
extends Area3D

@export var health_component_path: NodePath
@export var is_critical := false

@onready var health_component: HealthComponent = get_node(health_component_path)


func handle_damage(amount: float, source: Node = null) -> void:
	if health_component != null:
		health_component.apply_damage(amount, source)
