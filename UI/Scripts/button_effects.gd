extends Button

@export var target_highlight := Node
#@export var secondary_target_highlight := Node

func _ready() -> void:
	target_highlight.pivot_offset_ratio = Vector2(0.5, 0.5)
	#secondary_target_highlight.pivot_offset_ratio = Vector2(0.5, 0.5)
func _on_mouse_entered() -> void:
	target_highlight.modulate = Color(1.395, 1.395, 1.395, 1.0)
	#secondary_target_highlight.modulate = Color(1.395, 1.395, 1.395, 1.0)

func _on_mouse_exited() -> void:
	target_highlight.modulate = Color(1.0, 1.0, 1.0, 1.0)
	#secondary_target_highlight.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_button_down() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(target_highlight, "scale", Vector2(2.95, 2.95), 0.05)
	#tween.tween_property(secondary_target_highlight, "scale", Vector2(0.98, 0.98), 0.05)

func _on_button_up() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(target_highlight, "scale", Vector2(3, 3), 0.05)
	#tween.tween_property(secondary_target_highlight, "scale", Vector2(1, 1), 0.05)
