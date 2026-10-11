extends Node2D

var team_slots: Array[Area2D] = []
var slot_yips: Dictionary[int, Yipee] = {}
@onready var pen_collision = $MainPen/CollisionShape2D

func _ready() -> void:
	for child in get_children():
		if child is Area2D:
			team_slots.append(child)

	for i in range(1, team_slots.size() + 1):
		slot_yips[i] = null


func place_yip(yip: Yipee, slot_number: int) -> void:
	if slot_number < 1 or slot_number > team_slots.size():
		return

	var old_slot: int = yip.data.yip_party_slot

	if old_slot != 0:
		slot_yips[old_slot] = null
		SignalBus.yip_party[6 - old_slot] = null

	var displaced: Yipee = slot_yips[slot_number]

	if displaced != null and displaced != yip:
		displaced.data.yip_party_slot = 0
		displaced.global_position = displaced.data.farm_last_known_position

		for key in SignalBus.yip_party.keys():
			if SignalBus.yip_party[key] == displaced.data:
				SignalBus.yip_party[key] = null

	slot_yips[slot_number] = yip
	yip.data.yip_party_slot = slot_number
	yip.data.yip_barn_slot = 0
	yip.global_position = team_slots[slot_number - 1].global_position

	SignalBus.yip_party[6 - slot_number] = yip.data


func register_yip(yip: Yipee) -> void:
	var slot_number: int = yip.data.yip_party_slot

	if slot_number == 0:
		return

	slot_yips[slot_number] = yip
	yip.global_position = team_slots[slot_number - 1].global_position
	SignalBus.yip_party[6 - slot_number] = yip.data
