## SoundManager.gd
## The Central Audio Hub. Handles automatic event-driven sounds and adaptive music transitions.

extends Node

# --- Audio Bus Names ---
const BUS_MASTER = "Master"
const BUS_MUSIC = "Music"
const BUS_SFX = "SFX"
const BUS_AMBIENT = "Ambient"

# --- Audio Stream Players ---
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var ambient_player: AudioStreamPlayer = $AmbientPlayer
@onready var ui_player: AudioStreamPlayer = $UIPlayer

# --- Adaptive State ---
enum GameMood { CALM, SUSPENSE, COMBAT, BOSS, VICTORY, STORY }
var current_mood = GameMood.CALM

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_buses()

func _setup_buses():
	# Ensure buses are linked correctly in Godot's Audio tab
	pass

# --- 1. AUTOMATIC SOUND TRIGGERING ---
# Call this from any script: SoundManager.play_auto_sfx("step", {"material": "stone"})
func play_auto_sfx(event: String, data: Dictionary = {}):
	var stream = _get_stream_for_event(event, data)
	if not stream: return

	# Use AudioStreamPlayer2D if position is provided
	if data.has("position"):
		_play_spatial_sfx(stream, data["position"], data.get("pitch_var", 0.1))
	else:
		_play_global_sfx(stream, data.get("pitch_var", 0.1))

func _get_stream_for_event(event: String, data: Dictionary) -> AudioStream:
	# This functions as a central lookup table
	match event:
		"step":
			var mat = data.get("material", "grass")
			return load("res://assets/audio/sfx/footsteps/" + mat + ".wav")
		"jump": return load("res://assets/audio/sfx/player/jump_whoosh.wav")
		"hurt": return load("res://assets/audio/sfx/player/grunt.wav")
		"clash": return load("res://assets/audio/sfx/combat/metal_clash.wav")
		"alert": return load("res://assets/audio/sfx/enemy/detect.wav")
	return null

# --- 2. DYNAMIC MUSIC SYSTEM ---
func transition_to(mood: GameMood):
	if current_mood == mood: return
	current_mood = mood
	
	var track_path = _get_music_for_mood(mood)
	var new_track = load(track_path)
	
	# Smooth Crossfade
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", -80, 1.5)
	tween.tween_callback(func():
		music_player.stream = new_track
		music_player.play()
	)
	tween.tween_property(music_player, "volume_db", 0, 1.5)

func _get_music_for_mood(mood: GameMood) -> String:
	match mood:
		GameMood.COMBAT: return "res://assets/audio/bgm/combat_intense.mp3"
		GameMood.BOSS: return "res://assets/audio/bgm/boss_choir.mp3"
		GameMood.SUSPENSE: return "res://assets/audio/bgm/suspense_strings.mp3"
		_: return "res://assets/audio/bgm/exploration_calm.mp3"

# --- 3. HELPER METHODS ---
func _play_spatial_sfx(stream: AudioStream, pos: Vector2, pitch_v: float):
	var p = AudioStreamPlayer2D.new()
	p.stream = stream
	p.bus = BUS_SFX
	p.global_position = pos
	p.pitch_scale = randf_range(1.0 - pitch_v, 1.0 + pitch_v)
	get_tree().root.add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

func _play_global_sfx(stream: AudioStream, pitch_v: float):
	var p = AudioStreamPlayer.new()
	p.stream = stream
	p.bus = BUS_SFX
	p.pitch_scale = randf_range(1.0 - pitch_v, 1.0 + pitch_v)
	get_tree().root.add_child(p)
	p.play()
	p.finished.connect(p.queue_free)
