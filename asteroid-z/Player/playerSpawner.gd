extends Node2D

@export var player_scene: PackedScene

func _ready() -> void:
	if player_scene == null:
		push_error("Assigna Player.tscn a player_scene")
		return
	
	var player = player_scene.instantiate()
	player.global_position = get_viewport_rect().size / 2
	add_child(player)
