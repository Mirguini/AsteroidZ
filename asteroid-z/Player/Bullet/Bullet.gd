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


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("asteroids"):
		body.queue_free()
		queue_free()     
