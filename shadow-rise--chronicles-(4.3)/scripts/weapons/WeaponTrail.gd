## WeaponTrail.gd
## Cinematic Melee Weapon Trail using Line2D.
## Attach as a child of the Weapon Sprite.

extends Line2D

@export var max_points: int = 10
@export var trail_duration: float = 0.2

var _points_queue: Array = []

func _ready():
	top_level = true # Draw in global space
	clear_points()

func _process(_delta: float):
	# Update points based on where the parent (weapon tip) is
	var current_pos = get_parent().global_position
	
	_points_queue.push_front(current_pos)
	if _points_queue.size() > max_points:
		_points_queue.pop_back()
		
	clear_points()
	for p in _points_queue:
		add_point(p)

func start_trail():
	visible = true
	set_process(true)
	# Fade in or reset
	modulate.a = 1.0

func stop_trail():
	# Fade out smoothly
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, trail_duration)
	await tween.finished
	visible = false
	set_process(false)
