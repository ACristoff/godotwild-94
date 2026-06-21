extends Node2D

#region Variables
var all_yips:  Array[Yipee] = []

var focused_yip: Yipee = null
var dragged_yip: Yipee = null
var drag_offset : Vector2 = Vector2.ZERO

@onready var coin_label: Label = $CanvasLayer/Control/HBoxContainer/MarginContainer2/CoinLabel
@onready var special_areas : Node2D = $Areas
@onready var tooltip: Toolyip = $CanvasLayer/YipToolyip

var team_slots: Array[Area2D]

## Where will store yips globally
var yip_farm_party_position : Dictionary[int, Yipee] = {
	1: null,
	2: null,
	3: null,
	4: null,
	5: null
}

#endregion

#region Built in Functions
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Setting up party slots
	for child in special_areas.get_children():
		if child.name != &"MainPen":
			print(child.name)
			team_slots.append(child)
			child.area_entered.connect(_on_any_area_entered.bind(child))
			child.area_exited.connect(_on_any_area_exited.bind(child))
	
	coin_label.text = str(SignalBus.coins)
	tooltip.hide()

	#Setting up and spawning yips
	resserved_spots = get_random_point_in_area(SignalBus.yip_inventory.size())
	var index : int = 0
	for yip in SignalBus.yip_inventory:
		wire_yip(spawn_yip(yip, index))
		index += 1

# On exit set it so no one can be grabbed
func _exit_tree() -> void:
	for yip_data in SignalBus.yip_inventory:
		yip_data.can_be_grabbed = false
	resserved_spots = []

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
				dragged_yip.animation_player.play(&"Grabbed")
		else:
			if dragged_yip:
				_drop_yip(dragged_yip)
				dragged_yip.animation_player.play(&"RESET")
				dragged_yip = null
				
	elif event is InputEventMouseMotion:
		#print(SignalBus.yip_party)
		if dragged_yip:
			dragged_yip.global_position = get_global_mouse_position() + drag_offset

#endregion

#region Farm Hub Functions
const MIN_DISTANCE_BETWEEN_POINTS: float = 200.0
const MAX_ATTEMPTS_PER_POINT : int = 30
var resserved_spots : Array[Vector2] = []



## Picks a random spot for a yip to spawn in, tries to space yips away from eachother, not guranteed.
func get_random_point_in_area(count : int) -> Array[Vector2]:
	# Array to store each collision shape
	var shapes : Array[CollisionShape2D] = []
	
	# Grab each Collisionshape2D
	for child in %GrazingArea.get_children():
		# Check if its shape is CollisionShape2D
		if child is CollisionShape2D:
			# Check if its shape is RectangleShape2D
			if child.shape is RectangleShape2D:
				shapes.append(child)
				
	# Error if we don't have any grazing spot
	if shapes.is_empty():
		push_error("Why is this empty stupid add some grazing space!!!!!!")
		return []
		
	# Pointts we can use as spots
	var points : Array[Vector2] = []
	
	# Active List for poisson distribution
	var active_list : Array[Vector2] = []
	
	# Seed with one random valid point from a random box
	var first_point : Vector2 = _random_point_in_random_shape(shapes)
	points.append(first_point)
	active_list.append(first_point)
	
	# Keep creating points as long as there is at least one active point to grow from and havent reached number of yips (count)
	while active_list.size() > 0 and points.size() < count:
		# Pick a random point in active list to spawn a new point from
		var active_index : int = randi() % active_list.size() # Index of point we will grow from
		var base_point : Vector2 = active_list[active_index]
		
		# Tracker for valid point or not
		var found_valid : bool = false
		
		# Iterating until we hit limit
		for i in MAX_ATTEMPTS_PER_POINT:
			
			# Point a random angle in a circle
			var angle : float = randf_range(0.0, TAU)
			# Pick a random distance within said circle
			var dist : float = randf_range(MIN_DISTANCE_BETWEEN_POINTS, MIN_DISTANCE_BETWEEN_POINTS * 5.3)
			# Grab the actual normal coordinate at angle and distance, convert it back to regular points
			var candidate : Vector2 = base_point + Vector2(cos(angle), sin(angle)) * dist
			
			# Check if it falls within any of our grazing areas
			if not _is_inside_any_shape(candidate, shapes):
				continue
				
			# Check if it is far enough from all of our points
			if not _is_far_enough(candidate, points):
				continue
			
			# We found a valid point so add it to the list
			points.append(candidate)
			
			# update our active list, we found a new viable canidate, update bool and stop attempting for this base point
			active_list.append(candidate)
			found_valid = true
			break
		
		# We exuasted all tries for this canidate point so remove it from the list
		if not found_valid:
			active_list.remove_at(active_index)
			
	# We didn't produce enough points for our yips so generate random points
	if points.size() < count:
		var remaining : int = count - points.size()
		push_warning("Only found %d spaced points, filling remaining %d with plain random points" % [points.size(), remaining])
		
		for i in remaining:
			points.append(_random_point_in_random_shape(shapes))
	
	return points


