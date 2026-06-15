extends Node2D

@onready var text: Label = $Handle/Text
@onready var end_pnt: Marker2D = $End
@onready var handle: Node2D = $Handle

var color
var start
var end
var control
var tween: Tween
var wow_factor = 0
var base_font_size = 6
var anim_free = false
var sound_free = false

var current_size

func _ready() -> void:
	color = text.modulate
	color.a = 0
func move_along_curve(t):
	handle.global_position = quadratic_bezier(start, control, end, t)
func quadratic_bezier(a, b, c, t):
	return (1 - t) * (1 - t) * a + 2 * (1 - t) * t * b + t * t * c
func popup(damage = 0, type = "PHYSICAL"):
	start = handle.global_position
	#handle.scale = Vector2.ZERO
	#text.add_theme_font_size_override("font_size", 6)
	print("type =", type)
	match type:
		"FIRE":
			text.self_modulate = TypeColors.colors["FIRE"]
		"crit":
			text.self_modulate = Color.RED
		"fire":
			text.self_modulate = Color.ORANGE_RED
		"poison":
			text.self_modulate = Color.WEB_PURPLE
		"zap":
			text.self_modulate = Color.GOLD
			wow_factor = 0
	
	text.text = str(int(damage))
	if tween:
		tween.kill()
	var font_sizes = [8, 16, 32, 64]
	var t = clampf(float(damage) / 1000.0, 0.0, 1.0)
	var index = mini(int(t * font_sizes.size()), font_sizes.size() - 1)
	var new_size = font_sizes[index]
	set_font_size(new_size)
	#text.add_theme_font_size_override("font_size", 8)
	text.modulate = Color(1.0, 1.0, 1.0, 1.0)
	handle.global_position = start
	var end_offset = randi_range(-20, 20)
	var rot_offset = randf_range(-7, 7)
	handle.rotation_degrees = rot_offset
	end = end_pnt.global_position
	end.x += end_offset
	control = (start + end) / 2 + Vector2(0, -30)
	tween = create_tween()
	tween.set_parallel(true)
	#tween.parallel().tween_method(set_font_size, 8.0, 16.0, 0.1)
	tween.tween_method(move_along_curve, 0.0, 1.0, .8)
	tween.parallel().tween_method(set_font_size, current_size, 8.0, 0.15)
	tween.parallel().tween_property(text, "modulate", color, .3).set_delay(.5)
	tween.set_parallel(false)
	tween.tween_property(text, "modulate", color, .3)
	tween.tween_property(self, "anim_free", true, 0)
	tween.tween_callback(free_self)
	
func set_font_size(size: float):
	text.add_theme_font_size_override("font_size", int(size))
	current_size = size
	
func free_self():
	queue_free()
	#if anim_free and sound_free:
		#ProjectileManager.feed_pool_dmg(self)


func _on_audio_stream_player_2d_finished() -> void:
	sound_free = true
	free_self()
