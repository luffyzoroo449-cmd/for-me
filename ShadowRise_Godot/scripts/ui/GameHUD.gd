## GameHUD.gd
## Premium UI logic with animated progress bars & glow effects.

extends CanvasLayer

@onready var hp_bar: ProgressBar = $Control/Stats/HPBar
@onready var mp_bar: ProgressBar = $Control/Stats/MPBar
@onready var stamina_bar: ProgressBar = $Control/Stats/StaminaBar
@onready var level_lbl: Label = $Control/Character/LevelLabel

func _ready():
	_setup_styles()

func _process(_delta: float):
	# Smoothly interpolate bars
	hp_bar.value = lerp(hp_bar.value, GameManager.hp, 0.1)
	mp_bar.value = lerp(mp_bar.value, GameManager.mp, 0.1)
	stamina_bar.value = lerp(stamina_bar.value, GameManager.stamina, 0.1)
	
	level_lbl.text = "LEVEL " + str(GameManager.level)

func _setup_styles():
	# Applying the 'Premium Gold' look to levels and 'Magical Glow' to MP
	var mp_style = mp_bar.get_theme_stylebox("fill")
	mp_style.bg_color = GameManager.COLOR_MAGICAL_GLOW
	
	var stamina_style = stamina_bar.get_theme_stylebox("fill")
	stamina_style.bg_color = Color("#22c55e") # Green

	# Glow effect using a parent modulating node or WorldEnvironment
	$Control/Stats.modulate = Color(1.2, 1.2, 1.2) # HDR Glow
