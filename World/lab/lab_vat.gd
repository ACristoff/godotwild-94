extends Node2D

@export var type : String
@export var goop : PackedScene

var current_stars: Array[Node2D] = []

const SLOT_COLORS := {
	BodyMap.Slot.HEALTH:         "779422",
	BodyMap.Slot.HEALTH_AUGMENT: "779422",
	BodyMap.Slot.ATTACK:         "9c2424",
	BodyMap.Slot.ATTACK_AUGMENT: "d14830",
	BodyMap.Slot.COOLDOWN:       "56bccc",
	BodyMap.Slot.SPECIALIZATION: "cc4bae",
	BodyMap.Slot.BREED_AUGMENT:  "784bcc",
	BodyMap.Slot.NONE:           "3d3d3d",
}

func spawn_goop(amnt):
	var slot = BodyMap.Slot.get(type, BodyMap.Slot.NONE)
	var color := Color(SLOT_COLORS[slot])
	for i in amnt:
		var goop_spawn = goop.instantiate()
		$LabVatMaskSpawn.add_child(goop_spawn)
		goop_spawn.color = color
		current_stars.append(goop_spawn)
		await get_tree().create_timer(0.06).timeout

func remove_goop():
	if current_stars.size() > 0:
		var star_to_delete = current_stars[current_stars.size() - 1]
		current_stars.erase(star_to_delete)
		star_to_delete.queue_free()
		#current_stars.pop_back()
