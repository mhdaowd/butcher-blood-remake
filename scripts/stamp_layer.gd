class_name StampLayer
extends Node2D

@export var texture: Texture2D
@export var max_stamps: int = 600

var centers: PackedVector2Array = PackedVector2Array()
var sizes: PackedVector2Array = PackedVector2Array()
var colors: PackedColorArray = PackedColorArray()

func add(center: Vector2, size: Vector2, color: Color) -> void:
	if centers.size() >= max_stamps:
		return
	centers.append(center)
	sizes.append(size)
	colors.append(color)

func clear() -> void:
	centers.clear()
	sizes.clear()
	colors.clear()

func _draw() -> void:
	for index: int in range(centers.size()):
		draw_texture_rect(texture, Rect2(centers[index] - sizes[index] * 0.5, sizes[index]), false, colors[index])
