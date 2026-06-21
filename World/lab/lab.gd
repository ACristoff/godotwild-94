extends Node2D
@export var sample_yip: YipeeData

var yip_placed = false
var focused_yip: Yipee = null
var dragged_yip: Yipee = null
var drag_offset: Vector2 = Vector2.ZERO

var yip_on_launch_pad: Yipee = null
var yip_on_conveyor: Yipee = null
const ALLELE_UI = preload("uid://cckwntee1s0l4")  # alelle_ui.tscn

var allele_tooltip

@onready var canvas_layer = $CanvasLayer
@onready var launch_pad = $LaunchPad
@onready var conveyor = $ConveyorArea
@onready var dna_screen = $Control/SubViewportContainer/SubViewport/DNATestScreen
@onready var areas = $Areas

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
	if SignalBus.debug_mode == true && sample_yip != null:
		seed_debug_alleles()
		#sample_yip.helix = Helix.generate_debug()
		spawn_yip(sample_yip)

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
	#yip.global_position = Vector2(300,300)
	yip.global_position = get_random_point_in_area()
	print(yip.global_position)
	yip.data.can_be_grabbed = true
	add_child(yip)
	yip.z_index = 100
	yip.health_UI.visible = false
	yip.animation_player.play(&"Spawn")
	yip.yip_hovered.connect(_on_yip_hovered)
	yip.yip_unhovered.connect(_on_yip_unhovered)
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

func _on_allele_hovered(allele: Allele, side: String) -> void:
	var slot_key = BodyMap.Slot.keys()[allele.slot]
	allele_tooltip.update_info(allele.allele_name, side, allele.get_tooltip(), slot_key, allele.tier)
	allele_tooltip.global_position = get_viewport().get_mouse_position() + Vector2(15, 15)
	allele_tooltip.show()
	allele_tooltip.squish()

func _on_conveyor_area_area_entered(area):
	print("on_conveyor_area_area_entered", area)

func _on_conveyor_area_area_exited(area):
	pass # Replace with function body.
