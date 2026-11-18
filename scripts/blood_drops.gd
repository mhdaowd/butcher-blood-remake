class_name BloodDrops
extends MultiMeshInstance2D

@export var grid: BloodGrid
@export var impacts: BloodImpacts
@export var capacity: int = 1200
@export var gravity: float = 950.0
@export var air_drag: float = 0.25
@export var streak: float = 0.02
@export var max_speed: float = 900.0
@export var max_step: float = 14.0

var drops: Array[BloodDrop] = []
var bounds: Rect2 = Rect2()

func _ready() -> void:
	multimesh.instance_count = capacity
	bounds = grid.rect().grow(64.0)

func spawn(_position: Vector2, velocity: Vector2, radius: float, generation: int = 0, life: float = -1.0) -> void:
	if drops.size() >= capacity:
		return
	var drop: BloodDrop = BloodDrop.new()
	drop.position = _position
	drop.velocity = velocity
	drop.radius = radius
	drop.generation = generation
	drop.life = life
	drop.shade = randf_range(0.8, 1.12)
	drops.append(drop)

func _process(delta: float) -> void:
	delta = minf(delta, 1.0 / 40.0)
	var index: int = drops.size() - 1
	while index >= 0:
		if _step(drops[index], delta):
			drops[index] = drops[-1]
			drops.pop_back()
		index -= 1
	_render()

func _step(drop: BloodDrop, delta: float) -> bool:
	if drop.life >= 0.0:
		drop.life -= delta
		if drop.life <= 0.0:
			return true
	drop.velocity.y += gravity * delta
	drop.velocity = (drop.velocity * maxf(0.0, 1.0 - air_drag * delta)).limit_length(max_speed)
	var steps: int = 1 + int(drop.velocity.length() * delta / max_step)
	var step_delta: float = delta / steps
	for _index: int in range(steps):
		var previous_position: Vector2 = drop.position
		drop.position += drop.velocity * step_delta
		if drop.position.x < bounds.position.x or drop.position.x > bounds.end.x or drop.position.y > bounds.end.y or drop.position.y < bounds.position.y - 400.0:
			return true
		if grid.is_solid_at(drop.position):
			impacts.resolve(drop, previous_position)
			return true
	return false

func _render() -> void:
	for index: int in range(drops.size()):
		var drop: BloodDrop = drops[index]
		var speed: float = drop.velocity.length()
		var direction: Vector2 = drop.velocity / speed if speed > 1.0 else Vector2.DOWN
		var tail: float = minf(speed * streak, 9.0)
		var axis_x: Vector2 = direction * (drop.radius + tail * 0.5)
		var axis_y: Vector2 = Vector2(-direction.y, direction.x) * drop.radius
		var alpha: float = clampf(drop.life / 0.2, 0.0, 1.0) * 0.85 if drop.life >= 0.0 else 1.0
		multimesh.set_instance_transform_2d(index, Transform2D(axis_x, axis_y, drop.position - direction * tail * 0.5))
		multimesh.set_instance_custom_data(index, Color(drop.shade, alpha, 0.0, 0.0))
	multimesh.visible_instance_count = drops.size()
