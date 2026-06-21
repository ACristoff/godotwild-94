extends Panel

# A drop bin for one side of the DNA (LEFT or RIGHT). It stays dumb: it only
# reports its side and forwards to Lab, which owns the helix being edited and
# does the slot routing / inventory bookkeeping.

@export var side: String = "LEFT"  # "LEFT" or "RIGHT"
var lab  # set by Lab in _ready

func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	return lab != null and lab.can_place_allele(data, side)

func _drop_data(_pos: Vector2, data: Variant) -> void:
	lab.place_allele(data, side)
