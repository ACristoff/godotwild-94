class_name StatusEffect extends RefCounted

var kind: int
var stacks: int
var clock: float = 0.0 

func _init(p_kind: int, p_stacks: int) -> void:
	kind = p_kind
	stacks = p_stacks
