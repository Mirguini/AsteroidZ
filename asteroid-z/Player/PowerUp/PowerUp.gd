extends Area2D
class_name PowerUp

@export var power_type: PowerUpTypes.Type = PowerUpTypes.Type.TRIPLE_SHOT
@export var duration := 8.0
@export var drift_speed := 70.0
@export var lifetime := 10.0

@export var catalog: PowerUpCatalog
@export var default_sprite: Texture2D # opcional, per evitar invisibles
@onready var sprite: Sprite2D = $Sprite2D

var _dir: Vector2

func setup(new_type: PowerUpTypes.Type, new_duration: float) -> void:
	power_type = new_type
	duration = new_duration
	_update_sprite()

func _update_sprite() -> void:
	if sprite == null:
		return
	var tex: Texture2D = null
	if catalog != null:
		tex = catalog.get_sprite(power_type)
	sprite.texture = tex if tex != null else default_sprite

func _ready() -> void:
	_dir = Vector2.RIGHT.rotated(randf() * TAU)
	body_entered.connect(_on_body_entered)

	_update_sprite()

	# Auto-despawn (un sol cop)
	await get_tree().create_timer(lifetime).timeout
	if is_inside_tree():
		queue_free()

func _physics_process(delta: float) -> void:
	global_position += _dir * drift_speed * delta

func _on_body_entered(body: Node) -> void:
	print("POWERUP touched by:", body.name, " type:", body.get_class())
	print("is player group?", body.is_in_group("player"), " has add_powerup?", body.has_method("add_powerup"))
	if body.is_in_group("player") and body.has_method("add_powerup"):
		body.add_powerup(power_type, duration)
		queue_free()
