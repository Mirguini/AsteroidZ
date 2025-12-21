extends Node2D

@export var container_path: NodePath = NodePath("../Asteroids")

@export var asteroidObject: PackedScene
@export var spawnTime: float = 1.2
@export var spawnMargin: float = 80.0

@export var maxVel: float = 260.0
@export var minVel: float = 140.0

@export var desv: float = 0.35

var rng := RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if asteroidObject == null:
		push_warning("Assignar asteroid Object!")
		return
	spawnLoop()

func spawnLoop() -> void:
	while true: #aplicar mentre el jugador està viu
		spawnAsteroid()
		await get_tree().create_timer(spawnTime).timeout

func spawnAsteroid() -> void:
	var viewportSize: Vector2 = get_viewport_rect().size
	
	var side := rng.randi_range(0,3)
	var pos := Vector2.ZERO
	
	match side:
		0:
			pos = Vector2(rng.randf_range(0.0, viewportSize.x), -spawnMargin)
		1:
			pos = Vector2(rng.randf_range(0.0, viewportSize.x), viewportSize.y + spawnMargin)
		2: 
			pos = Vector2(-spawnMargin, rng.randf_range(0.0, viewportSize.y))
		3:
			pos = Vector2(viewportSize.x + spawnMargin, rng.randf_range(0.0, viewportSize.y))

	var asteroid := asteroidObject.instantiate()
	asteroid.global_position = pos
	
	var center := viewportSize * 0.5
	var dir := (center - pos).normalized().rotated(rng.randf_range(-desv, desv))
	if asteroid.has_method("set_direction"):
		asteroid.call("set_direction", dir)
	elif "direction" in asteroid:
		asteroid.direction = dir
	
	var vel := rng.randf_range(minVel, maxVel)
	if "vel" in asteroid:
		asteroid.vel = vel
		
	var container: Node = get_node_or_null(container_path)
	if container != null:
		container.add_child(asteroid)
	else:
		add_child(asteroid)
			
		
