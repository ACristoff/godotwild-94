extends Node2D
@export var sample_yip: YipeeData

var yip_placed = false
var focused_yip: Yipee = null
var dragged_yip: Yipee = null
var drag_offset: Vector2 = Vector2.ZERO

var yip_on_launch_pad: Yipee = null
var yip_on_conveyor: Yipee = null
const ALLELE_UI = preload("uid://cckwntee1s0l4")
const ALLELE_CHIP = preload("res://UI/Scenes/allele_chip.tscn")
const HELIX_DROP_OVERLAY = preload("res://UI/Scripts/helix_drop_overlay.gd")
var team_slots: Array[Area2D] = []
var yip_lab_party_position: Dictionary[int, Yipee] = {1: null, 2: null, 3: null, 4: null, 5: null}
var allele_tooltip

@onready var canvas_layer = $CanvasLayer
@onready var launch_pad = $LaunchPad
@onready var conveyor = $ConveyorArea
@onready var dna_screen = $Control/SubViewportContainer/SubViewport/DNATestScreen
@onready var areas = $Areas

@onready var left_inventory = $CanvasLayer/LeftInventory
@onready var right_inventory = $CanvasLayer/RightInventory
@onready var helix_surface = $Control/SubViewportContainer



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_screen()
	allele_tooltip = ALLELE_UI.instantiate()
	canvas_layer.add_child(allele_tooltip)
	allele_tooltip.scale = Vector2(3, 3)
	_ignore_mouse_recursive(allele_tooltip)
	allele_tooltip.hide()
	dna_screen.allele_hovered.connect(_on_allele_hovered)
	dna_screen.allele_unhovered.connect(_on_allele_unhovered)
	helix_surface.lab = self
	helix_surface.dna_screen = dna_screen
	left_inventory.lab = self
	right_inventory.lab = self
	_build_helix_drop_overlay()
	for child in areas.get_children():
		if child.name != &"MainPen":
			team_slots.append(child)
	if SignalBus.debug_mode == true && sample_yip != null:
		seed_debug_alleles()
		#sample_yip.helix = Helix.generate_debug()
		spawn_yip(sample_yip)
	if SignalBus.debug_mode == false && SignalBus.yip_inventory[0] != null:
		var inventory = SignalBus.yip_inventory
		for yip in inventory:
			spawn_yip(yip)
	##allele inventory
	rebuild_inventory()

func _build_helix_drop_overlay() -> void:
	var overlay := Control.new()
	overlay.name = "HelixDropOverlay"
	overlay.set_script(HELIX_DROP_OVERLAY)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.lab = self
	overlay.dna_screen = dna_screen
	helix_surface.get_parent().add_child(overlay)
	overlay.anchor_left = helix_surface.anchor_left
	overlay.anchor_top = helix_surface.anchor_top
	overlay.anchor_right = helix_surface.anchor_right
	overlay.anchor_bottom = helix_surface.anchor_bottom
	overlay.offset_left = helix_surface.offset_left
	overlay.offset_top = helix_surface.offset_top
	overlay.offset_right = helix_surface.offset_right
	overlay.offset_bottom = helix_surface.offset_bottom

func _ignore_mouse_recursive(node: Node) -> void:
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_ignore_mouse_recursive(child)

func seed_debug_alleles() -> void:
	if not SignalBus.allele_inventory.is_empty():
		return
	var samples: Array[Allele] = [
		preload("res://World/yipee/genes/allele/leftallele/resources/bigswing.tres"),
		preload("res://World/yipee/genes/allele/leftallele/resources/maul.tres"),
		preload("res://World/yipee/genes/allele/rightallele/resources/angel_wings.tres"),
		preload("res://World/yipee/genes/allele/rightallele/resources/angry_eyes.tres"),
	]
	for sample in samples:
		SignalBus.allele_inventory.append(sample.duplicate(true))

