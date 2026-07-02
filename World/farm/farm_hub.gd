extends Node2D

const BREED_SOUND := preload("res://Assets/Audio/Sounds/YIPS_FUKN.wav")

#region Variables
var all_yips:  Array[Yipee] = []

var focused_yip: Yipee = null
var dragged_yip: Yipee = null
var drag_offset : Vector2 = Vector2.ZERO

@onready var coin_label: Label = $CanvasLayer/Control/HBoxContainer/MarginContainer2/CoinLabel
@onready var special_areas : Node2D = $Areas
@onready var tooltip: Toolyip = $CanvasLayer/YipToolyip

@onready var farm_slot : Area2D = %BreedFarmSlot
@onready var farm_doors : Sprite2D = %BreedingBarnLargeDoor

var team_slots: Array[Area2D]
@onready var barn_slots: Array[Area2D] = [%b_slot1, %b_slot2]
@onready var main_pen : Area2D = $Areas/MainPen

## Where will store yips globally
var yip_farm_party_position : Dictionary[int, Yipee] = {
	1: null,
	2: null,
	3: null,
	4: null,
	5: null
}

var yip_farm_barn_position : Dictionary[int, Yipee] = {
	1: null,
	2: null
}

#endregion

#region Built in Functions
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Setting barn door stuff
	farm_slot.area_entered.connect(_on_breed_farm_slot_area_entered.bind(farm_slot))
	farm_slot.area_exited.connect(_on_breed_farm_slot_area_exited.bind(farm_slot))

	barn_slots[0].area_entered.connect(_on_breed_farm_slot_area_entered.bind(barn_slots[0]))
	barn_slots[0].area_exited.connect(_on_breed_farm_slot_area_exited.bind(barn_slots[0]))

	barn_slots[1].area_entered.connect(_on_breed_farm_slot_area_entered.bind(barn_slots[1]))
	barn_slots[1].area_exited.connect(_on_breed_farm_slot_area_exited.bind(barn_slots[1]))

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

	_update_barn_doors()
	_try_breed()

	#Tutorials
	if SignalBus.field_clicked:
		$BuyFirstYip.hide()
	if SignalBus.first_yip_bought:
		if !SignalBus.f_y_b_setter:
			$TeamSlots.show()
	if SignalBus.party_slot_tutorial_clicked:
		$TeamSlots.hide()
	if SignalBus.first_yip_bought and not SignalBus.party_slot_tutorial_clicked:
		$TeamSlots.show()
	if SignalBus.breeding_tut_clicked:
		$BreedingTut.hide()
	if SignalBus.party_slot_tutorial_clicked and not SignalBus.breeding_tut_clicked:
		$BreedingTut.show()

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
				tooltip.request_hide()
				print("Picked up a yip", dragged_yip)
				dragged_yip.animation_player.play(&"Grabbed")
		else:
			if dragged_yip:
				_drop_yip(dragged_yip)
				_update_barn_doors()
				_try_breed()
				dragged_yip.animation_player.play(&"RESET")
				dragged_yip = null

	elif event is InputEventMouseMotion:
		if dragged_yip:
			dragged_yip.global_position = get_global_mouse_position() + drag_offset

#endregion

#region Farm Hub Functions
const MIN_DISTANCE_BETWEEN_POINTS: float = 200.0
const MAX_ATTEMPTS_PER_POINT : int = 30
var resserved_spots : Array[Vector2] = []

## Collects the rectangle collision shapes that make up the grazeable space:
## the dedicated GrazingArea plus the MainPen.
func _grazing_shapes() -> Array[CollisionShape2D]:
	var shapes : Array[CollisionShape2D] = []
	for source in [%GrazingArea, main_pen]:
		for child in source.get_children():
			if child is CollisionShape2D and child.shape is RectangleShape2D:
				shapes.append(child)
	return shapes

## Picks a random spot for a yip to spawn in, tries to space yips away from eachother, not guranteed.
func get_random_point_in_area(count : int) -> Array[Vector2]:
	# Array to store each collision shape
	var shapes : Array[CollisionShape2D] = _grazing_shapes()

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
	#yip.cost.visible = false

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

	# Remember barn location between scenes if placed in the barn
	if yip.data.yip_barn_slot != 0:
		yip.global_position = barn_slots[yip.data.yip_barn_slot - 1].global_position
		SignalBus.yip_breed_barn[yip.data.yip_barn_slot] = yip.data
		yip_farm_barn_position[yip.data.yip_barn_slot] = yip

	return yip

