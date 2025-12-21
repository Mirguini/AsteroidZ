extends CharacterBody2D

@export var speed: float = 200.0
@export var rotation_speed: float = 2.5 # radians/segon

var direction: Vector2 = Vector2.RIGHT
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()

	# Rotació aleatòria inicial + rotació constant
	rotation = _rng.randf_range(0.0, TAU)
	rotation_speed *= _rng.randf_range(0.6, 1.4)

	# Variació suau de velocitat per instància
	speed *= _rng.randf_range(0.85, 1.15)

func set_direction(dir: Vector2) -> void:
	if dir.length() > 0.001:
		direction = dir.normalized()

func _physics_process(delta: float) -> void:
	velocity = direction * speed
	move_and_slide()

	rotation += rotation_speed * delta

func _process(_delta: float) -> void:
	# Esborra quan estigui prou lluny de la pantalla (amb marge)
	var r := get_viewport_rect()
	var margin := 250.0
	if global_position.x < -margin or global_position.x > r.size.x + margin \
	or global_position.y < -margin or global_position.y > r.size.y + margin:
		queue_free()
