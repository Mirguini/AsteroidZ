extends CharacterBody2D

@export var speed := 600.0

func _ready():
	global_position = get_viewport_rect().size / 2

func _process(delta: float) -> void:
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("moveRight") - Input.get_action_strength("moveLeft")
	input_vector.y = Input.get_action_strength("moveDown") - Input.get_action_strength("moveUp")

	input_vector = input_vector.normalized()
	
	velocity = input_vector * speed
	
	move_and_slide()
