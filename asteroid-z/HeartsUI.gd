extends HBoxContainer

var _player: Node = null
var _hearts: Array[TextureRect] = []

func _ready() -> void:
	_hearts = []
	for c in get_children():
		if c is TextureRect:
			_hearts.append(c)

	# Espera 1 frame para que el PlayerSpawner haya instanciado al jugador.
	await get_tree().process_frame

	_player = get_tree().get_first_node_in_group("player")
	if _player == null:
		push_warning("HeartsUI: no encuentro un nodo en el grupo 'player'.")
		return

	_player.connect("health_changed", Callable(self, "_on_health_changed"))

func _on_health_changed(current: int, max: int) -> void:
	# Muestra tantos corazones como vida haya
	for i in range(_hearts.size()):
		_hearts[i].modulate.a = 1.0 if i < current else 0.2
