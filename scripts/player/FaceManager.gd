## FaceManager.gd
## Manages facial expressions (Anger, Fear, Pain) based on player state.
## Attach to a Sprite2D overlaying the character's head.

extends Sprite2D

enum FaceExpression { CALM, ANGER, FEAR, PAIN }

@export var texture_calm: Texture2D
@export var texture_anger: Texture2D
@export var texture_fear: Texture2D
@export var texture_pain: Texture2D

func set_expression(state: FaceExpression):
	match state:
		FaceExpression.ANGER: texture = texture_anger
		FaceExpression.FEAR: texture = texture_fear
		FaceExpression.PAIN: texture = texture_pain
		_: texture = texture_calm

# Integration with HeroController
func _on_attack_started():
	set_expression(FaceExpression.ANGER)
	await get_tree().create_timer(0.4).timeout
	set_expression(FaceExpression.CALM)

func _on_hurt():
	set_expression(FaceExpression.PAIN)
	await get_tree().create_timer(0.5).timeout
	set_expression(FaceExpression.CALM)

func _on_enemy_nearby(distance: float):
	if distance < 100:
		set_expression(FaceExpression.FEAR)
	else:
		set_expression(FaceExpression.CALM)