func _drop_yip(yip: Yipee) -> void:
	var landed_slot: Area2D = null
	var landed_type: String = ""

	for slot in team_slots:
		if slot.overlaps_area(yip.farmslot):
			landed_slot = slot
			landed_type = "party"
			break

	if landed_slot == null:
		for slot in barn_slots:
			if slot.overlaps_area(yip.farmslot):
				landed_slot = slot
				landed_type = "barn"
				break

	# Always clear the yip out of wherever it currently lives,
	# before placing it anywhere new.
	var vacated_party_slot : int = yip.data.yip_party_slot
	var vacated_barn_slot : int = yip.data.yip_barn_slot
	_clear_yip_from_all(yip)

	if landed_slot != null:
		var slot_number : int = int(landed_slot.name.right(1))

		if landed_type == "party":
			var displaced_data : YipeeData = SignalBus.yip_party[_to_party_slot(slot_number)]
			var displaced_node : Yipee = yip_farm_party_position[slot_number]

			SignalBus.yip_party[_to_party_slot(slot_number)] = yip.data
			yip_farm_party_position[slot_number] = yip
			yip.data.yip_party_slot = slot_number

			if displaced_data != null and displaced_data != yip.data:
				_relocate_displaced(displaced_data, displaced_node, vacated_party_slot, vacated_barn_slot)

			yip.global_position = landed_slot.global_position

		else: # barn
			var displaced_data : YipeeData = SignalBus.yip_breed_barn[slot_number]
			var displaced_node : Yipee = yip_farm_barn_position[slot_number]

			SignalBus.yip_breed_barn[slot_number] = yip.data
			yip_farm_barn_position[slot_number] = yip
			yip.data.yip_barn_slot = slot_number

			if displaced_data != null and displaced_data != yip.data:
				_relocate_displaced(displaced_data, displaced_node, vacated_party_slot, vacated_barn_slot)

			yip.global_position = landed_slot.global_position
		return

	# Grazing area or snap to graze area
	if %GrazingArea.overlaps_area(yip.hover_area) or main_pen.overlaps_area(yip.farmslot):
		yip.data.farm_last_known_position = yip.global_position
	else:
		yip.global_position = yip.data.farm_last_known_position

# Removes a yip from both party/barn it currently occupies,
# in both SignalBus dictionaries and both local node-position dictionaries.
# ignores grazing postion
func _clear_yip_from_all(yip: Yipee) -> void:
	for key in SignalBus.yip_party.keys():
		if SignalBus.yip_party[key] == yip.data:
			SignalBus.yip_party[key] = null
	for key in yip_farm_party_position.keys():
		if yip_farm_party_position[key] == yip:
			yip_farm_party_position[key] = null

	for key in SignalBus.yip_breed_barn.keys():
		if SignalBus.yip_breed_barn[key] == yip.data:
			SignalBus.yip_breed_barn[key] = null
	for key in yip_farm_barn_position.keys():
		if yip_farm_barn_position[key] == yip:
			yip_farm_barn_position[key] = null

	yip.data.yip_party_slot = 0
	yip.data.yip_barn_slot = 0

# Sends the displaced yip back to wherever the dragged yip came from a party slot, a barn slot, or (if neither) the grazing/field area.
func _relocate_displaced(displaced_data: YipeeData, displaced_node: Yipee, vacated_party_slot: int, vacated_barn_slot: int) -> void:
	if vacated_party_slot != 0:
		SignalBus.yip_party[_to_party_slot(vacated_party_slot)] = displaced_data
		displaced_data.yip_party_slot = vacated_party_slot
		displaced_data.yip_barn_slot = 0
		yip_farm_party_position[vacated_party_slot] = displaced_node
		if displaced_node != null:
			displaced_node.global_position = team_slots[vacated_party_slot - 1].global_position

	elif vacated_barn_slot != 0:
		SignalBus.yip_breed_barn[vacated_barn_slot] = displaced_data
		displaced_data.yip_barn_slot = vacated_barn_slot
		displaced_data.yip_party_slot = 0
		yip_farm_barn_position[vacated_barn_slot] = displaced_node
		if displaced_node != null:
			displaced_node.global_position = barn_slots[vacated_barn_slot - 1].global_position

	else:
		displaced_data.yip_party_slot = 0
		displaced_data.yip_barn_slot = 0
		if displaced_node != null:
			displaced_node.global_position = displaced_node.data.farm_last_known_position

