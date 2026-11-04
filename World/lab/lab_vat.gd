extends Node2D

@export var type : String
@export var goop : PackedScene

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
	for i in amnt:
		var goop_spawn = goop.instantiate()
		$LabVatMaskSpawn.add_child(goop_spawn)
		await get_tree().create_timer(0.06).timeout
