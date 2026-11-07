extends MarginContainer

@export var name_label : Label
@export var level_label : Label
@export var type_texture : TextureRect
@export var BG_color_rect : ColorRect
@export var tick_rect : HBoxContainer

var current_tick_level : int = 3
var max_tick_level : int = 9
var ticked : int = 0
var type
var clamped : int
var leveling_up : bool = false

func _ready() -> void:
	change_tick(current_tick_level)

func change_tick(amnt):
	clamped = clampi(amnt, 3, 9)
	var max : int = 0
	for child in tick_rect.get_children():
		child.hide()
	for child in tick_rect.get_children():
		if max < clamped:
			max += 1
			child.show()
		else:
			break

func add_tick():
	for i in ticked:
		tick_rect.get_child(i).draw_center = true

func _on_add_goop_pressed() -> void:
	if leveling_up:
		return
	var type_slot = BodyMap.Slot.keys()[type]
	
	if SignalBus.goop_inventory[type_slot] == 0:
		return
	ticked += 1
	if ticked < clamped:
		add_tick()
	else:
		leveling_up = true
		add_tick()
		await get_tree().create_timer(.5).timeout
		reset_ticks()
	SignalBus.spent_goop.emit(type)

func reset_ticks():
	if current_tick_level == max_tick_level:
		level_label.text = "MAX"
		return
	for i in ticked:
		tick_rect.get_child(i).draw_center = false
	ticked = 0
	leveling_up = false
	current_tick_level += 3
	match current_tick_level:
		3:
			level_label.text = "Lvl 1"
		6:
			level_label.text = "Lvl 2"
		9:
			level_label.text = "Lvl 3"
	change_tick(current_tick_level)
