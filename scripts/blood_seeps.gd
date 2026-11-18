class_name BloodSeeps
extends Node

@export var canvas: BloodCanvas
@export var max_seeps: int = 120

class Seep:
	var position_x: float = 0.0
	var position_y: float = 0.0
	var depth: float = 10.0
	var speed: float = 18.0
	var radius: float = 1.2

var seeps: Array[Seep] = []

func spawn(position_x: float, position_y: float, depth: float, radius: float) -> void:
	if seeps.size() >= max_seeps:
		return
	var seep: Seep = Seep.new()
	seep.position_x = position_x
	seep.position_y = position_y
	seep.depth = depth
	seep.radius = radius
	seep.speed = randf_range(12.0, 24.0)
	seeps.append(seep)

func _process(delta: float) -> void:
	var soak_color: Color = canvas.soak_color
	var index: int = seeps.size() - 1
	while index >= 0:
		var seep: Seep = seeps[index]
		var step: float = seep.speed * delta
		seep.position_y += step
		seep.depth -= step
		canvas.add_stamp(Vector2(seep.position_x, seep.position_y), seep.radius * 0.9, seep.radius * 1.5, Color(soak_color.r, soak_color.g, soak_color.b, 0.55))
		seep.radius = maxf(0.7, seep.radius - delta * 0.15)
		if seep.depth <= 0.0:
			seeps.remove_at(index)
		index -= 1
