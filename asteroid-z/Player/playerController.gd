extends CharacterBody2D

@onready var shoot_sfx: AudioStreamPlayer2D = $ShootSfx
@onready var pickup_sfx: AudioStreamPlayer2D = $PickupSfx

@onready var shield_sprite: Sprite2D = $ShieldSprite

@export var speed := 600.0
@export var hit_cd := 0.35
@export var bullet: PackedScene
@export var fireCd: float = 0.15
@onready var muzzle: Marker2D = $Muzzle
@export var triple_spread_deg := 12.0

var active_powerups: Dictionary = {}
# type -> SceneTreeTimer
var score_multiplier := 1

var _can_take_hit := true
var aimDir := Vector2.RIGHT
var canShoot := true

func _ready() -> void:
	if shield_sprite != null:
		shield_sprite.visible = false


func _physics_process(delta: float) -> void:
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

	if has_powerup(PowerUpTypes.Type.TRIPLE_SHOT):
		_shoot_triple()
	else:
		_shoot_single()

	await get_tree().create_timer(fireCd).timeout
	canShoot = true

func _shoot_single() -> void:
	var b = bullet.instantiate()
	b.global_position = muzzle.global_position

	if "direction" in b:
		b.direction = aimDir

	get_parent().add_child(b)


func _shoot_triple() -> void:
	var spread := deg_to_rad(triple_spread_deg)

	_spawn_bullet(aimDir.rotated(-spread))
	_spawn_bullet(aimDir)
	_spawn_bullet(aimDir.rotated(spread))

func _spawn_bullet(dir: Vector2) -> void:
	var b = bullet.instantiate()
	b.global_position = muzzle.global_position

	if "direction" in b:
		b.direction = dir.normalized()

	get_parent().add_child(b)

func take_hit() -> void:
	if has_powerup(PowerUpTypes.Type.SHIELD):
		active_powerups.erase(PowerUpTypes.Type.SHIELD)

		if shield_sprite != null:
			shield_sprite.visible = false
		return

	if not _can_take_hit:
		return

	_can_take_hit = false

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

	
func add_powerup(type: PowerUpTypes.Type, duration: float) -> void:
	if pickup_sfx != null:
		pickup_sfx.stop()
		pickup_sfx.play()

	if type == PowerUpTypes.Type.SHIELD and shield_sprite != null:
		shield_sprite.visible = true

	# ✖️2 SCORE
	if type == PowerUpTypes.Type.DOUBLE_DAMAGE:
		score_multiplier = 2

	var t := get_tree().create_timer(duration)
	active_powerups[type] = t

	t.timeout.connect(func():
		if active_powerups.get(type) == t:
			active_powerups.erase(type)

			if type == PowerUpTypes.Type.SHIELD and shield_sprite != null:
				shield_sprite.visible = false

			if type == PowerUpTypes.Type.DOUBLE_DAMAGE:
				score_multiplier = 1
	)




func has_powerup(type: PowerUpTypes.Type) -> bool:
	return active_powerups.has(type)
