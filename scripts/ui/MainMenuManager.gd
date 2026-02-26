## MainMenuManager.gd
## Handles Login/Register, Save Slots, and Animated Background transitions.
## Use with a Control node hierarchy (LoginPanel, RegisterPanel, SlotPanel).

extends Control

# --- Themes & Colors ---
const THEME_BLUE = Color("#1e1b4b")
const THEME_GOLD = Color("#f59e0b")

# --- UI References ---
var login_panel: Panel
var slot_panel: GridContainer
var bg_particles: GPUParticles2D
var bg_gradient: TextureRect
var bg_noise: TextureRect

# --- State ---
var current_user_id: String = ""

func _ready():
	# UI Node Initialization
	login_panel = get_node_or_null("CanvasLayer/LoginPanel")
	slot_panel = get_node_or_null("CanvasLayer/SlotPanel")
	bg_particles = find_child("FloatingParticles", true, false)
	bg_gradient = find_child("GradientBG", true, false)
	bg_noise = find_child("NoiseOverlay", true, false)
	
	# Visual Init
	if bg_gradient or bg_noise:
		_animate_background()
	
	if login_panel:
		login_panel.visible = true
	if slot_panel:
		slot_panel.visible = false
	
	# Connect Signals
	_connect_ui_signals()

func _connect_ui_signals():
	var login_root = login_panel.get_node("VBoxContainer") if login_panel else null
	if not login_root: return
	
	var btn_login = login_root.get_node_or_null("BtnLogin")
	var btn_register = login_root.get_node_or_null("BtnRegister")
	var btn_guest = login_root.get_node_or_null("BtnGuest")
	
	if btn_login:
		btn_login.pressed.connect(_on_login_pressed)
		btn_login.mouse_entered.connect(_play_hover_sound)
	if btn_register:
		btn_register.pressed.connect(_on_register_pressed)
		btn_register.mouse_entered.connect(_play_hover_sound)
	if btn_guest:
		btn_guest.pressed.connect(_on_guest_pressed)
		btn_guest.mouse_entered.connect(_play_hover_sound)

func _play_hover_sound():
	SoundManager.play_auto_sfx("ui_hover", {"pitch_var": 0.05})

func _animate_background():
	if not bg_gradient: return
	# Color shifting and floating movement
	var tween = create_tween().set_loops().set_parallel(true)
	
	# Float effect
	tween.tween_property(bg_gradient, "position", Vector2(10, 10), 4.0).set_trans(Tween.TRANS_SINE)
	tween.chain().tween_property(bg_gradient, "position", Vector2(-10, -10), 4.0).set_trans(Tween.TRANS_SINE)
	
	# Color shift (Glow intensity)
	tween.tween_property(bg_gradient, "modulate", Color(1.2, 1.0, 1.5, 1.0), 3.0).set_trans(Tween.TRANS_SINE)
	tween.chain().tween_property(bg_gradient, "modulate", Color(1.0, 1.0, 1.0, 1.0), 3.0).set_trans(Tween.TRANS_SINE)
	
	if bg_noise:
		# Noise scrolling parallax
		tween.tween_property(bg_noise, "position", Vector2(-20, -20), 10.0).set_trans(Tween.TRANS_LINEAR)
		tween.chain().tween_property(bg_noise, "position", Vector2(0, 0), 10.0).set_trans(Tween.TRANS_LINEAR)

# --- Auth Logic ---
func _on_login_pressed():
	var username = $CanvasLayer/LoginPanel/VBoxContainer/UsernameField.text
	var password = $CanvasLayer/LoginPanel/VBoxContainer/PasswordField.text
	
	if username != "" and password != "":
		current_user_id = username
		_transition_to_slots()
	else:
		_show_error("Invalid Credentials")

func _on_register_pressed():
	# Create account logic (Simulation)
	var username = $CanvasLayer/LoginPanel/VBoxContainer/UsernameField.text
	if username.length() < 3:
		_show_error("ID must be 3+ letters")
		return
	
	_show_error("Account Created: " + username)
	SoundManager.play_auto_sfx("ui_success")

func _on_guest_pressed():
	current_user_id = "Guest_" + str(randi() % 9999)
	_transition_to_slots()
	SoundManager.play_auto_sfx("ui_click")

func _on_confirm_registration():
	# In a real game, you'd save this to a local SQLite or ConfigFile
	_show_error("Registration Successful")
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
	get_tree().change_scene_to_file("res://scenes/Level_1.tscn")

func _show_error(msg: String):
	$CanvasLayer/ErrorLabel.text = msg
	var tween = create_tween()
	tween.tween_property($CanvasLayer/ErrorLabel, "modulate:a", 1.0, 0.2)
	tween.tween_interval(2.0)
	tween.tween_property($CanvasLayer/ErrorLabel, "modulate:a", 0.0, 0.5)
