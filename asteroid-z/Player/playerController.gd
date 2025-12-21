extends CharacterBody2D

@export var speed := 600.0


var aimDir := Vector2.RIGHT

@export var bullet: PackedScene
@export var fireCd: float = 0.15
@onready var muzzle: Marker2D = $Muzzle
var canShoot := true

func _process(delta: float) -> void:
		var input_vector = Vector2.ZERO
		
		input_vector.x = Input.get_action_strength("moveRight") - Input.get_action_strength("moveLeft")
		input_vector.y = Input.get_action_strength("moveDown") - Input.get_action_strength("moveUp")

		input_vector = input_vector.normalized()
		
		velocity = input_vector * speed
		
		move_and_slide()
		
		if input_vector.length() > 0.01:
			aimDir = input_vector
			
			if abs(aimDir.x) > abs(aimDir.y):
				if aimDir.x > 0:
					rotation = deg_to_rad(90)
				else:
					rotation = deg_to_rad(-90)
			else:
				if aimDir.y < 0:
					rotation = 0
				else:
					rotation = deg_to_rad(180)
			
		if Input.is_action_pressed("Shoot"):
			tryShoot()
			
func tryShoot() -> void:
	if not canShoot:
		return
	if bullet == null:
		push_warning("Assigna l'escena de la bullet!")
		return
	
	canShoot = false
	
	var b = bullet.instantiate()
	b.global_position = muzzle.global_position
	
	# ✅ Direcció del tret = on apuntes (ja està bé amb el teu sistema)
	if "direction" in b:
		b.direction = aimDir.normalized()
	
	get_parent().add_child(b)
	
	await get_tree().create_timer(fireCd).timeout
	canShoot = true
