class_name BloodGrid
extends Node

@export var cell_size: int = 32
@export var tilemap: TileMapLayer

var origin: Vector2i = Vector2i.ZERO
var size: Vector2i = Vector2i.ZERO
var solid: PackedByteArray = PackedByteArray()

func _ready() -> void:
	if tilemap == null:
		tilemap = get_parent().get_parent() as TileMapLayer
	var used_rect: Rect2i = tilemap.get_used_rect()
	origin = used_rect.position
	size = used_rect.size
	solid.resize(size.x * size.y)
	for cell_y: int in range(size.y):
		for cell_x: int in range(size.x):
			solid[cell_y * size.x + cell_x] = 1 if tilemap.get_cell_source_id(origin + Vector2i(cell_x, cell_y)) != -1 else 0

func rect() -> Rect2:
	return Rect2(Vector2(origin * cell_size), Vector2(size * cell_size))

func is_solid(cell_x: int, cell_y: int) -> bool:
	var local_x: int = cell_x - origin.x
	var local_y: int = cell_y - origin.y
	if local_x < 0 or local_y < 0 or local_x >= size.x or local_y >= size.y:
		return false
	return solid[local_y * size.x + local_x] == 1

func is_solid_at(point: Vector2) -> bool:
	return is_solid(floori(point.x / cell_size), floori(point.y / cell_size))

func is_floor_surface(position_x: float, floor_y: float) -> bool:
	var cell_x: int = floori(position_x / cell_size)
	var cell_y: int = roundi(floor_y / cell_size)
	return is_solid(cell_x, cell_y) and not is_solid(cell_x, cell_y - 1)

func make_mask() -> ImageTexture:
	var image: Image = Image.create_empty(size.x, size.y, false, Image.FORMAT_R8)
	for cell_y: int in range(size.y):
		for cell_x: int in range(size.x):
			if solid[cell_y * size.x + cell_x] == 1:
				image.set_pixel(cell_x, cell_y, Color.RED)
	return ImageTexture.create_from_image(image)
