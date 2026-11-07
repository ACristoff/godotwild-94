class_name PartySnapshot

const PARTY_SIZE := 5

static func allele_to_dict(allele: Allele) -> Variant:
	if allele == null:
		return null
	return {
		"name": allele.allele_name,
		"tier": allele.tier,
		"goop": allele.goop_progress,
	}

static func strand_to_dict(strand: Strand) -> Variant:
	if strand == null:
		return null
	return {
		"slot": BodyMap.Slot.keys()[strand.slot],
		"left": allele_to_dict(strand.left),
		"right": allele_to_dict(strand.right),
	}

static func yip_to_dict(data: YipeeData, party_key: int) -> Dictionary:
	var rungs: Array = []
	for strand in data.helix.strands:
		rungs.append(strand_to_dict(strand))
	return {
		"party_key": party_key,
		"yipee_name": data.yipee_name,
		"age": data.age,
		"tier": YipeeData.YipTier.keys()[data.tier],
		"base_health": data.base_health,
		"base_attack": data.base_attack,
		"base_cooldown": data.base_cooldown,
		"base_crit_chance": data.base_crit_chance,
		"rungs": rungs,
	}

static func party_to_dict(party: Array, won: bool, day: int) -> Dictionary:
	var yips: Array = []
	for index in party.size():
		var data: YipeeData = party[index]
		if data == null:
			continue
		yips.append(yip_to_dict(data, index + 1))
	return {
		"format": SnapshotStore.FORMAT_VERSION,
		"run_id": SignalBus.run_id,
		"day": day,
		"victories": SignalBus.victories,
		"current_health": SignalBus.current_health,
		"won": won,
		"player_name": SignalBus.player_name,
		"player_portrait": SignalBus.player_portrait,
		"timestamp": Time.get_datetime_string_from_system(true),
		"yips": yips,
	}

static func dict_to_allele(allele_dict: Variant, side: Allele.Side) -> Allele:
	if typeof(allele_dict) != TYPE_DICTIONARY:
		return null
	var allele_name := str(allele_dict.get("name", ""))
	var allele: Allele
	if side == Allele.Side.LEFT:
		allele = AlleleLibrary.find_left(allele_name)
	else:
		allele = AlleleLibrary.find_right(allele_name)
	if allele == null:
		return null
	allele.tier = clampi(int(allele_dict.get("tier", 1)), 1, Allele.MAX_TIER)
	allele.goop_progress = int(allele_dict.get("goop", 0))
	return allele

static func dict_to_strand(strand_dict: Variant) -> Strand:
	if typeof(strand_dict) != TYPE_DICTIONARY:
		return null
	var slot_name := str(strand_dict.get("slot", ""))
	if not BodyMap.Slot.has(slot_name):
		return null
	var strand := Strand.new()
	strand.slot = BodyMap.Slot[slot_name]
	strand.left = dict_to_allele(strand_dict.get("left"), Allele.Side.LEFT) as LeftAllele
	strand.right = dict_to_allele(strand_dict.get("right"), Allele.Side.RIGHT) as RightAllele
	return strand

static func dict_to_yip(yip_dict: Dictionary) -> YipeeData:
	var data := YipeeData.new()
	data.yipee_name = str(yip_dict.get("yipee_name", ""))
	data.age = int(yip_dict.get("age", 1))
	var tier_name := str(yip_dict.get("tier", ""))
	if YipeeData.YipTier.has(tier_name):
		data.tier = YipeeData.YipTier[tier_name]
	data.base_health = int(yip_dict.get("base_health", 10))
	data.base_attack = int(yip_dict.get("base_attack", 1))
	data.base_cooldown = float(yip_dict.get("base_cooldown", 7.0))
	data.base_crit_chance = int(yip_dict.get("base_crit_chance", 3))
	var rungs = yip_dict.get("rungs", [])
	if typeof(rungs) == TYPE_ARRAY:
		for rung_index in mini(rungs.size(), Helix.RUNG_COUNT):
			data.helix.strands[rung_index] = dict_to_strand(rungs[rung_index])
	return data

static func dict_to_level(snapshot: Dictionary) -> Level:
	var yips = snapshot.get("yips", [])
	if typeof(yips) != TYPE_ARRAY:
		return null
	var enemy_team: Array[YipeeData] = []
	enemy_team.resize(PARTY_SIZE)
	var yip_count := 0
	for yip_dict in yips:
		if typeof(yip_dict) != TYPE_DICTIONARY:
			continue
		var formation_index := int(yip_dict.get("party_key", 0)) - 1
		if formation_index < 0 or formation_index >= PARTY_SIZE:
			continue
		enemy_team[formation_index] = dict_to_yip(yip_dict)
		yip_count += 1
	if yip_count == 0:
		return null
	var level := Level.new()
	level.level_name = str(snapshot.get("player_name", ""))
	level.opponent_portrait = str(snapshot.get("player_portrait", ""))
	level.enemy_team = enemy_team
	return level
