extends Node2D


@export var container_path: NodePath = NodePath("../Asteroids")
@export var asteroidObject: PackedScene
@export var spawnTime: float = 1.2
@export var spawnMargin: float = 80.0
@export var maxVel: float = 260.0
@export var minVel: float = 140.0
@export var desv: float = 0.35

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	if asteroidObject == null:
		push_warning("Assignar asteroid Object!")
		return
	spawnLoop()

func spawnLoop() -> void:
	while true:
		spawnAsteroid()
		await get_tree().create_timer(spawnTime).timeout

func spawnAsteroid() -> void:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return

	var viewportSize: Vector2 = get_viewport_rect().size
	var zoom := cam.zoom
	var half := (viewportSize * 0.5) / zoom
	var center := cam.get_screen_center_position()

	var side := rng.randi_range(0, 3)
	var pos := Vector2.ZERO

	match side:
		0:
			pos = Vector2(rng.randf_range(center.x - half.x, center.x + half.x), center.y - half.y - spawnMargin)
		1:
			pos = Vector2(rng.randf_range(center.x - half.x, center.x + half.x), center.y + half.y + spawnMargin)
		2:
			pos = Vector2(center.x - half.x - spawnMargin, rng.randf_range(center.y - half.y, center.y + half.y))
		3:
			pos = Vector2(center.x + half.x + spawnMargin, rng.randf_range(center.y - half.y, center.y + half.y))

	var asteroid := asteroidObject.instantiate()
	asteroid.global_position = pos
	asteroid.set("asteroid_scene", asteroidObject)

	var score_manager := get_tree().get_first_node_in_group("score_manager")
	if score_manager != null:
		asteroid.connect("destroyed", Callable(score_manager, "add_points"))

	var dir := (center - pos).normalized().rotated(rng.randf_range(-desv, desv))
	if asteroid.has_method("set_direction"):
		asteroid.call("set_direction", dir)
	else:
		asteroid.set("direction", dir)

	asteroid.set("can_split", true)
	asteroid.set("speed", rng.randf_range(minVel, maxVel))

	var container: Node = get_node_or_null(container_path)
	if container != null:
		container.add_child(asteroid)
	else:
		add_child(asteroid)
