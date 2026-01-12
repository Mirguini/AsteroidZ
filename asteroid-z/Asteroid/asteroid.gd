extends CharacterBody2D
signal destroyed(points: int)

@export var offscreen_despawn_time := 3.0
@export var hit_cd := 0.35
@export var score_value: int = 100
@export var speed: float = 200.0
@export var rotation_speed: float = 2.5
@export var can_split: bool = true
@export var asteroid_scene: PackedScene
@export var child_scale: float = 0.65
@export var child_speed_multiplier: float = 1.2
@export var split_angle_spread: float = 0.6
@export var spawn_separation: float = 10.0
@export var explosion_sfx_scene: PackedScene

@export var asteroid_bounce_cd := 0.08
@export var bounce_separation := 2.0
var _bounce_timer := 0.0



var _offscreen_timer := 0.0
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
	_bounce_timer = max(0.0, _bounce_timer - delta)

	velocity = direction * speed
	move_and_slide()
	rotation += rotation_speed * delta

	if _bounce_timer > 0.0:
		return

	var count := get_slide_collision_count()
	for i in count:
		var c := get_slide_collision(i)
		var other := c.get_collider()
		if other != null and other.is_in_group("asteroids"):
			var n := c.get_normal()
			bounce_from(n)
			if other.has_method("bounce_from"):
				other.call_deferred("bounce_from", -n)
			break


func _process(delta: float) -> void:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return

	var viewport_size := get_viewport_rect().size
	var zoom := cam.zoom
	var half := (viewport_size * 0.5) / zoom
	var center := cam.get_screen_center_position()
	var rect := Rect2(center - half, half * 2.0)

	rect = rect.grow(200.0)

	if rect.has_point(global_position):
		_offscreen_timer = 0.0
	else:
		_offscreen_timer += delta
		if _offscreen_timer >= offscreen_despawn_time:
			queue_free()


func destroy() -> void:
	call_deferred("_destroy_deferred")

func _destroy_deferred() -> void:
	emit_signal("destroyed", score_value)

	if explosion_sfx_scene != null:
		var sfx := explosion_sfx_scene.instantiate()
		get_parent().add_child(sfx)
		sfx.global_position = global_position

	if can_split:
		_split_into_two()

	queue_free()

func bounce_from(normal: Vector2) -> void:
	if _bounce_timer > 0.0:
		return
	_bounce_timer = asteroid_bounce_cd
	set_direction(direction.bounce(normal).normalized())
	global_position += normal * bounce_separation




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
			
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("take_hit"):
		body.call_deferred("take_hit")
		set_direction((global_position - body.global_position).normalized())
