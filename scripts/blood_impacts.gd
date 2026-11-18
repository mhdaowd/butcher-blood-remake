class_name BloodImpacts
extends Node

signal splash(position: Vector2, velocity: Vector2, radius: float, generation: int)

@export var canvas: BloodCanvas
@export var grid: BloodGrid
@export var pools: BloodPools
@export var runners: BloodRunners
@export var drips: BloodDrips
@export var seeps: BloodSeeps
@export var soak_ratio: float = 0.8
@export var pool_gain: float = 0.8
@export var seep_chance: float = 0.5
@export var max_splash_generation: int = 2

func resolve(drop: BloodDrop, previous_position: Vector2) -> void:
	var cell_size: int = grid.cell_size
	var cell_x: int = floori(drop.position.x / cell_size)
	var cell_y: int = floori(drop.position.y / cell_size)
	var into_wall: bool = grid.is_solid(cell_x, floori(previous_position.y / cell_size))
	var into_floor_or_ceiling: bool = grid.is_solid(floori(previous_position.x / cell_size), cell_y)
	var vertical: bool = absf(drop.velocity.y) >= absf(drop.velocity.x)
	if into_floor_or_ceiling != into_wall:
		vertical = into_floor_or_ceiling
	if not vertical:
		_on_wall(drop, cell_x)
	elif drop.velocity.y > 0.0:
		_on_floor(drop, float(cell_y * cell_size))
	else:
		_on_ceiling(drop, float((cell_y + 1) * cell_size))

func _soak(alpha: float) -> Color:
	var soak_color: Color = canvas.soak_color
	return Color(soak_color.r, soak_color.g, soak_color.b, alpha)

func _on_floor(drop: BloodDrop, floor_y: float) -> void:
	var position_x: float = drop.position.x
	var radius: float = drop.radius
	var speed: float = drop.velocity.length()
	var stretch: float = clampf(speed / 300.0, 0.8, 2.4)
	canvas.add_stamp(Vector2(position_x, floor_y + 0.5), radius * 1.3 * stretch, maxf(radius * 0.5, 1.0), drop.tint(canvas.fresh_color))
	canvas.add_stamp(Vector2(position_x, floor_y + 3.0 + radius), radius * 1.2, radius + 2.0, _soak(0.85))
	canvas.add_stamp(Vector2(position_x, floor_y + 8.0 + radius * 2.0), radius * 0.9, radius * 2.5, _soak(0.6))
	if radius >= 1.4 and randf() < seep_chance:
		seeps.spawn(position_x + randf_range(-radius, radius), floor_y + 2.0, minf(10.0 + radius * 6.0, 32.0), radius * 0.7)
	if randf() > soak_ratio:
		pools.add_volume(position_x, floor_y, PI * radius * radius * pool_gain)
	if drop.generation < max_splash_generation and speed > 220.0 and radius > 1.5:
		var count: int = randi_range(1, 3) if radius < 2.5 else randi_range(2, 4)
		for _index: int in range(count):
			var velocity: Vector2 = Vector2.from_angle(-PI * 0.5 + randf_range(-1.0, 1.0)) * speed * randf_range(0.12, 0.3)
			splash.emit(Vector2(position_x, floor_y - 1.5), velocity + Vector2(drop.velocity.x * 0.3, 0.0), radius * randf_range(0.35, 0.6), drop.generation + 1)

func _on_wall(drop: BloodDrop, cell_x: int) -> void:
	var cell_size: int = grid.cell_size
	var moving_right: bool = drop.velocity.x > 0.0
	var surface_x: float = float(cell_x * cell_size) if moving_right else float((cell_x + 1) * cell_size)
	var air_direction: float = -1.0 if moving_right else 1.0
	var radius: float = drop.radius
	canvas.add_stamp(Vector2(surface_x - air_direction * 0.5, drop.position.y), maxf(radius * 1.2, 1.0), radius * 1.3, drop.tint(canvas.fresh_color))
	canvas.add_stamp(Vector2(surface_x - air_direction * 2.0, drop.position.y), radius * 0.9, radius, _soak(0.7))
	runners.try_spawn(cell_x, cell_x - 1 if moving_right else cell_x + 1, surface_x, air_direction, drop.position.y, radius)

func _on_ceiling(drop: BloodDrop, ceiling_y: float) -> void:
	var radius: float = drop.radius
	canvas.add_stamp(Vector2(drop.position.x, ceiling_y - 0.5), radius * 1.4, maxf(radius * 0.7, 1.0), drop.tint(canvas.fresh_color))
	canvas.add_stamp(Vector2(drop.position.x, ceiling_y - 2.0), radius, radius * 0.9, _soak(0.7))
	drips.try_spawn(drop.position.x, ceiling_y, radius)
