extends MarginContainer

@export var name_label : Label
@export var level_label : Label
@export var type_texture : TextureRect
@export var BG_color_rect : ColorRect
@export var tick_rect : HBoxContainer

func _ready() -> void:
	change_tick(12)

func change_tick(amnt):
	var clamped = clampi(amnt, 3, 9)
	var max : int = 0
	for child in tick_rect.get_children():
		child.hide()
	for child in tick_rect.get_children():
		if max < clamped:
			max += 1
			child.show()
		else:
			break
