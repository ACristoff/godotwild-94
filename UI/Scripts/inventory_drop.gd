extends VBoxContainer

var lab

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return lab != null and lab.can_return_to_inventory(data)

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	lab.return_to_inventory(data)
