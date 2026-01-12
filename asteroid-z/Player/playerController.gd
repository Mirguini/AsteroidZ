extends CharacterBody2D

signal health_changed(current: int, max: int)
signal died

@export var max_health: int = 5
var health: int

@export var speed := 600.0
@export var hit_cd := 0.35

@export var bullet: PackedScene
@export var fireCd: float = 0.15

@onready var shoot_sfx: AudioStreamPlayer2D = $ShootSfx
@onready var die_sfx: AudioStreamPlayer2D = $DieSfx
@onready var muzzle: Marker2D = $Muzzle

var _can_take_hit := true
var canShoot := true
var aimDir := Vector2.RIGHT


func _ready() -> void:
	add_to_group("player")
	health = max_health
	emit_signal("health_changed", health, max_health)


func _process(delta: float) -> void:
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("moveRight") - Input.get_action_strength("moveLeft")
	input_vector.y = Input.get_action_strength("moveDown") - Input.get_action_strength("moveUp")
	input_vector = input_vector.normalized()

	velocity = input_vector * speed
	move_and_slide()

	if input_vector.length() > 0.01:
		aimDir = _snap_to_cardinal(input_vector)
		_apply_rotation_from_aim(aimDir)

	if Input.is_action_pressed("Shoot"):
		tryShoot()


func _snap_to_cardinal(v: Vector2) -> Vector2:
	if abs(v.x) > abs(v.y):
		return Vector2.RIGHT if v.x > 0.0 else Vector2.LEFT
	else:
		return Vector2.DOWN if v.y > 0.0 else Vector2.UP


func _apply_rotation_from_aim(dir: Vector2) -> void:
	if dir == Vector2.RIGHT:
		rotation = deg_to_rad(90)
	elif dir == Vector2.LEFT:
		rotation = deg_to_rad(-90)
	elif dir == Vector2.UP:
		rotation = 0.0
	else:
		rotation = deg_to_rad(180)


func tryShoot() -> void:
	if not canShoot:
		return
	if bullet == null:
		push_warning("Assigna l'escena de la bullet!")
		return

	canShoot = false

	if shoot_sfx != null:
		shoot_sfx.stop()
		shoot_sfx.play()

	var b = bullet.instantiate()
	b.global_position = muzzle.global_position
	if "direction" in b:
		b.direction = aimDir

	get_parent().add_child(b)

	await get_tree().create_timer(fireCd).timeout
	canShoot = true


func take_hit() -> void:
	if not _can_take_hit:
		return

	_can_take_hit = false

	# Restar vida y avisar al HUD
	health = max(0, health - 1)
	emit_signal("health_changed", health, max_health)

	# Si muere, suena y reinicia
	if health <= 0:
		emit_signal("died")

		if die_sfx != null:
			die_sfx.play()
			# Si finished te da problemas, dímelo y lo cambiamos por un Timer.
			await die_sfx.finished

		get_tree().call_deferred("reload_current_scene")
		return

	# Efectos de daño (lo que ya tenías)
	var flash := get_tree().get_first_node_in_group("damage_flash")
	if flash != null:
		flash.call("flash")

	var cam := $Camera2D
	if cam != null and cam.has_method("shake"):
		cam.call("shake")

	var sprite := $Sprite2D
	if sprite != null:
		sprite.modulate.a = 0.4

	await get_tree().create_timer(hit_cd).timeout

	if sprite != null:
		sprite.modulate.a = 1.0

	_can_take_hit = true
