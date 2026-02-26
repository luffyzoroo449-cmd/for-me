## AudioEnvironmentZone.gd
## Attach to an Area2D to automatically change the acoustic properties of a zone.

extends Area2D

@export_enum("Cave", "Underwater", "Forest", "Lava") var zone_type: String = "Forest"
@onready var sfx_bus_idx = AudioServer.get_bus_index("SFX")

func _ready():
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)

func _on_enter(body):
	if body.is_in_group("player"):
		_apply_effects(true)

func _on_exit(body):
	if body.is_in_group("player"):
		_apply_effects(false)

func _apply_effects(active: bool):
	match zone_type:
		"Cave":
			# Enable Reverb effect on SFX bus (Assuming Slot 0)
			AudioServer.set_bus_effect_enabled(sfx_bus_idx, 0, active)
		"Underwater":
			# Enable Low-Pass Filter on Master bus
			AudioServer.set_bus_effect_enabled(0, 1, active)
			if active:
				SoundManager.ambient_player.stream = load("res://assets/audio/ambient/underwater_muffled.mp3")
				SoundManager.ambient_player.play()
		"Lava":
			# Increase "Warmth" or Distortion
			pass
