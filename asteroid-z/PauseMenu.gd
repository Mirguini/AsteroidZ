extends CanvasLayer

@export var audio_bus_name := "Master"

@onready var resume_button: Button = $Root/Panel/VBoxContainer/ResumeButton
@onready var restart_button: Button = $Root/Panel/VBoxContainer/RestartButton
@onready var volume_slider: HSlider = $Root/Panel/VBoxContainer/HBoxContainer/VolumeSlider

var _bus := -1

func _ready() -> void:
	_bus = AudioServer.get_bus_index(audio_bus_name)
	visible = false
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)

	# Inicia el slider con el volumen actual del bus.
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(_bus))
	volume_slider.value_changed.connect(_on_volume_changed)

func open() -> void:
	visible = true
	resume_button.grab_focus()

func close() -> void:
	visible = false

func _on_resume_pressed() -> void:
	get_tree().paused = false
	close()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	close()
	get_tree().reload_current_scene()

func _on_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(_bus, linear_to_db(value))
