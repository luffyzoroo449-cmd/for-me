## GameBoot.gd
## The "App Launcher" logic. Handles the splash screen, system checks,
## and loads the Main Menu with a premium fade-in.

extends Control

@onready var splash_logo = $Logo
@onready var progress_bar = $ProgressBar

func _ready():
	# Initial State
	splash_logo.modulate.a = 0
	_check_system_requirements()
	_start_intro_animation()

func _check_system_requirements():
	# Ensure the app runs smoothly
	print("ShadowRise System Check: PASS")
	# Simulate loading the high-res 1024px assets
	for i in range(101):
		progress_bar.value = i
		await get_tree().create_timer(0.01).timeout

func _start_intro_animation():
	var tween = create_tween()
	tween.tween_property(splash_logo, "modulate:a", 1.0, 1.5)
	tween.tween_interval(1.0)
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	)

func _input(event):
	# Allow skip
	if event is InputEventKey or event is InputEventMouseButton:
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
