extends Node2D

@onready var tooltip: Toolyip = $TooltipCanvas/YipToolyip
@onready var conveyor_animation = $Mulcher/ConveyorAnimation
@onready var shredder_animation = $Mulcher/ShredderAnimation
@onready var pen_collision : CollisionShape2D = $Pen/PenArea/CollisionShape2D
@onready var team_slot_conatiner = $TeamSlots

@export var debug_yips : Array[YipeeData] = []

var focused_yip: Yipee = null
var dragged_yip: Yipee = null
var drag_offset: Vector2 = Vector2.ZERO
var yip_on_shredder: Yipee = null
var team_slots: Array[Area2D] = []
var conveyor_has_yip: Yipee = null

var slot_yips: Dictionary[int, Yipee] = {
	1: null,
	2: null,
	3: null,
	4: null,
	5: null,
	6: null, #I guess this is the lab pedestal?
}

#region built-in-functions

func _ready():
	for child in team_slot_conatiner.get_children():
		team_slots.append(child)
	for yip in debug_yips:
		spawn_yip(yip)
	#prints(team_slots)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if focused_yip:
					dragged_yip = focused_yip
					drag_offset = dragged_yip.global_position - get_global_mouse_position()
			else:
				if dragged_yip:
					print('dropped yip')
					for i in range(team_slots.size()):
						var slot: Area2D = team_slots[i]
						
						if slot.overlaps_area(dragged_yip.farmslot):
							print('dropped yip on area')
							place_yip(dragged_yip, i + 1)
							break
					
					dragged_yip = null
	
	elif event is InputEventMouseMotion:
		if dragged_yip:
			dragged_yip.global_position = get_global_mouse_position() + drag_offset

#endregion

#region shredder

func shred_yip(yip: Yipee):
	#do yip animation and effects here
	#take yips gene goop and add it to inventory
	#shred yip here, remove from player and kill
	#do a random yip death sound
	pass

func start_conveyor():
	shredder_animation.current_animation = "shredder_on"
	conveyor_animation.current_animation = "conveyor_on"
	pass

func _on_conveyor_area_area_entered(_area):
	
	start_conveyor()
	#start_conveyor(yip)
	pass # Replace with function body.

func _on_conveyor_area_area_exited(_area):
	if !conveyor_has_yip:
		shredder_animation.current_animation = "RESET"
		conveyor_animation.current_animation = "RESET"
		pass
	pass # Replace with function body.


#endregion 

#region goop_chamber

#endregion

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
	
	if yip.data.yip_party_slot != 0:
		#yip.global_position = team_slots[yip.data.yip_party_slot - 1].global_position
		#yip_lab_party_position[yip.data.yip_party_slot] = yip
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
		displaced.global_position = displaced.data.farm_last_known_position
	
		for key in SignalBus.yip_party.keys():
			if SignalBus.yip_party[key] == displaced.data:
				SignalBus.yip_party[key] = null
	
	# Place the new yip.
	slot_yips[slot_number] = yip
	yip.data.yip_party_slot = slot_number
	yip.data.yip_barn_slot = 0
	yip.global_position = team_slots[slot_number - 1].global_position
	
	
	# Update global party (visual slot 1 maps to party slot 5).
	SignalBus.yip_party[6 - slot_number] = yip.data
	prints(SignalBus.yip_party)

func _on_yip_hovered(yip: Yipee) -> void:
	if not is_instance_valid(yip):
		return
	tooltip.display_beside(yip)
	focused_yip = yip

func _on_yip_unhovered() -> void:
	tooltip.hide()
	focused_yip = null
	pass

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
