class_name AlleleLibrary

const RIGHT_DIR := "res://World/yipee/genes/allele/rightallele/resources/"
const LEFT_DIR := "res://World/yipee/genes/allele/leftallele/resources/"

static var _right_by_slot: Dictionary = {}
static var _left_by_slot: Dictionary = {}
static var _right_by_name: Dictionary = {}
static var _left_by_name: Dictionary = {}

static func _ensure_loaded() -> void:
	if _right_by_slot.is_empty():
		_right_by_slot = _scan_dir(RIGHT_DIR)
		_right_by_name = _index_by_name(_right_by_slot)
	if _left_by_slot.is_empty():
		_left_by_slot = _scan_dir(LEFT_DIR)
		_left_by_name = _index_by_name(_left_by_slot)

static func _scan_dir(path: String) -> Dictionary:
	var by_slot: Dictionary = {}
	var dir := DirAccess.open(path)
	if dir == null:
		push_error("AlleleLibrary: can't open " + path)
		return by_slot
	for file in dir.get_files():
		if not (file.ends_with(".tres") or file.ends_with(".tres.remap")):
			continue
		var res = load(path + file.trim_suffix(".remap"))
		if res is Allele:
			if not by_slot.has(res.slot):
				by_slot[res.slot] = []
			by_slot[res.slot].append(res)
	return by_slot

static func random_right(slot: BodyMap.Slot, weights: Dictionary) -> RightAllele:
	_ensure_loaded()
	var picked := _weighted_pick(_right_by_slot.get(slot, []), weights)
	if picked == null:
		return null
	return picked.duplicate(true) as RightAllele

static func random_left(slot: BodyMap.Slot, weights: Dictionary) -> LeftAllele:
	_ensure_loaded()
	var picked := _weighted_pick(_left_by_slot.get(slot, []), weights)
	if picked == null:
		return null
	return picked.duplicate(true) as LeftAllele

static func _weighted_pick(pool: Array, weights: Dictionary) -> Allele:
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

static func _index_by_name(by_slot: Dictionary) -> Dictionary:
	var by_name: Dictionary = {}
	for slot_pool in by_slot.values():
		for allele in slot_pool:
			by_name[allele.allele_name] = allele
	return by_name

static func find_left(allele_name: String) -> LeftAllele:
	_ensure_loaded()
	var template = _left_by_name.get(allele_name)
	if template == null:
		return null
	return template.duplicate(true) as LeftAllele

static func find_right(allele_name: String) -> RightAllele:
	_ensure_loaded()
	var template = _right_by_name.get(allele_name)
	if template == null:
		return null
	return template.duplicate(true) as RightAllele
