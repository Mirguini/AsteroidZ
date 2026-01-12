extends Resource
class_name PowerUpDrop

@export var type: PowerUpTypes.Type = PowerUpTypes.Type.TRIPLE_SHOT
@export_range(0.0, 100.0, 0.1) var weight := 1.0
@export var duration := 8.0
