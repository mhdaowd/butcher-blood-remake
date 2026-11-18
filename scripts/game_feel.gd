class_name GameFeel
extends Node

@export var camera: Camera2D
@export var flash_rect: ColorRect
@export var shake_decay: float = 30.0
@export var flash_decay: float = 3.0

var _shake: float = 0.0
var flash: float = 0.0
var flash_color: Color = Color(1.0, 0.1, 0.1)

static func of(source: Node) -> GameFeel:
	return source.get_tree().get_first_node_in_group(&"game_feel") as GameFeel

func _process(delta: float) -> void:
	if camera == null:
		camera = get_viewport().get_camera_2d()
	_shake = move_toward(_shake, 0.0, shake_decay * delta)
	if camera != null:
		camera.offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake / camera.zoom.x
	if flash > 0.0 and flash_rect != null:
		flash = move_toward(flash, 0.0, flash_decay * delta)
		flash_rect.material.set_shader_parameter(&"flash", flash)
		flash_rect.material.set_shader_parameter(&"flash_color", Vector3(flash_color.r, flash_color.g, flash_color.b))

func shake(amount: float) -> void:
	_shake = maxf(_shake, amount)

func flash_screen(amount: float, color: Color = flash_color) -> void:
	flash = maxf(flash, amount)
	flash_color = color

func hitstop(duration: float = 0.05) -> void:
	Engine.time_scale = 0.05
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0