func get_random_point_in_area() -> Vector2:
	# Array to store each collision shape
	var shapes : Array[CollisionShape2D] = [areas.pen_collision]
	
	if shapes.is_empty():
		push_error("Why is this empty stupid add some grazing space!!!!!!")
		return Vector2.ZERO
	
	# Randomly selecting a grazing spot
	var grazing_spot : CollisionShape2D = shapes[randi() % shapes.size()]
	var grazing_shape : RectangleShape2D = shapes[randi() % shapes.size()].shape
	
	var extents : Vector2 = grazing_shape.size / 2.0
	# To store random spawn point
	var random_point_in_grazing_area : Vector2 = Vector2(randf_range(-extents.x, extents.x), randf_range(-extents.y, extents.y))
	
	return grazing_spot.to_global(random_point_in_grazing_area)

func spawn_yip(data: YipeeData) -> Yipee:
	var yip : Yipee = preload("res://World/yipee/yipee.tscn").instantiate() as Yipee
	yip.data = data
	add_child(yip)
	yip.z_index = 100
	yip.health_UI.visible = false
	yip.data.can_be_grabbed = true
	yip.yip_hovered.connect(_on_yip_hovered)
	yip.yip_unhovered.connect(_on_yip_unhovered)
	
	if yip.data.yip_party_slot != 0:
		yip.global_position = team_slots[yip.data.yip_party_slot - 1].global_position
		yip_lab_party_position[yip.data.yip_party_slot] = yip
		yip.animation_player.play(&"IdleNormal")
	else:
		yip.global_position = get_random_point_in_area()
		yip.animation_player.play(&"Spawn")
	
	return yip

func _on_yip_hovered(yip: Yipee) -> void:
	print("YIP HOVERED")
	focused_yip = yip

func _on_allele_unhovered() -> void:
	print("ALLELE UNHOVER -> hide")
	allele_tooltip.hide()

func _on_yip_unhovered() -> void:
	focused_yip = null

func update_screen():
	left_inventory.visible = yip_placed
	right_inventory.visible = yip_placed
	if yip_placed:
		$Control/SubViewportContainer/SubViewport/DNATestScreen.show()
		$Control/SubViewportContainer/SubViewport/Cyanspeenspritesheet.hide()
		$Arrow.hide()
		$PlaceYip.hide()
		$NoConnectionFound.modulate = Color(0.0, 0.0, 0.0, 0.0)
	else:
		$Control/SubViewportContainer/SubViewport/DNATestScreen.hide()
		$Control/SubViewportContainer/SubViewport/Cyanspeenspritesheet.show()
		$Arrow.show()
		$PlaceYip.show()
		$NoConnectionFound.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			print("CLICK, focused_yip = ", focused_yip)
			if focused_yip:
				dragged_yip = focused_yip
				drag_offset = dragged_yip.global_position - get_global_mouse_position()
		else:
			dragged_yip = null
	elif event is InputEventMouseMotion:
		if dragged_yip:
			dragged_yip.global_position = get_global_mouse_position() + drag_offset

func set_yip_to_launch(yip: Yipee) -> void:
	update_screen()
	dna_screen.display_helix(yip.data.helix)
	pass

func clear_launch() -> void:
	update_screen()
	pass

func _on_launch_pad_area_entered(area):
	var yip := area.get_parent() as Yipee
	if yip == null:
		return
	if yip_on_launch_pad == null:
		yip_on_launch_pad = yip
		yip_placed = true
		set_yip_to_launch(yip)

func _on_launch_pad_area_exited(area):
	var yip := area.get_parent() as Yipee
	if yip == null or yip_on_launch_pad != yip:
		return
	for overlapping_area in launch_pad.get_overlapping_areas():
		if overlapping_area.get_parent() == yip:
			return
	yip_placed = false
	yip_on_launch_pad = null
	clear_launch()

func rebuild_inventory() -> void:
	if left_inventory == null or right_inventory == null:
		return
	for child in left_inventory.get_children():
		child.queue_free()
	for child in right_inventory.get_children():
		child.queue_free()
	for index in SignalBus.allele_inventory.size():
		var allele = SignalBus.allele_inventory[index]
		var chip = ALLELE_CHIP.instantiate()
		if allele is LeftAllele:
			left_inventory.add_child(chip)
			chip.flip_h = true
		else:
			right_inventory.add_child(chip)
		chip.setup(allele, index)

