extends TextureRect

# One allele in the lab inventory row. The gene_small.png body is tinted by the
# allele's slot color, matching the CRT rung it belongs in. TextureRect (a
# Control) is the chip root so it can be a native drag-and-drop source.

var allele: Allele = null
var source_index: int = -1
var hovering = false
var current_allele
var allele_data: Allele
const ALELLE_UI = preload("uid://cckwntee1s0l4")
var spawn_pos

func _ready() -> void:
	var allele = ALELLE_UI.instantiate()
	current_allele = allele
	add_child(allele)
	allele.hide()


func set_allele(allele: Allele, side: String, slot_key: String) -> void:
	allele_data = allele
	if current_allele == null or allele == null:
		return
	current_allele.update_info(allele.allele_name, side, allele.get_tooltip(), slot_key, allele.tier)
# Same hex the CRT shells use (see dna_stacked_shell.set_slot) so a chip reads
# the exact color of its rung. modulate multiplies the texture, so a white-ish
# gene sprite takes the slot color directly.
const SLOT_COLORS := {
	BodyMap.Slot.HEALTH:         "779422",
	BodyMap.Slot.HEALTH_AUGMENT: "5f70e0",
	BodyMap.Slot.ATTACK:         "9c2424",
	BodyMap.Slot.ATTACK_AUGMENT: "d14830",
	BodyMap.Slot.COOLDOWN:       "56bccc",
	BodyMap.Slot.SPECIALIZATION: "cc4bae",
	BodyMap.Slot.BREED_AUGMENT:  "784bcc",
	BodyMap.Slot.NONE:           "3d3d3d",
}

func setup(a: Allele, idx: int) -> void:
	allele = a
	source_index = idx
	modulate = Color.from_string(SLOT_COLORS.get(a.slot, "3d3d3d"), Color.WHITE)

func _get_drag_data(_pos: Vector2) -> Variant:
	if allele == null:
		return null
	# Floating preview that follows the cursor.
	var preview := TextureRect.new()
	preview.texture = texture
	preview.modulate = modulate
	preview.flip_h = flip_h
	preview.custom_minimum_size = custom_minimum_size
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_drag_preview(preview)
	# Thread origin through the payload so _drop_data can pull this allele out of
	# allele_inventory and return any displaced allele to index `index`.
	return { "allele": allele, "index": source_index }


func _on_area_2d_mouse_entered() -> void:
	if allele == null:
		return
	var screen_size = get_viewport().get_visible_rect().size / 3
	var tt_size = Vector2(107, 22)
	spawn_pos = self.global_position
	current_allele.global_position.y = spawn_pos.y - 25
	current_allele.global_position.x = clamp(current_allele.global_position.x, 0, screen_size.x - tt_size.x)
	current_allele.global_position.y = clamp(current_allele.global_position.y, 0, screen_size.y - tt_size.y)
	current_allele.show()
	current_allele.squish()


func _on_area_2d_mouse_exited() -> void:
	current_allele.hide()
