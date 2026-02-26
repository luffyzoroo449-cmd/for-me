## TacticalEnemyAI.gd
## Advanced AI: Dodging, Flanking, and Group Coordination

extends CharacterBody2D

signal search_for_backup(pos)

enum AIBehavior { PATROL, CHASE, FLANK, DODGE, RETREAT }
var behavior = AIBehavior.PATROL

@export var archetype: String = "soldier" # heavy_knight, archer, assassin
@export var detection_range: float = 400.0

var player: CharacterBody2D = null
var dodge_cooldown: float = 0.0

func _ready():
	add_to_group("enemy")
	get_tree().get_nodes_in_group("enemy").forEach(func(e): e.search_for_backup.connect(_on_backup_called))

func _physics_process(delta: float):
	if dodge_cooldown > 0: dodge_cooldown -= delta
	
	_think()
	_perform_behavior(delta)

func _think():
	if not player:
		_find_player()
		return
		
	var dist = global_position.distance_to(player.global_position)
	
	# If low HP, retreat
	if float($Health.hp) / $Health.max_hp < 0.3:
		behavior = AIBehavior.RETREAT
		return

	# Tactical behavior
	if dist < 120 and dodge_cooldown <= 0:
		behavior = AIBehavior.DODGE
	elif dist > 180:
		behavior = AIBehavior.FLANK
	else:
		behavior = AIBehavior.CHASE

func _perform_behavior(delta: float):
	match behavior:
		AIBehavior.DODGE:
			_dodge()
		AIBehavior.FLANK:
			_move_to_side_of_player()
		AIBehavior.RETREAT:
			_run_away()
		_:
			_move_to_player()

func _dodge():
	var dir = -1 if randf() > 0.5 else 1
	velocity.x = dir * 400.0
	dodge_cooldown = 2.0
	# Animation: Slide/Roll
	$AnimationTree.get("parameters/playback").travel("dodge")

func _move_to_side_of_player():
	var offset = Vector2(150, 0) if player.global_position.x > global_position.x else Vector2(-150, 0)
	var target = player.global_position + offset
	# Pathfinding using NavigationAgent2D
	$NavAgent.target_position = target
	_move_towards_nav_target()

func call_for_backup():
	emit_signal("search_for_backup", global_position)

func _on_backup_called(request_pos: Vector2):
	if behavior == AIBehavior.PATROL:
		# Respond to backup call
		$NavAgent.target_position = request_pos
		behavior = AIBehavior.CHASE
