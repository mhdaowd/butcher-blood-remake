class_name BloodPools
extends MultiMeshInstance2D

@export var grid: BloodGrid
@export var canvas: BloodCanvas
@export var seeps: BloodSeeps
@export var capacity: int = 64
@export var max_height: float = 1.5
@export var min_height: float = 1.0
@export var spread_speed: float = 3.0
@export var soak_rate: float = 14.0

class Pool:
	var left: float = 0.0
	var right: float = 0.0
	var surface_y: float = 0.0
	var volume: float = 0.0
	var agitation: float = 0.0
	var soak_timer: float = 0.0
	var phase: float = 0.0

var pools: Array[Pool] = []
var box_height: float = 0.0

func _ready() -> void:
	box_height = max_height + 3.0
	multimesh.instance_count = capacity
	material.set_shader_parameter(&"max_height", max_height)
	material.set_shader_parameter(&"box_height", box_height)

func add_volume(position_x: float, floor_y: float, volume: float) -> void:
	if not grid.is_floor_surface(position_x, floor_y):
		return
	for pool: Pool in pools:
		if absf(pool.surface_y - floor_y) < 0.5 and position_x >= pool.left - 6.0 and position_x <= pool.right + 6.0:
			pool.volume += volume
			if grid.is_floor_surface(position_x - 1.5, floor_y):
				pool.left = minf(pool.left, position_x - 1.5)
			if grid.is_floor_surface(position_x + 1.5, floor_y):
				pool.right = maxf(pool.right, position_x + 1.5)
			pool.agitation = 1.0
			return
	var created: Pool = Pool.new()
	created.left = position_x - 2.0 if grid.is_floor_surface(position_x - 2.0, floor_y) else position_x
	created.right = position_x + 2.0 if grid.is_floor_surface(position_x + 2.0, floor_y) else position_x
	created.surface_y = floor_y
	created.volume = volume
	created.agitation = 1.0
	created.phase = randf() * TAU
	pools.append(created)
	if pools.size() > capacity:
		_finalize(pools.pop_front())

func _process(delta: float) -> void:
	delta = minf(delta, 1.0 / 40.0)
	var soak_color: Color = canvas.soak_color
	var index: int = pools.size() - 1
	while index >= 0:
		var pool: Pool = pools[index]
		pool.agitation = maxf(0.0, pool.agitation - delta * 1.5)
		var width: float = maxf(pool.right - pool.left, 1.0)
		var height: float = pool.volume / (width * 0.7)
		if height > min_height:
			var spread: float = clampf(height, 0.0, 6.0) * spread_speed * delta
			if grid.is_floor_surface(pool.left - spread, pool.surface_y):
				pool.left -= spread
			if grid.is_floor_surface(pool.right + spread, pool.surface_y):
				pool.right += spread
		pool.volume -= soak_rate * delta * (0.5 + width * 0.03)
		pool.soak_timer -= delta
		if pool.soak_timer <= 0.0:
			pool.soak_timer = 0.1
			var sample_x: float = randf_range(pool.left, pool.right)
			canvas.add_stamp(Vector2(sample_x, pool.surface_y + randf_range(2.0, 9.0)), randf_range(1.2, 2.6), randf_range(1.5, 3.5), Color(soak_color.r, soak_color.g, soak_color.b, 0.45))
			if randf() < 0.25:
				seeps.spawn(sample_x, pool.surface_y + 1.0, randf_range(8.0, 22.0), 1.1)
		width = maxf(pool.right - pool.left, 1.0)
		height = pool.volume / (width * 0.7)
		if height < 0.5 or pool.volume <= 0.0:
			_finalize(pool)
			pools.remove_at(index)
		index -= 1
	_render()

func _render() -> void:
	var count: int = 0
	for pool: Pool in pools:
		var width: float = pool.right - pool.left
		var height: float = pool.volume / (maxf(width, 1.0) * 0.7)
		if width < 1.0 or height < 0.4:
			continue
		var center: Vector2 = Vector2((pool.left + pool.right) * 0.5, pool.surface_y + 1.0 - box_height * 0.5)
		multimesh.set_instance_transform_2d(count, Transform2D(Vector2(width + 2.0, 0.0), Vector2(0.0, box_height), center))
		multimesh.set_instance_custom_data(count, Color(minf(height, max_height), pool.agitation, pool.phase, 0.0))
		count += 1
	multimesh.visible_instance_count = count

func _finalize(pool: Pool) -> void:
	var width: float = pool.right - pool.left
	if width < 1.0:
		return
	var center_x: float = (pool.left + pool.right) * 0.5
	var dried_color: Color = canvas.dried_color
	var soak_color: Color = canvas.soak_color
	canvas.add_stamp(Vector2(center_x, pool.surface_y + 0.3), width * 0.5 + 1.0, 1.0, Color(dried_color.r, dried_color.g, dried_color.b, dried_color.a * 0.9))
	canvas.add_stamp(Vector2(center_x, pool.surface_y + 4.0), width * 0.5, 4.0, Color(soak_color.r, soak_color.g, soak_color.b, 0.6))
	for _index: int in range(int(width / 10.0)):
		seeps.spawn(randf_range(pool.left, pool.right), pool.surface_y + 1.0, randf_range(8.0, 20.0), 1.1)
