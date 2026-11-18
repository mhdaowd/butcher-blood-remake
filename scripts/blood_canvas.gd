class_name BloodCanvas
extends Node2D

@export var grid: BloodGrid
@export var fresh_color: Color = Color(0.72, 0.03, 0.05, 0.95)
@export var soak_color: Color = Color(0.36, 0.02, 0.04, 1.0)
@export var dried_color: Color = Color(0.28, 0.02, 0.04, 0.9)

@onready var viewport: SubViewport = $Viewport
@onready var stamps: StampLayer = $Viewport/Stamps
@onready var view: Sprite2D = $View

var pending: bool = false

func _ready() -> void:
	var bounds: Rect2 = grid.rect()
	viewport.size = Vector2i(bounds.size)
	stamps.position = -bounds.position
	view.position = bounds.position
	view.material.set_shader_parameter(&"mask_texture", grid.make_mask())
	view.material.set_shader_parameter(&"cell", float(grid.cell_size))

func _process(_delta: float) -> void:
	if pending:
		stamps.clear()
		pending = false

func add_stamp(center: Vector2, radius_x: float, radius_y: float, color: Color) -> void:
	if not pending:
		pending = true
		stamps.queue_redraw()
		viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	stamps.add(center, Vector2(maxf(radius_x, 0.6), maxf(radius_y, 0.6)) * 4.0, color)
