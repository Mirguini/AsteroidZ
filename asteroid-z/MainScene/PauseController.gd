extends Node

@export var pause_menu_path: NodePath
@onready var pause_menu: CanvasLayer = get_node(pause_menu_path)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	if pause_menu != null:
		pause_menu.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause()
		get_viewport().set_input_as_handled()

func _toggle_pause() -> void:
	var new_paused := not get_tree().paused
	get_tree().paused = new_paused
	if pause_menu == null:
		return
	if new_paused:
		pause_menu.call("open")
	else:
		pause_menu.call("close")
