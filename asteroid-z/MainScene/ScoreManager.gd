extends Node

@export var label_path: NodePath
var score: int = 0
var label: Label

func _ready() -> void:
	label = get_node_or_null(label_path) as Label
	if label == null:
		push_error("ScoreManager: No trobo el Label. Revisa 'label_path' a l'Inspector.")
		return
	label.text = "Puntuació: %d" % score
	add_to_group("score_manager")

func add_points(value: int) -> void:
	var mult := 1

	var player := get_tree().get_first_node_in_group("player")
	if player != null and "score_multiplier" in player:
		mult = int(player.score_multiplier)

	score += value * mult

	if label != null:
		label.text = "Puntuació: %d" % score
