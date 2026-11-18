class_name BloodDrips
extends MultiMeshInstance2D

signal drop_released(position: Vector2, velocity: Vector2, radius: float, generation: int)

@export var capacity: int = 48
@export var chance: float = 0.35
@export var min_radius: float = 1.4

class Drip:
	var position_x: float = 0.0
	var position_y: float = 0.0
	var time: float = 0.0
	var wait: float = 1.0
	var radius: float = 2.0
	var remaining: int = 3

var drips: Array[Drip] = []

func _ready() -> void:
	multimesh.instance_count = capacity

func try_spawn(position_x: float, ceiling_y: float, radius: float) -> void:
	if radius < min_radius or randf() >= chance or drips.size() >= capacity:
		return
	var drip: Drip = Drip.new()
	drip.position_x = position_x
	drip.position_y = ceiling_y
	drip.wait = randf_range(0.4, 1.2)
	drip.radius = radius * 0.9
	drip.remaining = randi_range(2, 5)
	drips.append(drip)

func _process(delta: float) -> void:
	delta = minf(delta, 1.0 / 40.0)
	var index: int = drips.size() - 1
	while index >= 0:
		var drip: Drip = drips[index]
		drip.time += delta
		if drip.time >= drip.wait:
			drop_released.emit(Vector2(drip.position_x, drip.position_y + 2.0), Vector2(0.0, 10.0), drip.radius * 0.85, 1)
			drip.time = 0.0
			drip.wait = randf_range(0.5, 1.4)
			drip.radius *= 0.85
			drip.remaining -= 1
			if drip.remaining <= 0:
				drips.remove_at(index)
		index -= 1
	_render()

func _render() -> void:
	for index: int in range(drips.size()):
		var drip: Drip = drips[index]
		var radius: float = drip.radius * (0.4 + 0.6 * minf(1.0, drip.time / drip.wait))
		multimesh.set_instance_transform_2d(index, Transform2D(Vector2(radius, 0.0), Vector2(0.0, radius * 1.5), Vector2(drip.position_x, drip.position_y + radius * 1.4)))
		multimesh.set_instance_custom_data(index, Color(1.0, 1.0, 0.0, 0.0))
	multimesh.visible_instance_count = drips.size()
