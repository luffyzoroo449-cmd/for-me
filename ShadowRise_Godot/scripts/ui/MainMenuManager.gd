## MainMenuManager.gd
## Handles Login/Register, Save Slots, and Animated Background transitions.
## Use with a Control node hierarchy (LoginPanel, RegisterPanel, SlotPanel).

extends Control

# --- Themes & Colors ---
const THEME_BLUE = Color("#1e1b4b")
const THEME_GOLD = Color("#f59e0b")

# --- UI References ---
@onready var login_panel: Panel = $CanvasLayer/LoginPanel
@onready var register_panel: Panel = $CanvasLayer/RegisterPanel
@onready var slot_panel: GridContainer = $CanvasLayer/SlotPanel
@onready var bg_particles: GPUParticles2D = $Background/FloatingParticles

# --- State ---
var current_user_id: String = ""

func _ready():
	# Visual Init
	_animate_background()
	login_panel.visible = true
	if register_panel: register_panel.visible = false
	slot_panel.visible = false
	
	# Connect Signals
	var btn_login = $CanvasLayer/LoginPanel/VBoxContainer/BtnLogin
	var btn_register = $CanvasLayer/LoginPanel/VBoxContainer/BtnRegister
	
	btn_login.pressed.connect(_on_login_pressed)
	btn_register.pressed.connect(_on_register_pressed)
	
	btn_login.mouse_entered.connect(_play_hover_sound)
	btn_register.mouse_entered.connect(_play_hover_sound)

func _play_hover_sound():
	SoundManager.play_auto_sfx("ui_hover", {"pitch_var": 0.05})

func _animate_background():
	# Subtle floating movement for the background image
	var tween = create_tween().set_loops()
	tween.tween_property($Background/Sprite, "position", Vector2(10, 10), 4.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property($Background/Sprite, "position", Vector2(-10, -10), 4.0).set_trans(Tween.TRANS_SINE)

# --- Auth Logic ---
func _on_login_pressed():
	var username = $CanvasLayer/LoginPanel/UsernameField.text
	var password = $CanvasLayer/LoginPanel/PasswordField.text
	
	if username != "" and password != "":
		current_user_id = username
		_transition_to_slots()
	else:
		_show_error("Invalid Credentials")

func _on_register_pressed():
	login_panel.visible = false
	register_panel.visible = true

func _on_confirm_registration():
	# In a real game, you'd save this to a local SQLite or ConfigFile
	_show_error("Registration Successful")
	register_panel.visible = false
	login_panel.visible = true

# --- Save Slots ---
func _transition_to_slots():
	login_panel.visible = false
	slot_panel.visible = true
	_populate_save_slots()

func _populate_save_slots():
	for i in range(3): # 3 Save slots
		var slot_btn = Button.new()
		slot_btn.text = "SAVE SLOT " + str(i+1)
		slot_btn.custom_minimum_size = Vector2(200, 80)
		slot_btn.pressed.connect(_load_game_slot.bind(i))
		slot_panel.add_child(slot_btn)

func _load_game_slot(slot_index: int):
	print("Loading Slot: ", slot_index)
	# GameManager carries the persistent data
	GameManager.player_name = current_user_id
	get_tree().change_scene_to_file("res://scenes/WorldMap.tscn")

func _show_error(msg: String):
	$CanvasLayer/ErrorLabel.text = msg
	var tween = create_tween()
	tween.tween_property($CanvasLayer/ErrorLabel, "modulate:a", 1.0, 0.2)
	tween.tween_interval(2.0)
	tween.tween_property($CanvasLayer/ErrorLabel, "modulate:a", 0.0, 0.5)
