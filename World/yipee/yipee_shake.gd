extends Sprite2D


var shake_strength: float = 0.0
var original_position: Vector2

func _ready() -> void:
	original_position = position

func apply_shake(strength:=20, duration:=5) -> void:
	shake_strength = strength
	var timer := get_tree().create_timer(duration)
	await timer.timeout
	shake_strength = 0.0
	position = original_position

func start():
	var tween = create_tween()
	var new_pos = $"../..".grind_pos.global_position + Vector2(randf_range(-30, 30), randf_range(-30, 30))
	tween.tween_property($".", "global_position", new_pos, 0.1)
	tween.tween_callback(shake)
func shake():
	original_position = position
	apply_shake(10, 5)

func _process(delta: float) -> void:
	if shake_strength > 0:
		position = original_position + Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
