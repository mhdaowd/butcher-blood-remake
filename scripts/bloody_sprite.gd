extends Sprite2D

@export var per_hit: float = 0.3

var amount: float = 0.0

func add_blood(_area: Area2D = null) -> void:
	amount = minf(amount + per_hit, 1.0)
	material.set_shader_parameter(&"amount", amount)
