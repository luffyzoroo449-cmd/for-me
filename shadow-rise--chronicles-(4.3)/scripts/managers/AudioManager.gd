## AudioManager.gd
## Advanced Audio System for Orchestral Adaptive Music and Environmental Ambience.
## Handles dynamic crossfading and reverb zones.

extends Node

# --- Music Layers ---
@onready var music_calm: AudioStreamPlayer = $MusicCalm
@onready var music_combat: AudioStreamPlayer = $MusicCombat
@onready var music_boss: AudioStreamPlayer = $MusicBoss

# --- Ambience ---
@onready var ambient_player: AudioStreamPlayer = $Ambience

# --- Internal State ---
var current_intensity: float = 0.0 # 0.0 (calm) to 1.0 (combat)
var is_boss_fight: bool = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_start_music()

func _process(delta: float):
	if not is_boss_fight:
		_handle_adaptive_music(delta)
	else:
		_handle_boss_music(delta)

func _handle_adaptive_music(delta: float):
	# Calculate target intensity based on enemy proximity (queried from GameWorld)
	var target_intensity = get_tree().get_first_node_in_group("game_world").get_combat_intensity()
	current_intensity = lerp(current_intensity, target_intensity, delta * 0.5)
	
	music_calm.volume_db = linear_to_db(1.0 - current_intensity)
	music_combat.volume_db = linear_to_db(current_intensity)
	music_boss.volume_db = -80 # Muted

func _handle_boss_music(delta: float):
	music_calm.volume_db = lerp(music_calm.volume_db, -80.0, delta)
	music_combat.volume_db = lerp(music_combat.volume_db, -80.0, delta)
	music_boss.volume_db = lerp(music_boss.volume_db, 0.0, delta)

func start_boss_fight():
	is_boss_fight = true

func stop_boss_fight():
	is_boss_fight = false

func play_sfx(sfx_name: String, position: Vector2 = Vector2.ZERO):
	# Reusable SFX pooling logic or one-shot at position
	var player = AudioStreamPlayer2D.new()
	player.stream = load("res://assets/audio/sfx/" + sfx_name + ".mp3")
	player.global_position = position
	get_tree().root.add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

func set_ambience(zone_name: String):
	var stream = load("res://assets/audio/ambient/" + zone_name + ".mp3")
	if ambient_player.stream != stream:
		var tween = create_tween()
		tween.tween_property(ambient_player, "volume_db", -80, 1.0)
		tween.tween_callback(func(): 
			ambient_player.stream = stream
			ambient_player.play()
		)
		tween.tween_property(ambient_player, "volume_db", 0.0, 1.0)
