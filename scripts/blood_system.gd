class_name BloodSystem
extends Node2D

@export var grid: BloodGrid
@export var drops: BloodDrops

static func of(source: Node) -> BloodSystem:
	return source.get_tree().get_first_node_in_group(&"blood") as BloodSystem

func _ready() -> void:
	var tile_size: int = (get_parent() as TileMapLayer).tile_set.tile_size.x
	scale = Vector2.ONE * float(tile_size) / float(grid.cell_size)

func burst(world_position: Vector2, direction: Vector2, amount: int = 90, power: float = 520.0, spread: float = 1.0) -> void:
	var _position: Vector2 = to_local(world_position)
	var base_angle: float = direction.angle()
	for _index: int in range(amount):
		var radius: float = lerpf(1.4, 5.5, pow(randf(), 2.2))
		_spawn(_position, base_angle + randfn(0.0, spread * 0.5), power * randf_range(0.2, 1.1), radius)
	for _index: int in range(int(amount * 0.5)):
		_spawn(_position, base_angle + randfn(0.0, spread * 0.8), power * randf_range(0.5, 1.3), randf_range(0.8, 1.4), 1, randf_range(0.25, 0.7))
	for _index: int in range(int(amount * 0.25)):
		_spawn(_position, base_angle + PI + randfn(0.0, 0.7), power * randf_range(0.15, 0.5), lerpf(1.2, 4.0, pow(randf(), 2.0)))
	for _index: int in range(6):
		_spawn(_position, base_angle + randfn(0.0, spread), power * randf_range(0.1, 0.35), randf_range(4.0, 6.5))

func _spawn(_position: Vector2, angle: float, speed: float, radius: float, generation: int = 0, life: float = -1.0) -> void:
	var origin: Vector2 = _position + Vector2(randf_range(-3.0, 3.0), randf_range(-3.0, 3.0))
	drops.spawn(origin, Vector2.from_angle(angle) * speed, radius, generation, life)
