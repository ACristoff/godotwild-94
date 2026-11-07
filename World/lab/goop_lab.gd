extends Node2D

var current_strand: Strand

@onready var vat_container = $Vats
var vats: Dictionary[String, Node2D] = {}

@onready var tooltip2: Toolyip = $CorrectScale/YipToolyip2
@onready var conveyor_animation = $Mulcher/ConveyorAnimation
@onready var shredder_animation = $Mulcher/ShredderAnimation
@onready var pen_collision : CollisionShape2D = $Pen/PenArea/CollisionShape2D
@onready var conveyor_area : Area2D = $Mulcher/ConveyorArea
@onready var pedestal_area : Area2D = $PedestalArea
@onready var team_slot_conatiner = $TeamSlots

#Debug only variables
@export var debug_yips : Array[YipeeData] = []
@onready var debug_goop : Label = $DebugData/Goop

var focused_yip: Yipee = null
var dragged_yip: Yipee = null
var drag_offset: Vector2 = Vector2.ZERO
var team_slots: Array[Area2D] = []
var conveyor_has_yip: Array[Yipee] = []
var yip_on_pedestal: Yipee = null

const SLOT_COLORS := {
	BodyMap.Slot.HEALTH:         "779422",
	BodyMap.Slot.HEALTH_AUGMENT: "0eb56d",
	BodyMap.Slot.ATTACK:         "9c2424",
	BodyMap.Slot.ATTACK_AUGMENT: "d14830",
	BodyMap.Slot.COOLDOWN:       "5662cc",
	BodyMap.Slot.SPECIALIZATION: "cc4bae",
	BodyMap.Slot.BREED_AUGMENT:  "784bcc",
	BodyMap.Slot.NONE:           "3d3d3d",
}
const SLOT_ICONS := {
	BodyMap.Slot.HEALTH:         "res://UI/Textures/ui_effecticons/heal_icon.png",
	BodyMap.Slot.HEALTH_AUGMENT: "res://UI/Textures/ui_effecticons/heal_aug.png",
	BodyMap.Slot.ATTACK:         "res://UI/Textures/ui_effecticons/attack_icon.png",
	BodyMap.Slot.ATTACK_AUGMENT: "res://UI/Textures/ui_effecticons/attack_aug_icon.png",
	BodyMap.Slot.COOLDOWN:       "res://UI/Textures/ui_effecticons/haste_icon.png",
	BodyMap.Slot.SPECIALIZATION: "res://UI/Textures/ui_effecticons/null_icon.png",
	BodyMap.Slot.BREED_AUGMENT:  "res://UI/Textures/ui_effecticons/breed_icon.png",
	BodyMap.Slot.NONE:           "res://UI/Textures/ui_effecticons/null_icon.png",
}
var slot_yips: Dictionary[int, Yipee] = {
	1: null,
	2: null,
	3: null,
	4: null,
	5: null,
	6: null, #I guess this is the lab pedestal?
}

@export var conveyor_speed: int = 120

#region built-in-functions

func _ready():
	SignalBus.spent_goop.connect(_on_goop_spent)
	for child in team_slot_conatiner.get_children():
		team_slots.append(child)
	if SignalBus.debug_mode == true:
		$DebugData.visible = true
		for yip in debug_yips:
			spawn_yip(yip)
	else:
		for yip in SignalBus.yip_inventory:
			spawn_yip(yip)
		pass
	for vat in vat_container.get_children():
		vats[vat.type] = vat
	#update_goop("health", 2)
	#prints(team_slots)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if focused_yip:
					dragged_yip = focused_yip
					drag_offset = dragged_yip.global_position - get_global_mouse_position()
					_refresh_cursor()
			else:
				if dragged_yip:
					print('dropped yip')
					for i in range(team_slots.size()):
						var slot: Area2D = team_slots[i]
						if slot.overlaps_area(dragged_yip.farmslot):
							print('dropped yip on area')
							place_yip(dragged_yip, i + 1)
							break
					if conveyor_area.overlaps_area(dragged_yip.farmslot) && !conveyor_has_yip.has(dragged_yip):
						print('on conveyor')
						conveyor_has_yip.append(dragged_yip)
					if pedestal_area.overlaps_area(dragged_yip.farmslot):
						print('on pedestal')
						yip_on_pedestal = dragged_yip
						screen_yip()
					dragged_yip = null
					_refresh_cursor()
	
	elif event is InputEventMouseMotion:
		if dragged_yip:
			dragged_yip.global_position = get_global_mouse_position() + drag_offset

