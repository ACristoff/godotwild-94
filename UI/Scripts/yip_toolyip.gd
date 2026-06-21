class_name Toolyip extends Control

const STAT_PIP = preload("res://UI/Scenes/damage_toolyip.tscn")

var amnt_of_stats : int

@onready var stats_flow_container: FlowContainer = $StatsFlowContainer
@onready var stats_container: NinePatchRect = $StatsContainer
@onready var name_field: LineEdit = $MainPanel/HBoxContainer/Name/LineEdit
@onready var age_label: Label = $MainPanel/HBoxContainer/Age/Label
@onready var hp_label: Label = $MainPanel/Age2/Label
@onready var cooldown_label: Label = $MainPanel/TextureRect/VBoxContainer/ActualSeconds
@onready var mouse_hover: Panel = $MouseHover
@onready var mouse_hover_2: Panel = $MouseHover2
var tooltip_hovering := false
#var yip_owner
var set_hover = false
var shown = true

var tt_size = Vector2(149, 84)

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

const SLOT_KEYS := {
	BodyMap.Slot.HEALTH: "HP",
	BodyMap.Slot.HEALTH_AUGMENT: "HPAUG",
	BodyMap.Slot.ATTACK: "ATK",
	BodyMap.Slot.ATTACK_AUGMENT: "ATKAUG",
	BodyMap.Slot.COOLDOWN: "CD",
	BodyMap.Slot.SPECIALIZATION: "SPEC",
	BodyMap.Slot.BREED_AUGMENT: "BREED",
	BodyMap.Slot.NONE: "NULL",
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(1, 9):
		var node
		node = get_node("DNA/LeftGene" + str(i))
		node.self_modulate = get_color("NULL")
		node = get_node("DNA/RightGene" + str(i))
		node.self_modulate = get_color("NULL")
	print(get_total_rect(self))

func display(yip: Yipee) -> void:
	var data: YipeeData = yip.data
	name_field.text = data.yipee_name if data.yipee_name != "" else "WILD YIP"
	age_label.text = "Age:%d" % data.age
	hp_label.text = "HP:%d" % roundi(data.get_health())
	cooldown_label.text = "%.1f" % data.get_cooldown()
	
	var helix: Helix = yip.data.helix
	increment = 0
	for i in range(Helix.RUNG_COUNT):
		var strand: Strand = helix.strands[i] if i < helix.strands.size() else null
		var key = "NULL"
		if strand != null:
			key = SLOT_KEYS.get(strand.slot, "NULL")
		set_slot_visuals(key)
		var left_filled = strand != null and strand.left != null
		var right_filled = strand != null and strand.right != null
		get_node("DNA/LeftGene" + str(i + 1)).self_modulate = get_color(key) if left_filled else get_color("NULL")
		get_node("DNA/RightGene" + str(i + 1)).self_modulate = get_color(key) if right_filled else get_color("NULL")
		get_node("MainPanel/Alleles/Effects/R_allele" + str(i + 1)).set_allele(
			strand.left if strand else null, "LEFT", key)
		get_node("MainPanel/Alleles/Visuals/L_allele" + str(i + 1)).set_allele(
			strand.right if strand else null, "RIGHT", key)
	
	var pips := {}
	var atk := roundi(data.get_attack())
	if atk > 0:
		pips["PHYSICAL"] = atk
	for strand in helix.strands:
		if strand == null:
			continue
		for allele in [strand.left, strand.right]:
			if allele == null:
				continue
			var contrib: Dictionary = allele.get_damage_pips()
			for type in contrib:
				pips[type] = pips.get(type, 0) + contrib[type]
	_rebuild_stat_pips(pips)
	shown = false
	become_visible()

func _rebuild_stat_pips(pips: Dictionary) -> void:
	for child in stats_flow_container.get_children():
		child.queue_free()
	for type in pips:
		if pips[type] <= 0:
			continue
		var pip = STAT_PIP.instantiate()
		stats_flow_container.add_child(pip)
		# Set after add_child so the chip's setters run with is_node_ready() true:
		# ailment_name drives the chip colour, value drives the number.
		pip.ailment_name = type
		pip.value = pips[type]

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

func become_visible():
	if !shown:
		popup()
		show()
		shown = true

#func random_debug_setter():
	#for i in range(1, 9):
		#var type = types.pick_random()
		#set_slot_visuals(type)
	#increment = 0

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

func popup():
	$AnimationPlayer.play("pop")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if mouse_hover.get_global_rect().has_point(get_global_mouse_position()) or mouse_hover_2.get_global_rect().has_point(get_global_mouse_position()):
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