func current_helix() -> Helix:
	if yip_on_launch_pad == null:
		return null
	return yip_on_launch_pad.data.helix

func rung_for_slot(slot: BodyMap.Slot) -> int:
	var helix := current_helix()
	if helix == null:
		return -1
	for rung_index in helix.strands.size():
		var strand: Strand = helix.strands[rung_index]
		if strand != null and strand.slot == slot:
			return rung_index
	return -1

func can_place_allele(data: Variant, rung_index: int, side: String) -> bool:
	if typeof(data) != TYPE_DICTIONARY or not data.has("allele"):
		return false
	if rung_index < 0 or side == "":
		return false
	var allele = data.allele
	if side == "LEFT" and not (allele is LeftAllele):
		return false
	if side == "RIGHT" and not (allele is RightAllele):
		return false
	var helix := current_helix()
	if helix == null or rung_index >= helix.strands.size():
		return false
	var strand: Strand = helix.strands[rung_index]
	return strand != null and strand.slot == allele.slot

func place_allele(data: Variant, rung_index: int, side: String) -> void:
	if not can_place_allele(data, rung_index, side):
		return
	var allele: Allele = data.allele
	var helix := current_helix()
	var source: String = data.get("source", "inventory")
	if source == "inventory":
		var from_index: int = data.get("index", -1)
		if from_index >= 0 and from_index < SignalBus.allele_inventory.size():
			SignalBus.allele_inventory.remove_at(from_index)
	elif source == "helix":
		clear_helix_slot(data.rung, data.side)
	var strand: Strand = helix.strands[rung_index]
	var displaced: Allele = strand.left if side == "LEFT" else strand.right
	if side == "LEFT":
		strand.left = allele
	else:
		strand.right = allele
	helix.set_rung(rung_index, strand)
	if displaced != null:
		SignalBus.allele_inventory.append(displaced)
	refresh()

func allele_at(rung_index: int, side: String) -> Allele:
	var helix := current_helix()
	if helix == null or rung_index < 0 or rung_index >= helix.strands.size():
		return null
	var strand: Strand = helix.strands[rung_index]
	if strand == null:
		return null
	return strand.left if side == "LEFT" else strand.right

func make_chip_preview(allele: Allele) -> Control:
	var chip = ALLELE_CHIP.instantiate()
	chip.setup(allele, -1)
	chip.flip_h = allele is LeftAllele
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return chip

func clear_helix_slot(rung_index: int, side: String) -> void:
	var helix := current_helix()
	if helix == null or rung_index < 0 or rung_index >= helix.strands.size():
		return
	var strand: Strand = helix.strands[rung_index]
	if strand == null:
		return
	if side == "LEFT":
		strand.left = null
	else:
		strand.right = null
	helix.set_rung(rung_index, strand)

func can_return_to_inventory(data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data.get("source", "") == "helix"

func return_to_inventory(data: Variant) -> void:
	if not can_return_to_inventory(data):
		return
	clear_helix_slot(data.rung, data.side)
	SignalBus.allele_inventory.append(data.allele)
	refresh()

func refresh() -> void:
	rebuild_inventory()
	if yip_on_launch_pad != null:
		dna_screen.display_helix(current_helix())
		if yip_on_launch_pad.body:
			yip_on_launch_pad.body.apply_helix(current_helix())

func _on_allele_hovered(allele: Allele, side: String) -> void:
	var slot_key = Toolyip.SLOT_KEYS.get(allele.slot, "NULL")
	allele_tooltip.update_info(allele.allele_name, side, allele.get_tooltip(), slot_key, allele.tier)
	allele_tooltip.global_position = get_viewport().get_mouse_position() + Vector2(15, 15)
	allele_tooltip.show()
	allele_tooltip.squish()

func _on_conveyor_area_area_entered(area):
	print("on_conveyor_area_area_entered", area)

func _on_conveyor_area_area_exited(area):
	pass # Replace with function body.


func _on_farm_button_pressed():
	SignalBus.go_to.emit(SignalBus.Locations.FARM)
	pass # Replace with function body.
