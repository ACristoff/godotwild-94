class_name AlleleLibrary

const RIGHT_DIR := "res://World/yipee/genes/allele/rightallele/resources/"

static var _right_by_slot: Dictionary = {}

static func _ensure_loaded() -> void:
	if not _right_by_slot.is_empty():
		return
	var dir := DirAccess.open(RIGHT_DIR)
	if dir == null:
		push_error("AlleleLibrary: can't open " + RIGHT_DIR)
		return
	for file in dir.get_files():
		if not (file.ends_with(".tres") or file.ends_with(".tres.remap")):
			continue
		var res = load(RIGHT_DIR + file.trim_suffix(".remap"))
		if res is RightAllele:
			if not _right_by_slot.has(res.slot):
				_right_by_slot[res.slot] = []
			_right_by_slot[res.slot].append(res)

static func random_right(slot: BodyMap.Slot, weights: Dictionary) -> RightAllele:
	_ensure_loaded()
	var pool: Array = _right_by_slot.get(slot, [])
	if pool.is_empty():
		return null
	var total := 0.0
	for a in pool:
		total += weights.get(a.rarity, 1.0)
	var roll := randf() * total
	for a in pool:
		roll -= weights.get(a.rarity, 1.0)
		if roll <= 0.0:
			return a
	return pool.back()
