extends Node2D
@export var sample_yip: YipeeData

var yip_placed = false
var focused_yip: Yipee = null
var dragged_yip: Yipee = null
var drag_offset: Vector2 = Vector2.ZERO

var yip_on_launch_pad: Yipee = null

@onready var launch_pad = $LaunchPad
@onready var conveyor = $ConveyorArea
@onready var dna_screen = $Control/SubViewportContainer/SubViewport/DNATestScreen
@onready var areas = $Areas
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_screen()
	if SignalBus.debug_mode == true && sample_yip != null:
		print('debug')
		spawn_yip(sample_yip)

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
	focused_yip = yip

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
			if focused_yip:
				dragged_yip = focused_yip
				# remember the grab point so the yip follows the cursor from where you grabbed it
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


func _on_conveyor_area_area_entered(area):
	print("on_conveyor_area_area_entered", area)

	
