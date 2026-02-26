## ProceduralSpawner.gd
## Dynamically spawns enemies based on level progress and difficulty scale.

extends Node2D

@export var enemy_scenes: Dictionary = {
	"basic": preload("res://scenes/enemies/EnemyBasic.tscn"),
	"advanced": preload("res://scenes/enemies/EnemyAdvanced.tscn"),
	"sniper": preload("res://scenes/enemies/EnemySniper.tscn")
}

@export var spawn_interval: float = 10.0
@export var max_active_enemies: int = 5

var active_enemies: int = 0
var difficulty: float = 1.0

func _ready() -> void:
	$SpawnTimer.wait_time = spawn_interval
	$SpawnTimer.start()

func set_difficulty(new_diff: float) -> void:
	difficulty = new_diff

func _on_spawn_timer_timeout() -> void:
	if active_enemies >= max_active_enemies * difficulty:
		return
	
	_spawn_random_enemy()

func _spawn_random_enemy() -> void:
	# Choose type based on difficulty
	var type = "basic"
	if difficulty > 1.2 and randf() > 0.6:
		type = "advanced"
	elif difficulty > 1.5 and randf() > 0.8:
		type = "sniper"
	
	var enemy = enemy_scenes[type].instantiate()
	# Spawn at a random position outside the camera view (e.g. 800px ahead)
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var spawn_pos = player.global_position + Vector2(randf_range(600, 900), -50)
		enemy.global_position = spawn_pos
		get_parent().add_child(enemy)
		active_enemies += 1
		enemy.died.connect(func(_e): active_enemies -= 1)
