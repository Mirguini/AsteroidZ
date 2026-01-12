extends ColorRect

@export var peak_alpha := 0.25
@export var in_time := 0.05
@export var out_time := 0.18

var _tween: Tween

func _ready() -> void:
	add_to_group("damage_flash")

func flash() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	var c := color
	c.a = 0.0
	color = c
	visible = true
	_tween = create_tween()
	_tween.tween_property(self, "color:a", peak_alpha, in_time)
	_tween.tween_property(self, "color:a", 0.0, out_time)
