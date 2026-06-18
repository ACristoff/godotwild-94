class_name Helix extends Resource
## The DNA container: an ordered set of strand slots matching the rungs
## in the sketch. Modifiable at runtime (lab screen) — every mutation
## calls emit_changed() so live Yipee bodies can re-derive their stats.

const RUNG_COUNT := 8

static var fill_chance_by_tier = {
	YipeeData.YipTier.COMMON: 25,
	YipeeData.YipTier.UNCOMMON: 30,
	YipeeData.YipTier.RARE: 50,
	YipeeData.YipTier.ULTRARARE: 60
}

## Indexed by Slot. Entries may be null (empty rung).
@export var strands: Array[Strand] = []:
	set(value):
		strands = value
		if strands.size() < RUNG_COUNT:
			strands.resize(RUNG_COUNT)

func _init() -> void:
	if strands.size() < RUNG_COUNT:
		strands.resize(RUNG_COUNT)

static func generate_random(yip_tier: YipeeData.YipTier = YipeeData.YipTier.COMMON) -> Helix:
	var helix := Helix.new()
	var types := BodyMap.Slot.values()
	for i in RUNG_COUNT:
		var random = randi_range(0, 99)
		var current_odds = fill_chance_by_tier[yip_tier]
		
		if random < current_odds:
			var strand := Strand.new()
			strand.slot = types.pick_random()
			helix.strands[i] = strand
	
	return helix

func get_rung(index: int) -> Strand:
	return strands[index]

func set_rung(index: int, strand: Strand) -> void:
	strands[index] = strand
	emit_changed()

func clear_rung(index: int) -> Strand:
	var strand := strands[index]
	strands[index] = null
	emit_changed()
	return strand

func strands_of_type(slot: BodyMap.Slot) -> Array[Strand]:
	var out: Array[Strand] = []
	for strand in strands:
		if strand != null and strand.slot == slot:
			out.append(strand)
	return out

## Deep copy — strands are duplicated too, so no shared references.
func clone() -> Helix:
	return duplicate(true) as Helix
