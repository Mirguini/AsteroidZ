extends CanvasLayer

@onready var mat := $ColorRect.material as ShaderMaterial

func _process(delta):
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return
	mat.set_shader_parameter("camera_offset", cam.global_position / 8000.0)
