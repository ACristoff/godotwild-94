extends Control

var amnt_of_stats : int

@onready var stats_flow_container: FlowContainer = $StatsFlowContainer
@onready var stats_container: NinePatchRect = $StatsContainer

@onready var mouse_hover: Panel = $MouseHover
@onready var mouse_hover_2: Panel = $MouseHover2
var tooltip_hovering := false
var yip_owner
var set_hover = false

var increment = 0

var types = [
	"ATK",
	"ATKAUG",
	"HP",
	"HPAUG",
	"BREED",
	"CD",
	"SPEC"
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	random_debug_setter()
	for i in range(1, 9):
		var node
		node = get_node("DNA/LeftGene" + str(i))
		node.self_modulate = get_color("NULL")
		node = get_node("DNA/RightGene" + str(i))
		node.self_modulate = get_color("NULL")
	print(get_total_rect(self))

func set_slot_visuals(type):
	#increment = 0
	var node
	increment += 1
	node = get_node("DNA/LeftSlot" + str(increment))
	#print(node)
	node.self_modulate = get_color(type)
	node = get_node("DNA/RightSlot" + str(increment))
	node.self_modulate = get_color(type)
	node = get_node("DNA/VBoxContainer/SlotType" + str(increment))
	node.text = str(type)
	node.self_modulate = get_color(type)
	node = node.get_child(0)
	node.self_modulate = get_color(type)

func random_debug_setter():
	for i in range(1, 9):
		var type = types.pick_random()
		set_slot_visuals(type)
	increment = 0

func get_color(type):
	match type:
		"ATK":
			return TypeColors.colors["ATK"]
		"ATKAUG":
			return TypeColors.colors["ATKAUG"]
		"HP":
			return TypeColors.colors["HP"]
		"HPAUG":
			return TypeColors.colors["HPAUG"]
		"BREED":
			return TypeColors.colors["BREED"]
		"CD":
			return TypeColors.colors["CD"]
		"SPEC":
			return TypeColors.colors["SPEC"]
		"NULL":
			return TypeColors.colors["NULL"]

func get_total_rect(node: Control) -> Rect2:
	var rect = node.get_global_rect()
	for child in node.get_children():
		if child is Control:
			rect = rect.merge(get_total_rect(child))
	return rect

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if mouse_hover.get_global_rect().has_point(get_global_mouse_position()) or mouse_hover_2.get_global_rect().has_point(get_global_mouse_position()):
		if yip_owner.hovering == true:
			set_hover = true
		if set_hover:
			tooltip_hovering = true
			#print("tooltip, ", tooltip_hovering)
		else:
			tooltip_hovering = false
			#print("tooltip, ", tooltip_hovering)
	else:
		tooltip_hovering = false
		set_hover = false
	amnt_of_stats = stats_flow_container.get_child_count()
	match amnt_of_stats:
		1:
			stats_flow_container.size = Vector2(22, 13)
		2:
			stats_flow_container.size = Vector2(42, 13)
		3:
			stats_flow_container.size = Vector2(42, 25)
		4:
			stats_flow_container.size = Vector2(42, 25)
		5:
			stats_flow_container.size = Vector2(42, 37)
		6:
			stats_flow_container.size = Vector2(42, 37)
		7:
			stats_flow_container.size = Vector2(42, 49)
		8:
			stats_flow_container.size = Vector2(42, 49)
		9:
			stats_flow_container.size = Vector2(42, 61)
		10:
			stats_flow_container.size = Vector2(42, 61)
	stats_container.size = stats_flow_container.size
	stats_container.size.y = stats_container.size.y + 2
	stats_container.size.x = stats_container.size.x + 1