## Picks a random shape, generates a random point inside its local bound then convert to global.
func _random_point_in_random_shape(shapes : Array[CollisionShape2D]) -> Vector2:
	var shape_node : CollisionShape2D = shapes[randi() % shapes.size()]
	var rect_shape : RectangleShape2D = shape_node.shape
	var extents : Vector2 = rect_shape.size / 2.0
	var local_point : Vector2 = Vector2(randf_range(-extents.x, extents.x), randf_range(-extents.y, extents.y))
	return shape_node.to_global(local_point)

## Checks if a global point is inside any of our shapes  (grazing areas)
func _is_inside_any_shape(global_point : Vector2, shapes : Array[CollisionShape2D]) -> bool:
	for shape_node in shapes:
		var local_point : Vector2 = shape_node.to_local(global_point)
		var rect_shape : RectangleShape2D = shape_node.shape
		var extents : Vector2 = rect_shape.size / 2.0
		
		# Use abs to cover both positive and negative distance
		if abs(local_point.x) <= extents.x and abs(local_point.y) <= extents.y:
			return true
	return false

## Checks to see if a point is far enough basically
func _is_far_enough(point : Vector2, existing_points : Array[Vector2]) -> bool:
	for p in existing_points:
		if point.distance_to(p) < MIN_DISTANCE_BETWEEN_POINTS:
			return false
	return true



func spawn_yip(data: YipeeData, index : int) -> Yipee:
	# Creating yip node
	var yip : Yipee = preload("res://World/yipee/yipee.tscn").instantiate() as Yipee
	# Setting data
	yip.data = data
	
	# Add to scene
	add_child(yip)
	yip.health_UI.visible = false
	yip.health_UI.current_health = yip.health.current_health
	yip.health_UI.max_health = yip.health.max_health
	yip.health_UI.update_UI()
	
	# Checking if this yip already had a farm position
	if yip.data.farm_last_known_position == Vector2.ZERO:
		yip.global_position = resserved_spots[index]
		print("Generated Position: ", yip.global_position)
		yip.data.farm_last_known_position = yip.global_position
		yip.animation_player.play(&"Spawn")
		
	# If it already had one then place it there
	else:
		yip.global_position = yip.data.farm_last_known_position
		yip.animation_player.play(&"IdleNormal")
	
	# It can be dragged and dropped
	yip.data.can_be_grabbed = true
	
	# Remember party location between scenes if placed in a party
	if yip.data.yip_party_slot != 0:
		yip.global_position = team_slots[yip.data.yip_party_slot - 1].global_position
		SignalBus.yip_party[_to_party_slot(yip.data.yip_party_slot)] = yip.data
		yip_farm_party_position[yip.data.yip_party_slot] = yip
	
	return yip

