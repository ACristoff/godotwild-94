class_name Toolyip extends Control

const STAT_PIP = preload("res://UI/Scenes/damage_toolyip.tscn")
const DAMAGE_LINE = preload("res://UI/Scenes/damage_line.tscn")

const RIDER_WORDS := {
	"PHYSICAL": "damage",
	"FIRE": "burn",
	"POISON": "poison",
	"ICE": "ice",
}

const HIDE_GRACE: float= 0.1
const GAP_RIGHT: float = 50.0
const GAP_LEFT: float = 70.0

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

@onready var stats_flow_container: FlowContainer = $StatsFlowContainer
@onready var stats_container: NinePatchRect = $StatsContainer
@onready var name_field: LineEdit = $MainPanel/MarginContainer/NameAgeRarity/NameLabel
@onready var age_label: Label = $MainPanel/MarginContainer/NameAgeRarity/AgeLabel
@onready var hp_label: Label = $MainPanel/MarginContainer2/CooldownPanel/MarginContainer/Health/VBoxContainer/HealthLabel
@onready var cooldown_label: Label = $MainPanel/MainInterface/CooldownInformation/CooldownPanel/VBoxContainer/ActualSecondsLabel
@onready var mouse_hover: Panel = $MainPanel/MainPanelBG/MouseHover
@onready var mouse_hover_2: Panel = $MainPanel/MainPanelBG/MouseHover
@onready var strand_pips_container: Control = $MainPanel/MainInterface/DNARefactor
@onready var main_panel: NinePatchRect = $MainPanel
@onready var damage_lines_container: VBoxContainer = get_node_or_null("MainPanel/MainInterface/CooldownInformation/DamageInformationContainer")

@onready var allele_information: AlleleInformation = $MainPanel/MainInterface/AlleleInformation

var amnt_of_stats: int
var _yip_hovered: bool = false
var current_yip: Yipee = null
var _hide_grace: float= 0.0
var shown: bool = true
var tt_size: Vector2 = Vector2(400, 350)
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
	for i in range(1, 9):
		var node
		#node = get_node("DNA/LeftGene" + str(i))
		#node.self_modulate = get_color("NULL")
		#node = get_node("DNA/RightGene" + str(i))
		#node.self_modulate = get_color("NULL")
	if strand_pips_container != null:
		var pips = strand_pips_container.get_children()
		for pip in pips:
			var new_pip: AlllelePip = pip
			new_pip.strand_hovered.connect(on_strand_hovered)
	print(get_total_rect(self))

func on_strand_hovered(new_strand: Strand):
	print(new_strand, 'strand hovered!')
	allele_information.set_strand(new_strand)
	pass

func display_beside(yip: Yipee) -> void:
	display(yip)

	var canvas := get_parent() as CanvasLayer
	var screen_bounds: Vector2 = get_viewport().get_visible_rect().size / canvas.scale
	var yip_pos: Vector2 = canvas.transform.affine_inverse() * yip.get_global_transform_with_canvas().origin

	var panel_offset: Vector2 = main_panel.position
	var panel_size: Vector2 = main_panel.size
	var panel_pos := Vector2.ZERO

	if yip_pos.x > screen_bounds.x / 2.0:
		panel_pos.x = yip_pos.x - GAP_RIGHT - panel_size.x
	else:
		panel_pos.x = yip_pos.x + GAP_LEFT
	panel_pos.y = yip_pos.y - panel_size.y / 2.0

	panel_pos.x = clampf(panel_pos.x, 0.0, screen_bounds.x - panel_size.x)
	panel_pos.y = clampf(panel_pos.y, 0.0, screen_bounds.y - panel_size.y)

	global_position = panel_pos - panel_offset

func display(yip: Yipee) -> void:
	var data: YipeeData = yip.data
	current_yip = yip
	name_field.text = data.yipee_name if data.yipee_name != "" else "WILD YIP"
	age_label.text = "Age:%d" % data.age
	hp_label.text = "%d" % roundi(data.get_health())
	cooldown_label.text = "%.1f" % data.get_cooldown()
	
	var container = strand_pips_container.get_children()
	for i in range(8):
		var new_pip: AlllelePip = container[i]
		var new_strand: Strand = data.helix.strands[i]
		new_pip.set_strand(new_strand)
	
	var pips := {}
	var atk := roundi(data.get_attack())
	if atk > 0:
		pips["PHYSICAL"] = atk
	for strand in data.helix.strands:
		if strand == null:
			continue
		for allele in [strand.left, strand.right]:
			if allele == null:
				continue
			var contribution: Dictionary = allele.get_damage_pips()
			for type in contribution:
				pips[type] = pips.get(type, 0) + contribution[type]
	_rebuild_damage_lines(pips)
	_yip_hovered = true
	_hide_grace = HIDE_GRACE
	#shown = false
	become_visible()

func _rebuild_damage_lines(pips: Dictionary) -> void:
	if damage_lines_container == null:
		return
	for child in damage_lines_container.get_children():
		damage_lines_container.remove_child(child)
		child.queue_free()
	for type in pips:
		if pips[type] <= 0:
			continue
		var line: Label = DAMAGE_LINE.instantiate()
		damage_lines_container.add_child(line)
		line.text = "Does %d %s" % [pips[type], RIDER_WORDS.get(type, str(type).to_lower())]
		if type != "PHYSICAL" and TypeColors.colors.has(type):
			line.add_theme_color_override("font_color", TypeColors.colors[type])
			line.add_theme_color_override("font_outline_color", TypeColors.colors[type])

#func _rebuild_stat_pips(pips: Dictionary) -> void:
	#for child in stats_flow_container.get_children():
		#child.queue_free()
	#for type in pips:
		#if pips[type] <= 0:
			#continue
		#var pip = STAT_PIP.instantiate()
		#stats_flow_container.add_child(pip)
		#pip.ailment_name = type
		#pip.value = pips[type]

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
	if not visible:
		popup()
		show()
		#shown = true

func request_hide() -> void:
	_yip_hovered = false

func _mouse_over_tooltip() -> bool:
	var mouse := get_global_mouse_position()
	return mouse_hover.get_global_rect().has_point(mouse) or mouse_hover_2.get_global_rect().has_point(mouse)

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
func _process(delta: float) -> void:
	if visible:
		if _yip_hovered or _mouse_over_tooltip():
			_hide_grace = HIDE_GRACE
		else:
			_hide_grace -= delta
			if _hide_grace <= 0.0:
				hide()
				current_yip = null
	#amnt_of_stats = stats_flow_container.get_child_count()
	#match amnt_of_stats:
		#1:
			#stats_flow_container.size = Vector2(22, 13)
		#2:
			#stats_flow_container.size = Vector2(42, 13)
		#3:
			#stats_flow_container.size = Vector2(42, 25)
		#4:
			#stats_flow_container.size = Vector2(42, 25)
		#5:
			#stats_flow_container.size = Vector2(42, 37)
		#6:
			#stats_flow_container.size = Vector2(42, 37)
		#7:
			#stats_flow_container.size = Vector2(42, 49)
		#8:
			#stats_flow_container.size = Vector2(42, 49)
		#9:
			#stats_flow_container.size = Vector2(42, 61)
		#10:
			#stats_flow_container.size = Vector2(42, 61)
	#stats_container.size = stats_flow_container.size
	#stats_container.size.y = stats_container.size.y + 2
	#stats_container.size.x = stats_container.size.x + 1

func _on_name_label_text_changed(new_text):
	if current_yip != null:
		current_yip.data.yipee_name = new_text