func screen_yip():
	var data: YipeeData = yip_on_pedestal.data
	var index := 0
	for row in $ScreenRects/Node2D/Panel/MarginContainer/AllelesDisplay.get_children():
		var allele_name = row.get_node("AlleleBG/NameBox/MarginContainer/AlleleName")
		var allele_level = row.get_node("AlleleBG/NameBox/MarginContainer4/Box/MarginContainer/AlleleLevel")
		var allele_icon = row.get_node("AlleleBG/NameBox/MarginContainer4/Box/AlleleTypeTexture")
		var allele_bg = row.get_node("AlleleBG")
		var allele_button = row.get_node("AlleleBG/NameBox/MarginContainer4/Box/MarginContainer3/Tick8/AddGoop")
		allele_name.text = "Empty"
		allele_level.text = "Lvl 0"
		allele_icon.texture = load("res://UI/Textures/ui_effecticons/null_icon.png")
		allele_bg.color = Color(0.3, 0.3, 0.3, 1.0)
		allele_button.disabled = true
		row.type = null
		
		if data.helix.strands[index] != null:
			if data.helix.strands[index].left != null:
				var allele : Allele = data.helix.strands[index].left
				allele_name.text = str(allele.allele_name)
				allele_level.text = str("Lvl ", allele.tier)
				allele_icon.texture = load(SLOT_ICONS[allele.slot])
				allele_bg.color = SLOT_COLORS[allele.slot]
				allele_button.disabled = false
				if allele.tier > 1:
					row.change_tick(allele.tier * 3)
				row.type = data.helix.strands[index].slot
		else:
			allele_name.text = "Empty"
			allele_level.text = "Lvl 0"
			allele_icon.texture = load("res://UI/Textures/ui_effecticons/null_icon.png")
			allele_bg.color = Color(0.3, 0.3, 0.3, 1.0)
			allele_button.disabled = true
		index += 1



func _process(delta):
	#prints(conveyor_has_yip)
	if conveyor_has_yip.size() > 0 :
		for yip in conveyor_has_yip:
			yip.position.x += conveyor_speed * delta
		pass
	pass

#endregion

#region shredder

func shred_yip(yip: Yipee):
	prints(yip, 'TIME TO SHRED')
	if focused_yip == yip:
		focused_yip = null
		tooltip2.hide()
		_refresh_cursor()
	#do yip animation and effects here
	yip.grind_pos = $Mulcher/ShredderSprite
	yip.shred()
	#TODO CALEB
	#take yips gene goop and add it to inventory
	print(yip.data.helix.strands)
	for strand in yip.data.helix.strands:
		if strand == null:
			continue
		var strand_type = BodyMap.Slot.find_key(strand.slot)
		if not SignalBus.goop_inventory.has(strand_type):
			continue
		var left_value = 0
		var right_value = 0
		prints(strand.left, strand.right, strand_type)
		if strand.left:
			left_value += calculate_value(strand.left)
		if strand.right:
			right_value += calculate_value(strand.right)
		var total = left_value + right_value
		update_goop(strand_type, total)
		spawn_stars(strand_type, total)
	#shred yip here, remove from player and kill
	#SignalBus.yip_inventory.erase(yip.data)
	delete_yip(yip.data)
	#yip.queue_free()
	#TODO: do a random yip death sound
	conveyor_has_yip.erase(yip)
	if conveyor_has_yip.size() == 0:
		stop_conveyor()

func delete_yip(data: YipeeData) -> void:
	SignalBus.yip_inventory.erase(data)
	for key in SignalBus.yip_party:
		if SignalBus.yip_party[key] == data:
			SignalBus.yip_party[key] = null
	for key in SignalBus.yip_breed_barn:
		if SignalBus.yip_breed_barn[key] == data:
			SignalBus.yip_breed_barn[key] = null
	data.yip_party_slot = 0
	data.yip_barn_slot = 0


func calculate_value(allele: Allele):
	var tier = allele.tier
	var rarity = allele.rarity + 1
	return tier * rarity

func stop_conveyor():
	shredder_animation.current_animation = "RESET"
	conveyor_animation.current_animation = "RESET"

func start_conveyor():
	shredder_animation.current_animation = "shredder_on"
	conveyor_animation.current_animation = "conveyor_on"

func _on_conveyor_area_area_entered(_area):
	start_conveyor()

func _on_conveyor_area_area_exited(_area):
	if dragged_yip == _area.get_parent():
		#conveyor_has_yip = null
		var yip = _area.get_parent()
		conveyor_has_yip.erase(yip)
	if !conveyor_has_yip:
		stop_conveyor()

func _on_shredding_zone_area_entered(area: Area2D):
	prints(area, 'entered shredder!', area.get_parent(), conveyor_has_yip)
	var entered_yip = area.get_parent()
	#if entered_yip == conveyor_has_yip:
	if conveyor_has_yip.has(entered_yip):
		shred_yip(entered_yip)

#endregion 

#region goop_chamber

