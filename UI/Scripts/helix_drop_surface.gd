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
