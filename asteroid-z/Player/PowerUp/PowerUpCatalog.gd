extends Resource
class_name PowerUpCatalog

@export var triple_shot_sprite: Texture2D
@export var rapid_fire_sprite: Texture2D
@export var double_damage_sprite: Texture2D
@export var shield_sprite: Texture2D

func get_sprite(t: PowerUpTypes.Type) -> Texture2D:
	match t:
		PowerUpTypes.Type.TRIPLE_SHOT: return triple_shot_sprite
		PowerUpTypes.Type.RAPID_FIRE: return rapid_fire_sprite
		PowerUpTypes.Type.DOUBLE_DAMAGE: return double_damage_sprite
		PowerUpTypes.Type.SHIELD: return shield_sprite
		_: return null
