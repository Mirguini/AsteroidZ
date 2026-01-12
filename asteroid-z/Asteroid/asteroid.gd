extends CharacterBody2D
signal destroyed(points: int)

@export var score_value: int = 100

@export var speed: float = 200.0
@export var rotation_speed: float = 2.5

@export var can_split: bool = true
@export var asteroid_scene: PackedScene
@export var child_scale: float = 0.65
@export var child_speed_multiplier: float = 1.2
@export var split_angle_spread: float = 0.6
@export var spawn_separation: float = 10.0

var direction: Vector2 = Vector2.RIGHT
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	rotation = _rng.randf_range(0.0, TAU)
	rotation_speed *= _rng.randf_range(0.6, 1.4)
	speed *= _rng.randf_range(0.85, 1.15)

func set_direction(dir: Vector2) -> void:
	if dir.length() > 0.001:
		direction = dir.normalized()

func _physics_process(delta: float) -> void:
	velocity = direction * speed
	move_and_slide()
	rotation += rotation_speed * delta

func _process(_delta: float) -> void:
	var r := get_viewport_rect()
	var margin := 250.0
	if global_position.x < -margin or global_position.x > r.size.x + margin \
	or global_position.y < -margin or global_position.y > r.size.y + margin:
		queue_free()

func destroy() -> void:
	call_deferred("_destroy_deferred")

func _destroy_deferred() -> void:
	emit_signal("destroyed", score_value)
	if can_split:
		_split_into_two()
	queue_free()



func _split_into_two() -> void:
	if asteroid_scene == null:
		return

	var base_dir := direction
	if base_dir.length() < 0.001:
		base_dir = Vector2.RIGHT.rotated(_rng.randf_range(0.0, TAU))
	base_dir = base_dir.normalized()

	var a1 := _rng.randf_range(-split_angle_spread, split_angle_spread)
	var a2 := -a1 + _rng.randf_range(-0.25, 0.25)

	var dirs := [
		base_dir.rotated(a1).normalized(),
		base_dir.rotated(a2).normalized()
	]

	for i in 2:
		var child := asteroid_scene.instantiate()
		get_parent().call_deferred("add_child", child)
		child.set_deferred("global_position", global_position + dirs[i] * spawn_separation)
		child.set_deferred("scale", scale * child_scale)
		child.set_deferred("can_split", false)
		child.set_deferred("speed", speed * child_speed_multiplier)
		child.set_deferred("score_value", int(score_value * 0.5))

		if child.has_method("set_direction"):
			child.call_deferred("set_direction", dirs[i])
		else:
			child.set_deferred("direction", dirs[i])
