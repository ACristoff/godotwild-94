class_name Helix extends Resource
## The DNA container: an ordered set of strand slots matching the rungs
## in the sketch. Modifiable at runtime (lab screen) — every mutation
## calls emit_changed() so live Yipee bodies can re-derive their stats.

enum Slot {
	HEALTH,
	HEALTH_AUGMENT,
	ATTACK,
	ATTACK_AUGMENT_1,
	ATTACK_AUGMENT_2,
	COOLDOWN,
	SPECIALIZATION,
	BREED_AUGMENT,
}
const SLOT_COUNT := 8

## Indexed by Slot. Entries may be null (empty rung).
@export var strands: Array[Strand] = []:
	set(value):
		strands = value
		if strands.size() < SLOT_COUNT:
			strands.resize(SLOT_COUNT)

func _init() -> void:
	if strands.size() < SLOT_COUNT:
		strands.resize(SLOT_COUNT)

func get_strand(slot: Slot) -> Strand:
	return strands[slot]

func set_strand(slot: Slot, strand: Strand) -> void:
	assert(strand.left == null or strand.left.slot == slot, "Strand slot doesn't match its left allele")
	if strand.slot != slot:
		return
	strands[slot] = strand
	emit_changed()

## Pops a strand out of the helix (e.g., into lab inventory) and returns it.
func remove_strand(slot: Slot) -> Strand:
	var strand := strands[slot]
	strands[slot] = null
	emit_changed()
	return strand

## Deep copy — strands are duplicated too, so no shared references.
func clone() -> Helix:
	return duplicate(true) as Helix