func _barn_is_full() -> bool:
	return yip_farm_barn_position[1] != null and yip_farm_barn_position[2] != null

func _can_breed() -> bool:
	var parent_a: YipeeData = SignalBus.yip_breed_barn[1]
	var parent_b: YipeeData = SignalBus.yip_breed_barn[2]
	if parent_a == null or parent_b == null:
		return false
	return not parent_a.bred_today and not parent_b.bred_today

func _update_barn_doors() -> void:
	farm_doors.visible = _can_breed()

func _try_breed() -> void:
	var parent_a: YipeeData = SignalBus.yip_breed_barn[1]
	var parent_b: YipeeData = SignalBus.yip_breed_barn[2]
	if parent_a == null or parent_b == null:
		return
	if parent_a.bred_today or parent_b.bred_today:
		return

	parent_a.bred_today = true
	parent_b.bred_today = true
	var child := YipeeData.breed(parent_a, parent_b)
	SignalBus.yip_inventory.append(child)
	AudMan.play_sfx_wav(BREED_SOUND, 0.0, false)

	var parent_node_a: Yipee = yip_farm_barn_position[1]
	var parent_node_b: Yipee = yip_farm_barn_position[2]
	if parent_node_a != null:
		parent_node_a.visible = false
	if parent_node_b != null:
		parent_node_b.visible = false

	await get_tree().create_timer(3.0).timeout
	if not is_inside_tree():
		return
	
	if is_instance_valid(parent_node_a):
		parent_node_a.visible = true
	if is_instance_valid(parent_node_b):
		parent_node_b.visible = true
	
	var spawn_points := get_random_point_in_area(1)
	child.farm_last_known_position = spawn_points[0]
	wire_yip(spawn_yip(child, 0))
	_update_barn_doors()

# TeamSlot1 (front of the farm row) is the front of the battle formation, which
# battle reads as party slot 5. Maps a visual TeamSlot number <-> party slot key.
# Symmetric (6 - n is its own inverse), so it works for both reads and writes.
func _to_party_slot(team_slot: int) -> int:
	return 6 - team_slot

#endregion

#region Button Stuff


func _on_field_button_pressed():
	SignalBus.field_clicked = true
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

func _on_settings_button_pressed() -> void:
	SignalBus.game_state_changed.emit("Settings")

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

func _on_any_area_entered(entered_area: Area2D, source_area: Area2D) -> void:
	print(source_area.name, " was entered by ", entered_area.name)

func _on_any_area_exited(entered_area: Area2D, source_area: Area2D) -> void:
	print(source_area.name, " was exited by ", entered_area.name)

func _on_breed_farm_slot_area_entered(entered_area: Area2D, source_area: Area2D) -> void:
	print(source_area.name, " was entered by ", entered_area.name)
	if not _barn_is_full():
		farm_doors.visible = false

func _on_breed_farm_slot_area_exited(entered_area: Area2D, source_area: Area2D) -> void:
	print(source_area.name, " was exited by ", entered_area.name)
	_update_barn_doors()

func _on_yip_hovered(yip: Yipee) -> void:
	tooltip.display_beside(yip)
	focused_yip = yip

func _on_yip_unhovered() -> void:
	tooltip.request_hide()
	focused_yip = null

func _on_area_2d_mouse_entered() -> void:
	$LabDoor2.play("DoorOpen")

func _on_area_2d_mouse_exited() -> void:
	$LabDoor2.play("DoorClose")

func _on_lab_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		SignalBus.go_to.emit(SignalBus.Locations.LAB)

func _on_team_slots_next() -> void:
	SignalBus.party_slot_tutorial_clicked = true
	$TeamSlots.hide()
	$BreedingTut.show()
	SignalBus.f_y_b_setter = true


func _on_breeding_tut_next() -> void:
	SignalBus.breeding_tut_clicked = true
	$BreedingTut.hide()

#endregion
