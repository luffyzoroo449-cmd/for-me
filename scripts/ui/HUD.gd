## HUD.gd
## Attach to: Control node inside a CanvasLayer
##
## Node structure:
##   Control (HUD.gd)
##   ├── HBoxContainer "HealthBar"
##   │   └── (3× TextureRect hearts)
##   ├── Label "TimerLabel"
##   ├── Label "LevelLabel"
##   ├── HBoxContainer "CoinRow"
##   │   ├── Label "CoinIcon" (🪙)
##   │   └── Label "CoinCount"
##   ├── VBoxContainer "WeaponInfo"
##   │   ├── Label "WeaponName"
##   │   ├── HBoxContainer "AmmoPips"
##   │   └── Label "ReloadLabel"
##   └── Label "GemCount"

extends Control

const MAX_HEALTH := 3

@onready var coin_count_label: Label = $CoinRow/CoinCount
@onready var gem_count_label: Label = $GemCount
@onready var timer_label: Label = $TimerLabel
@onready var level_label: Label = $LevelLabel
@onready var weapon_name_label: Label = $WeaponInfo/WeaponName
@onready var ammo_pips_container: HBoxContainer = $WeaponInfo/AmmoPips
@onready var reload_label: Label = $WeaponInfo/ReloadLabel
@onready var health_container: HBoxContainer = $HealthBar

var heart_icons: Array = []

func _ready() -> void:
	reload_label.visible = false
	for i in range(MAX_HEALTH):
		var icon := Label.new()
		icon.text = "❤️"
		icon.add_theme_font_size_override("font_size", 20)
		health_container.add_child(icon)
		heart_icons.append(icon)

# ─── Called from GameWorld ────────────────────────────────────────────────────
func init_level(level_id: int, world_id: int, initial_health: int) -> void:
	level_label.text = "World %d — Level %d" % [world_id, level_id]
	update_health(initial_health)
	coin_count_label.text = "0"
	gem_count_label.text = "0"

func update_timer(seconds: float) -> void:
	var mins := int(seconds) / 60
	var secs := int(seconds) % 60
	timer_label.text = "%02d:%02d" % [mins, secs]

func update_health(new_health: int) -> void:
	for i in range(heart_icons.size()):
		heart_icons[i].modulate.a = 1.0 if i < new_health else 0.2
		# Scale pulse on damage
		if i == new_health:
			var tween := create_tween()
			tween.tween_property(heart_icons[i], "scale", Vector2(1.3, 1.3), 0.1)
			tween.tween_property(heart_icons[i], "scale", Vector2(1.0, 1.0), 0.1)

func update_coins(value: int) -> void:
	coin_count_label.text = str(value)
	# Pop animation
	var tween := create_tween()
	tween.tween_property(coin_count_label, "scale", Vector2(1.3, 1.3), 0.08)
	tween.tween_property(coin_count_label, "scale", Vector2(1.0, 1.0), 0.08)

func update_gems(value: int) -> void:
	gem_count_label.text = "💎 " + str(value)

func update_weapon(name: String, color: Color) -> void:
	weapon_name_label.text = "🔫 " + name
	weapon_name_label.add_theme_color_override("font_color", color)

func update_ammo(current: int, max_ammo: int) -> void:
	# Rebuild ammo pip bar
	for child in ammo_pips_container.get_children():
		child.queue_free()

	for i in range(max_ammo):
		var pip := ColorRect.new()
		pip.size = Vector2(6, 12)
		pip.color = Color("#fde047") if i < current else Color(1, 1, 1, 0.15)
		pip.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		ammo_pips_container.add_child(pip)

func show_reloading(is_reloading: bool) -> void:
	reload_label.visible = is_reloading
	if is_reloading:
		# Blink animation
		var tween := create_tween().set_loops()
		tween.tween_property(reload_label, "modulate:a", 0.3, 0.3)
		tween.tween_property(reload_label, "modulate:a", 1.0, 0.3)
	else:
		reload_label.modulate.a = 1.0

func show_level_up(new_level: int) -> void:
	var msg := Label.new()
	msg.text = "LEVEL UP! NOW LEVEL %d" % new_level
	msg.add_theme_color_override("font_color", Color("#fbbf24")) # Gold
	msg.add_theme_font_size_override("font_size", 40)
	msg.anchors_preset = Control.PRESET_CENTER
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(msg)
	
	msg.scale = Vector2.ZERO
	var tween := create_tween()
	tween.tween_property(msg, "scale", Vector2(1.2, 1.2), 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_interval(1.5)
	tween.tween_property(msg, "modulate:a", 0.0, 0.5)
	tween.tween_callback(msg.queue_free)
