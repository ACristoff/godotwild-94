extends Node


func _ready() -> void:
	var h := Helix.generate_random()
	for strand in h.strands:
		print(BodyMap.Slot.keys()[strand.slot])
	#print()
