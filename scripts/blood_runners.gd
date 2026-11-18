class_name BloodRunners
extends Node

signal drop_released(position: Vector2, velocity: Vector2, radius: float, generation: int)

@export var grid: BloodGrid
@export var canvas: BloodCanvas
@export var pools: BloodPools
@export var seeps: BloodSeeps
@export var chance: float = 0.7
@export var volume: float = 3.5
@export var consume: float = 0.4
@export var max_length: float = 380.0
@export var max_runners: int = 120
@export var min_radius: float = 1.6
@export var min_speed: float = 24.0
@export var max_speed: float = 90.0

class Runner:
	var wall_cell_x: int = 0
	var air_cell_x: int = 0
	var surface_x: float = 0.0
	var air_direction: float = 1.0
	var position_y: float = 0.0
	var speed: float = 0.0
	var volume: float = 1.0
	var initial_volume: float = 1.0
	var delay: float = 0.0
	var travel: float = 0.0

var runners: Array[Runner] = []

func try_spawn(wall_cell_x: int, air_cell_x: int, surface_x: float, air_direction: float, position_y: float, radius: float) -> void:
	if radius < min_radius or randf() >= chance or runners.size() >= max_runners:
		return
	var runner: Runner = Runner.new()
	runner.wall_cell_x = wall_cell_x
	runner.air_cell_x = air_cell_x
	runner.surface_x = surface_x
	runner.air_direction = air_direction
	runner.position_y = position_y
	runner.volume = radius * radius * PI * volume
	runner.initial_volume = runner.volume
	runner.delay = randf_range(0.1, 0.5)
	runners.append(runner)

func _process(delta: float) -> void:
	delta = minf(delta, 1.0 / 40.0)
	var index: int = runners.size() - 1
	while index >= 0:
		var runner: Runner = runners[index]
		if runner.delay > 0.0:
			runner.delay -= delta
		elif _step(runner, delta):
			runners.remove_at(index)
		index -= 1

func _step(runner: Runner, delta: float) -> bool:
	var cell_size: int = grid.cell_size
	var fraction: float = clampf(runner.volume / runner.initial_volume, 0.0, 1.0)
	runner.speed = move_toward(runner.speed, lerpf(min_speed, max_speed, fraction), 120.0 * delta)
	var step: float = runner.speed * delta
	var next_y: float = runner.position_y + step
	if not grid.is_solid(runner.wall_cell_x, floori(next_y / cell_size)):
		drop_released.emit(Vector2(runner.surface_x + runner.air_direction * 1.5, next_y), Vector2(0.0, 30.0), 1.8, 1)
		return true
	if grid.is_solid(runner.air_cell_x, floori((next_y + 2.0) / cell_size)):
		var floor_y: float = float(floori((next_y + 2.0) / cell_size) * cell_size)
		pools.add_volume(runner.surface_x + runner.air_direction * 2.0, floor_y, runner.volume * 0.5 + 2.0)
		seeps.spawn(runner.surface_x - runner.air_direction * 1.5, floor_y + 1.0, 14.0, 1.2)
		return true
	runner.position_y = next_y
	runner.travel += step
	var radius: float = lerpf(0.8, 2.0, fraction)
	var fresh_color: Color = canvas.fresh_color
	canvas.add_stamp(Vector2(runner.surface_x - runner.air_direction, runner.position_y), radius, radius * 1.6, Color(fresh_color.r * 0.85, fresh_color.g, fresh_color.b, fresh_color.a))
	runner.volume = maxf(0.0, runner.volume - step * consume)
	return runner.travel > max_length
