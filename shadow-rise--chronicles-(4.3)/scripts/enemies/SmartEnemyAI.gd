## SmartEnemyAI.gd
## Advanced AI with Pathfinding, Retreat behavior, and Reaction states

extends CharacterBody2D

enum AIState { IDLE, PATROL, CHASE, ATTACK, RETREAT }
var current_state: AIState = AIState.IDLE

@export var move_speed: float = 120.0
@export var detection_radius: float = 300.0
@export var retreat_threshold: float = 0.3 # HP percentage to trigger retreat

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_comp: Node = $HealthComponent

var player: CharacterBody2D = null

func _physics_process(delta: float) -> void:
	if not player:
		_check_for_player()
		_state_patrol(delta)
		return

	match current_state:
		AIState.CHASE:
			_state_chase(delta)
		AIState.ATTACK:
			_state_attack(delta)
		AIState.RETREAT:
			_state_retreat(delta)

func _check_for_player() -> void:
	var world_player = get_tree().get_first_node_in_group("player")
	if world_player and global_position.distance_to(world_player.global_position) < detection_radius:
		player = world_player
		current_state = AIState.CHASE

func _state_chase(_delta: float) -> void:
	nav_agent.target_position = player.global_position
	
	if nav_agent.is_navigation_finished():
		current_state = AIState.ATTACK
		return
		
	var next_path_pos = nav_agent.get_next_path_position()
	var dir = global_position.direction_to(next_path_pos)
	
	velocity = dir * move_speed
	move_and_slide()
	
	# Face movement
	sprite.flip_h = velocity.x < 0

func _state_retreat(_delta: float) -> void:
	# Move in opposite direction of player
	var dir = player.global_position.direction_to(global_position)
	velocity = dir * move_speed * 1.2
	move_and_slide()
	
	if global_position.distance_to(player.global_position) > 600:
		current_state = AIState.IDLE
		player = null

func take_damage(amount: float) -> void:
	health_comp.hp -= amount
	if health_comp.get_hp_percent() < retreat_threshold:
		current_state = AIState.RETREAT
	else:
		current_state = AIState.CHASE
