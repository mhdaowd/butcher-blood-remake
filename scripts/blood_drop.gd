class_name BloodDrop
extends RefCounted

var position: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var radius: float = 2.0
var shade: float = 1.0
var generation: int = 0
var life: float = -1.0

func tint(base_color: Color) -> Color:
	return Color(clampf(base_color.r * shade, 0.0, 1.0), base_color.g, base_color.b, base_color.a)
