extends Node2D

var all_yips:  Array[Yipee] = []


var focused_yip: Yipee = null
var dragged_yip: Yipee = null
var drag_offset : Vector2 = Vector2.ZERO


#func _spawn(data: YipeeData, pos: Vector2) -> Yipee:
	#var yip := preload("res://World/yipee/yipee.tscn").instantiate() as Yipee
	#yip.data = data
	#yip.position = pos
	#
	#add_child(yip)
	#yip.health_UI.visible = true
	#yip.health_UI.current_health = yip.health.current_health
	#yip.health_UI.max_health = yip.health.max_health
	#yip.health_UI.update_UI()
	#return yip

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for yip in SignalBus.yip_inventory:
		print(yip)
		print("HEY WE GOT A YIPPIE HERE")
		wire_yip(spawn_yip(yip))
		#var new_yip = spawn_yip()
		#wire_yip(new_yip)
		#all_yips.append(new_yip)
		pass
		
func _input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			print("Mouse Pressed")
			if focused_yip:
				dragged_yip = focused_yip
				print('Picked up a yip', focused_yip)
				# Remember offset so the yip doesn't jump so its center snaps to the cursor
				drag_offset = dragged_yip.global_position - get_global_mouse_position()
				print("Picked up a yip", dragged_yip)
		else:
			print("Mouse Released")
			if dragged_yip:
				print("dropped yip")
				_drop_yip(dragged_yip)
				dragged_yip = null
				
	elif event is InputEventMouseMotion:
		if dragged_yip:
			dragged_yip.global_position = get_global_mouse_position() + drag_offset

#region Farm Hub Functions

## TODO: Edit spawn yip code, maybe make it so yips don't spawn in the same spot
func get_random_point_in_area() -> Vector2:
	# Array to store each collision shape
	var shapes : Array[CollisionShape2D] = []
	
	# Grab each Collisionshape2D
	for child in %GrazingArea.get_children():
		# Check if its shape is CollisionShape2D
		if child is CollisionShape2D:
			# Check if its shape is RectangleShape2D
			if child.shape is RectangleShape2D:
				shapes.append(child)
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
	var yip := preload("res://World/yipee/yipee.tscn").instantiate() as Yipee
	yip.data = data
	yip.global_position = get_random_point_in_area()
	print("Generated Position: ", yip.global_position)
	
	yip.farm_last_known_position = yip.global_position
	yip.can_be_grabbed = true
	
	add_child(yip)
	yip.health_UI.visible = false
	yip.health_UI.current_health = yip.health.current_health
	yip.health_UI.max_health = yip.health.max_health
	yip.health_UI.update_UI()
	return yip

func _drop_yip(yip: Yipee) -> void:
	# Check if yip is inside of the  grazing area
	# If it is, then place it there, set last known location
	if %GrazingArea.overlaps_area(yip.hover_area):
		yip.farm_last_known_position = yip.global_position
	else:
		# If it is not, then don't place it there, place it at its last known location
		yip.global_position = yip.farm_last_known_position

#endregion 

#region Button Stuff
func _on_texture_button_mouse_entered() -> void:
	$LabDoor2.play("DoorOpen")
func _on_texture_button_mouse_exited() -> void:
	$LabDoor2.play("DoorClose")

func _on_field_button_pressed():
	SignalBus.go_to.emit(SignalBus.Locations.FIELD)
	pass # Replace with function body.

func _on_battle_button_pressed():
	SignalBus.go_to.emit(SignalBus.Locations.BATTLE)
	pass # Replace with function body.
#endregion

#region Signal Stuff

func wire_yip(yip: Yipee) -> void:
	yip.yip_hovered.connect(_on_yip_hovered)
	yip.yip_unhovered.connect(_on_yip_unhovered)

func _on_yip_hovered(yip: Yipee) -> void:
	print('yip hovered in farm hub')
	focused_yip = yip

func _on_yip_unhovered() -> void:
	print('yip unhovered in farm hub')
	focused_yip = null
	
#endregion
