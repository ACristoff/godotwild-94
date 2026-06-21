extends Control

var lab
var dna_screen

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_BEGIN:
		mouse_filter = Control.MOUSE_FILTER_STOP
		if dna_screen != null:
			dna_screen.set_dragging(true)
	elif what == NOTIFICATION_DRAG_END:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		if dna_screen != null:
			dna_screen.set_dragging(false)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if lab == null or dna_screen == null:
		return false
	dna_screen.face_toward(at_position)
	return lab.can_place_allele(data, dna_screen.rung_at_local(at_position), _side_for(data))

func _drop_data(at_position: Vector2, data: Variant) -> void:
	lab.place_allele(data, dna_screen.rung_at_local(at_position), _side_for(data))

func _side_for(data: Variant) -> String:
	if typeof(data) == TYPE_DICTIONARY and data.has("allele"):
		return "LEFT" if data.allele is LeftAllele else "RIGHT"
	return ""
