extends Node2D

#region Variables
var all_yips:  Array[Yipee] = []

var focused_yip: Yipee = null
var dragged_yip: Yipee = null
var drag_offset : Vector2 = Vector2.ZERO

@onready var coin_label: Label = $CanvasLayer/Control/HBoxContainer/MarginContainer2/CoinLabel
@onready var special_areas : Node2D = $Areas

var team_slots: Array[Area2D]

#endregion

#region Built in Functions
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in special_areas.get_children():
		if child.name != &"MainPen":
			print(child.name)
			team_slots.append(child)
			child.area_entered.connect(_on_any_area_entered.bind(child))
			child.area_exited.connect(_on_any_area_exited.bind(child))
	
	coin_label.text = str(SignalBus.coins)
	for yip in SignalBus.yip_inventory:
		wire_yip(spawn_yip(yip))

# On exit set it so no one can be grabbed
func _exit_tree() -> void:
	for yip_data in SignalBus.yip_inventory:
		yip_data.can_be_grabbed = false

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
			if dragged_yip:
				_drop_yip(dragged_yip)
				dragged_yip = null
				
	elif event is InputEventMouseMotion:
		print(SignalBus.yip_party)
		if dragged_yip:
			dragged_yip.global_position = get_global_mouse_position() + drag_offset

#endregion

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
	var yip : Yipee = preload("res://World/yipee/yipee.tscn").instantiate() as Yipee
	yip.data = data
	if yip.data.farm_last_known_position == Vector2.ZERO:
		yip.global_position = get_random_point_in_area()
		print("Generated Position: ", yip.global_position)
		yip.data.farm_last_known_position = yip.global_position
	else:
		yip.global_position = yip.data.farm_last_known_position
		
	yip.data.can_be_grabbed = true
	
	# Remember party location between scenes if placed in a party
	if yip.data.yip_party_slot != 0:
		yip.global_position = team_slots[yip.data.yip_party_slot - 1].global_position
		SignalBus.yip_party[yip.data.yip_party_slot] = yip
	
	add_child(yip)
	yip.health_UI.visible = false
	yip.health_UI.current_health = yip.health.current_health
	yip.health_UI.max_health = yip.health.max_health
	yip.health_UI.update_UI()
	
	yip.animation_player.play(&"Spawn")
	
	return yip

func _drop_yip(yip: Yipee) -> void:
	var landed_slot: Area2D = null
	
	for slot in team_slots:
		if slot.overlaps_area(yip.farmslot):
			landed_slot = slot
			break
			
	# We are hovering over a slot
	if landed_slot != null:
		# Grab slot number
		var slot_number : int = int(landed_slot.name.right(1))
		
		# Find if another yip already occupies the target slot
		var displaced_yip: Yipee = SignalBus.yip_party[slot_number]
		
		# Updating party position
		for key in SignalBus.yip_party.keys():
			if SignalBus.yip_party[key] == yip:
				SignalBus.yip_party[key] = null
		SignalBus.yip_party[slot_number] = yip

		# If someone was already in that slot, move them to the slot the dragged yip vacated
		if displaced_yip != null and displaced_yip != yip:
			var old_slot_number : int = yip.data.yip_party_slot
			SignalBus.yip_party[old_slot_number] = displaced_yip
			displaced_yip.data.yip_party_slot = old_slot_number
			displaced_yip.global_position = team_slots[old_slot_number - 1].global_position
		
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
		SignalBus.yip_party[yip.data.yip_party_slot] = null
		yip.data.yip_party_slot = 0

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
	yip.animation_player.animation_finished.connect(_on_yip_animation_finished.bind(yip))

func _on_yip_animation_finished(anim_name: StringName, yip: Yipee) -> void:
	if anim_name == &"Spawn":
		print(yip, " finished spawning")
		yip.animation_player.play(&"IdleNormal")

func _on_yip_hovered(yip: Yipee) -> void:
	print('yip hovered in farm hub')
	focused_yip = yip

func _on_yip_unhovered() -> void:
	print('yip unhovered in farm hub')
	focused_yip = null
	
func _on_any_area_entered(entered_area: Area2D, source_area: Area2D) -> void:
	print(source_area.name, " was entered by ", entered_area.name)
	
func _on_any_area_exited(entered_area: Area2D, source_area: Area2D) -> void:
	print(source_area.name, " was exited by ", entered_area.name)

#endregion
