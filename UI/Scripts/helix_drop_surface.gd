extends SubViewportContainer

var lab
var dna_screen

func _get_drag_data(_at_position: Vector2) -> Variant:
	if lab == null or dna_screen == null:
		return null
	var rung: int = dna_screen.drop_rung
	var side: String = dna_screen.drop_side
	var allele = lab.allele_at(rung, side)
	if allele == null:
		return null
	set_drag_preview(lab.make_chip_preview(allele))
	return { "allele": allele, "source": "helix", "rung": rung, "side": side }

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if lab == null or dna_screen == null:
		return false
	return lab.can_place_allele(data, dna_screen.rung_at_mouse(), _side_for(data))

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	lab.place_allele(data, dna_screen.rung_at_mouse(), _side_for(data))

# The side is fixed by the allele's type (LeftAllele -> LEFT half, RightAllele ->
# RIGHT half), so there's no need to aim at it on the spinning helix. We only
# need the rung from the cursor's Y; the type decides the side.
func _side_for(data: Variant) -> String:
	if typeof(data) == TYPE_DICTIONARY and data.has("allele"):
		return "LEFT" if data.allele is LeftAllele else "RIGHT"
	return ""
