extends Area2D

@export var speed: float = 900.0
@export var lifetime: float = 1.2

var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	if direction.length() > 0.001:
		rotation = direction.angle() + deg_to_rad(90)

	await get_tree().create_timer(lifetime).timeout
	queue_free()


func _physics_process(delta: float) -> void:
	# Moviment
	global_position += direction.normalized() * speed * delta