func _drop_yip(yip: Yipee) -> void:
	# Party slot
	var landed_slot: Area2D = null
	
	# Check if our yip is overlapping with a party slot and store it
	for slot in team_slots:
		if slot.overlaps_area(yip.farmslot):
			landed_slot = slot
			break
			
	# We are hovering over a slot
	if landed_slot != null:
		
		# Grab the slot number
		var slot_number : int = int(landed_slot.name.right(1))
	
		# Find if another yip already occupies the target slot
		var displaced_yip_data: YipeeData = SignalBus.yip_party[_to_party_slot(slot_number)]
		var displaced_yip_node: Yipee = yip_farm_party_position[slot_number]
		
		# Updating party position
		for key in SignalBus.yip_party.keys():
			
			# Remove yip from old slot
			if SignalBus.yip_party[key] == yip.data:
				SignalBus.yip_party[key] = null
				yip_farm_party_position[key] = null
				
		# Put yip in new slot
		SignalBus.yip_party[_to_party_slot(slot_number)] = yip.data
		yip_farm_party_position[slot_number] = yip

		# Swapping logic
		# Yip in target slot and is not one we are moving
		if displaced_yip_data != null and displaced_yip_data != yip.data:
			
			# get slot number of old dragged yip
			var old_slot_number : int = yip.data.yip_party_slot
			
			# dragged yip came from another party slot
			if old_slot_number != 0:
				# Move displaced yip into the slot the dragged yip came from
				SignalBus.yip_party[_to_party_slot(old_slot_number)] = displaced_yip_data
				displaced_yip_data.yip_party_slot = old_slot_number
				
				yip_farm_party_position[old_slot_number] = displaced_yip_node
				if displaced_yip_node != null:
					displaced_yip_node.global_position = team_slots[old_slot_number - 1].global_position
			else:
				displaced_yip_data.yip_party_slot = 0
				if displaced_yip_node != null:
					displaced_yip_node.global_position = displaced_yip_node.data.farm_last_known_position
		
		# Updating our position
		yip.global_position = landed_slot.global_position
		yip.data.yip_party_slot = slot_number
	
		return
	
	# Check if yip is inside of the grazing area
	# If it is, then place it there, set last known location
	if %GrazingArea.overlaps_area(yip.hover_area):
		yip.data.farm_last_known_position = yip.global_position
	else:
		# If it is not, then don't place it there, place it at its last known location
		yip.global_position = yip.data.farm_last_known_position
	
	# Removing yip from party when we removing it
	if yip.data.yip_party_slot != 0:
		SignalBus.yip_party[_to_party_slot(yip.data.yip_party_slot)] = null
		yip_farm_party_position[yip.data.yip_party_slot] = null
		yip.data.yip_party_slot = 0

# TeamSlot1 (front of the farm row) is the front of the battle formation, which
# battle reads as party slot 5. Maps a visual TeamSlot number <-> party slot key.
# Symmetric (6 - n is its own inverse), so it works for both reads and writes.
func _to_party_slot(team_slot: int) -> int:
	return 6 - team_slot

#endregion

#region Button Stuff


func _on_field_button_pressed():
	SignalBus.go_to.emit(SignalBus.Locations.FIELD)
	pass # Replace with function body.

func _on_battle_button_pressed():
	var has_yip := false
	for yip in SignalBus.yip_party.values():
		if yip != null:
			has_yip = true
			break
	if not has_yip:
		return
	SignalBus.go_to.emit(SignalBus.Locations.BATTLE)

#endregion

#region Signal Stuff

func wire_yip(yip: Yipee) -> void:
	yip.yip_hovered.connect(_on_yip_hovered)
	yip.yip_unhovered.connect(_on_yip_unhovered)
	yip.animation_player.animation_finished.connect(_on_yip_animation_finished.bind(yip))

func _on_yip_animation_finished(anim_name: StringName, yip: Yipee) -> void:
	if anim_name == &"Spawn" or anim_name == &"RESET":
		print(yip, " finished spawning")
		yip.animation_player.play(&"IdleNormal")

func _on_yip_hovered(yip: Yipee) -> void:
	var screen_size = get_viewport().get_visible_rect().size / 3
	tooltip.display(yip)
	var screen_pos = yip.get_global_transform_with_canvas().origin
	tooltip.global_position = $CanvasLayer.transform.affine_inverse() * screen_pos
	tooltip.global_position.y -= 99
	tooltip.global_position.x -= 55
	tooltip.global_position.x = clamp(tooltip.global_position.x, 0, screen_size.x - tooltip.tt_size.x)
	tooltip.global_position.y = clamp(tooltip.global_position.y, 0, screen_size.y - tooltip.tt_size.y)
	focused_yip = yip

func _on_yip_unhovered() -> void:
	tooltip.hide()
	focused_yip = null
	
func _on_any_area_entered(entered_area: Area2D, source_area: Area2D) -> void:
	print(source_area.name, " was entered by ", entered_area.name)
	
func _on_any_area_exited(entered_area: Area2D, source_area: Area2D) -> void:
	print(source_area.name, " was exited by ", entered_area.name)

#endregion


func _on_area_2d_mouse_entered() -> void:
	$LabDoor2.play("DoorOpen")
func _on_area_2d_mouse_exited() -> void:
	$LabDoor2.play("DoorClose")