func update_goop(new_goop: String, goop_number: int):
	SignalBus.goop_inventory[new_goop] += goop_number
	
	debug_goop.text += "\n %s : %s" % [new_goop, SignalBus.goop_inventory[new_goop]]
	

#endregion
func spawn_stars(slot_key: String, amount: int) -> void:
	if not vats.has(slot_key):
		push_warning("No vat for key '%s'. Have: %s" % [slot_key, vats.keys()])
		return
	var vat: Node2D = vats[slot_key]
	vat.spawn_goop(amount)
		
#region pen

func spawn_yip(data: YipeeData) -> Yipee:
	var yip : Yipee = preload("res://World/yipee/yipee.tscn").instantiate() as Yipee
	yip.data = data
	add_child(yip)
	yip.z_index = 100
	yip.health_UI.visible = false
	yip.data.can_be_grabbed = true
	yip.yip_hovered.connect(_on_yip_hovered)
	yip.yip_unhovered.connect(_on_yip_unhovered)
	
	var party_slot : int = yip.data.yip_party_slot
	if party_slot != 0 and party_slot <= team_slots.size():
		yip.global_position = team_slots[party_slot - 1].global_position
		slot_yips[party_slot] = yip
		yip.animation_player.play(&"IdleNormal")
	else:
		yip.global_position = get_random_point_in_area()
		yip.animation_player.play(&"Spawn")
	
	return yip

#endregion

func place_yip(yip: Yipee, slot_number: int) -> void:
	if slot_number < 1 or slot_number > team_slots.size():
		return
	
	var old_slot: int = yip.data.yip_party_slot
	
	# Remove from previous slot.
	if old_slot != 0 and slot_yips.has(old_slot):
		slot_yips[old_slot] = null
		SignalBus.yip_party[6 - old_slot] = null
	
	# Swap out the yip already in this slot.
	var displaced: Yipee = slot_yips[slot_number]
	
	if displaced != null and displaced != yip:
		displaced.data.yip_party_slot = 0
		displaced.global_position = get_random_point_in_area()
	
		for key in SignalBus.yip_party.keys():
			if SignalBus.yip_party[key] == displaced.data:
				SignalBus.yip_party[key] = null
	
	# Place the new yip.
	slot_yips[slot_number] = yip
	yip.data.yip_party_slot = slot_number
	#yip.data.yip_barn_slot = 0
	for key in SignalBus.yip_breed_barn.keys():
		if SignalBus.yip_breed_barn[key] == yip.data:
			SignalBus.yip_breed_barn[key] = null
	yip.data.yip_barn_slot = 0
	yip.global_position = team_slots[slot_number - 1].global_position
	
	# Update global party (visual slot 1 maps to party slot 5).
	SignalBus.yip_party[6 - slot_number] = yip.data
	prints(SignalBus.yip_party)

func _on_yip_hovered(yip: Yipee) -> void:
	if not is_instance_valid(yip):
		return
	if !dragged_yip:
		tooltip2.display_beside(yip)
		focused_yip = yip
		_refresh_cursor()

func _on_yip_unhovered() -> void:
	tooltip2.hide()
	focused_yip = null
	_refresh_cursor()

#enum Slot {
	#HEALTH,
	#HEALTH_AUGMENT,
	#ATTACK,
	#ATTACK_AUGMENT,
	#COOLDOWN,
	#SPECIALIZATION,
	#BREED_AUGMENT,
	#NONE
#}

func _on_goop_spent(type: BodyMap.Slot):
	print('goop spent of type:', BodyMap.Slot.keys()[type])
	var type_slot = BodyMap.Slot.keys()[type]
	SignalBus.goop_inventory[type_slot] -= 1
	print('goop leftover:', SignalBus.goop_inventory[type_slot], )

func _refresh_cursor() -> void:
	if dragged_yip != null:
		CursorManager.use(CursorManager.Pointers.CURSOR_GRABBED)
	elif focused_yip != null:
		CursorManager.use(CursorManager.Pointers.CURSOR_GRABBABLE)
	else:
		CursorManager.reset()

func get_random_point_in_area() -> Vector2:
	# Array to store each collision shape
	var shapes : Array[CollisionShape2D] = [pen_collision]
	
	# Randomly selecting a grazing spot
	var grazing_spot : CollisionShape2D = shapes[randi() % shapes.size()]
	var grazing_shape : RectangleShape2D = shapes[randi() % shapes.size()].shape
	
	var extents : Vector2 = grazing_shape.size / 2.0
	# To store random spawn point
	var random_point_in_grazing_area : Vector2 = Vector2(randf_range(-extents.x, extents.x), randf_range(-extents.y, extents.y))
	
	return grazing_spot.to_global(random_point_in_grazing_area)

func _exit_tree() -> void:
	CursorManager.reset()

func _on_farm_button_pressed() -> void:
	SignalBus.go_to.emit(SignalBus.Locations.FARM)
