extends CharacterBody2D

@export var speed: float = 240.0
@export var acceleration: float = 1900.0
@export var friction: float = 1700.0
@export var jump_velocity: float = -700.0
@export var gravity: float = 1500.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var bat: Area2D = $Bat
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var facing: int = 1
var is_attacking: bool = false
var jump_held: bool = false
var coyote_time: float = 0.0
var was_on_floor: bool = false
var bob_time: float = 0.0
var squash: float = 0.0
var base_scale: Vector2 = Vector2.ONE

func _ready() -> void:
	animated_sprite.play(&"idle")
	animation_player.play(&"BatIdle")

func _physics_process(delta: float) -> void:
	if is_on_floor():
		coyote_time = 0.1
	else:
		coyote_time -= delta
		velocity.y += gravity * delta
	
	var direction: float = Input.get_axis(&"move_left", &"move_right")
	if direction != 0.0:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
	
	var jump_pressed: bool = Input.is_action_pressed(&"jump")
	if jump_pressed and not jump_held and coyote_time > 0.0:
		velocity.y = jump_velocity
		coyote_time = 0.0
		squash = -0.6
	jump_held = jump_pressed
	if Input.is_action_just_pressed(&"attack") and not is_attacking:
		animated_sprite.play(&"attack")
		animation_player.play(&"BatAnimation")
		is_attacking = true
	move_and_slide()
	
	var on_floor: bool = is_on_floor()
	if on_floor and not was_on_floor:
		squash = 0.8
	was_on_floor = on_floor
	facing = 1 if get_global_mouse_position().x >= global_position.x else -1

func _process(delta: float) -> void:
	if not is_attacking:
		squash = move_toward(squash, 0.0, 5.0 * delta)
		bat.scale.x = facing
		var moving: bool = absf(velocity.x) > 20.0 and is_on_floor()
		bob_time += delta * (14.0 if moving else 0.0)
		var scale_x: float = base_scale.x * float(facing) * (1.0 + 0.18 * squash)
		var scale_y: float = base_scale.y * (1.0 - 0.18 * squash)
		animated_sprite.scale = Vector2(scale_x, scale_y)
		animated_sprite.rotation = sin(bob_time) * 0.05 if moving else 0.0

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.get_animation() == &"attack":
		animated_sprite.play(&"idle")

func _on_animation_player_animation_finished(animation_name: StringName) -> void:
	if animation_name == &"BatAnimation":
		animation_player.play(&"BatIdle")
		is_attacking = false

func _on_bat_area_entered(area: Area2D) -> void:
	if area.name == &"HurtboxComponent":
		var game_feel: GameFeel = GameFeel.of(self)
		if game_feel:
			game_feel.shake(9.0)
			game_feel.flash_screen(0.5)
			game_feel.hitstop(0.06)
		var blood_system: BloodSystem = BloodSystem.of(self)
		if blood_system:
			blood_system.burst(area.global_position, (area.global_position - global_position).normalized() + Vector2.UP * 0.3)
