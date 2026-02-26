## RealisticPlayerController.gd
## ADVANCED ANIMATION SYSTEM (AnimationPlayer + AnimationTree)
## 
## Required Node Structure:
## CharacterBody2D (Player)
## ├── Sprite2D (Hero Sheet)
## ├── AnimationPlayer (Contains: idle, run, jump, fall, attack, hurt, dash)
## ├── AnimationTree  (Set 'Tree Root' to AnimationNodeStateMachine)
## └── Marker2D (Muzzle)

extends CharacterBody2D

# ─── Animation Tree Parameters ────────────────────────────────────────────────
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")

# ─── Movement Stats ───────────────────────────────────────────────────────────
@export var max_speed := 220.0
@export var acceleration := 1200.0
@export var friction := 1500.0
@export var jump_velocity := -450.0

var is_attacking := false

func _ready() -> void:
	anim_tree.active = true

func _physics_process(delta: float) -> void:
	var move_input = Input.get_axis("move_left", "move_right")
	
	_handle_movement(move_input, delta)
	_handle_jump()
	_handle_combat()
	_update_animation_parameters(move_input)
	
	move_and_slide()

func _handle_movement(input: float, delta: float) -> void:
	if input != 0:
		velocity.x = move_toward(velocity.x, input * max_speed, acceleration * delta)
		$Sprite2D.flip_h = input < 0
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func _handle_jump() -> void:
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity
		# Trigger Jump Start in Tree
		anim_state.travel("jump")

func _handle_combat() -> void:
	if Input.is_action_just_pressed("shoot") and not is_attacking:
		_perform_attack()

func _perform_attack() -> void:
	is_attacking = true
	# Use "OneShot" or "Travel" in State Machine
	anim_state.travel("attack")
	
	# Realistic logic: slow down slightly during swing
	velocity.x *= 0.5
	
	# Callback or Timer to reset is_attacking
	await get_tree().create_timer(0.4).timeout 
	is_attacking = false

# ─── SMART ANIMATION SYNC ─────────────────────────────────────────────────────
func _update_animation_parameters(input: float) -> void:
	# 1. Blend speed between Idle and Run
	# In your AnimationTree, create a BlendSpace1D for 'Move' (0 = Idle, 1 = Max Run)
	var move_amount = abs(velocity.x) / max_speed
	anim_tree.set("parameters/Move/blend_position", move_amount)
	
	# 2. State Logic
	if not is_on_floor():
		if velocity.y < 0:
			anim_state.travel("jump")
		else:
			anim_state.travel("fall")
	else:
		if is_attacking:
			anim_state.travel("attack")
		elif abs(velocity.x) > 10:
			anim_state.travel("run")
		else:
			anim_state.travel("idle")
	
	# 3. Dynamic Face Expression (Sample)
	# Triggered via Shader or SpriteFrame parameter in AnimationPlayer
	if is_attacking:
		anim_tree.set("parameters/Face/blend_amount", 1.0) # Angry face
	else:
		anim_tree.set("parameters/Face/blend_amount", 0.0) # Calm face
