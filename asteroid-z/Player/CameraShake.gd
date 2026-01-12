extends Camera2D

@export var default_shake_strength := 8.0
@export var default_shake_time := 0.18

var _shake_time := 0.0
var _shake_strength := 0.0
var _base_offset := Vector2.ZERO
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	_base_offset = offset

func shake(strength: float = -1.0, time: float = -1.0) -> void:
	if strength < 0.0:
		strength = default_shake_strength
	if time < 0.0:
		time = default_shake_time
	_shake_strength = max(_shake_strength, strength)
	_shake_time = max(_shake_time, time)

func _process(delta: float) -> void:
	if _shake_time > 0.0:
		_shake_time -= delta
		offset = _base_offset + Vector2(
			_rng.randf_range(-_shake_strength, _shake_strength),
			_rng.randf_range(-_shake_strength, _shake_strength)
		)
	else:
		offset = _base_offset
		_shake_strength = 0.0
