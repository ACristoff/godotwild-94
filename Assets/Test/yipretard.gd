extends Sprite2D

const YIP_TOOLYIP = preload("uid://dqgfurgu7jsbg")
@onready var yipretard: Sprite2D = $"."
var current_tt
var spawn_pos

var tt_active = false
@onready var panel: Panel = $Panel

var hovering := false
var tooltip_hovering := false


var tt_size = Vector2(149, 84)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	var tooltip = YIP_TOOLYIP.instantiate()
	current_tt = tooltip
	add_child(tooltip)
	spawn_pos = self.global_position
	#tooltip.global_position = yipretard.global_position
	tooltip.yip_owner = self
	tooltip.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var screen_size = get_viewport().get_visible_rect().size / 3
	if panel.get_global_rect().has_point(get_global_mouse_position()):
		hovering = true
		#print("yippy, ", tooltip_hovering)
	else:
		hovering = false
		#print("yippy, ", tooltip_hovering)
	if current_tt.tooltip_hovering:
		tooltip_hovering = true
	else:
		tooltip_hovering = false
	if hovering or tooltip_hovering:
		current_tt.global_position.y = spawn_pos.y - 99
		current_tt.global_position.x = spawn_pos.x - 55
		current_tt.global_position.x = clamp(current_tt.global_position.x, 0, screen_size.x - tt_size.x)
		current_tt.global_position.y = clamp(current_tt.global_position.y, 0, screen_size.y - tt_size.y)
		current_tt.become_visible()
	else:
		current_tt.hide()
		current_tt.shown = false
		current_tt.global_position = self.global_position
