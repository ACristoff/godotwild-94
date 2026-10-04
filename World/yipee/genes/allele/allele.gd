class_name Allele
extends Resource

enum Side { LEFT, RIGHT }
enum AlleleRarity { COMMON, UNCOMMON, RARE, ULTRARARE}

const MAX_TIER := 3

var side: Allele.Side
@export var slot: BodyMap.Slot


@export var allele_name: String = ""
@export var tooltip: String = ""
@export var tier: int = 1
@export var rarity: AlleleRarity = AlleleRarity.COMMON
@export var flat_mods: Dictionary[BodyMap.Stat, int] = {}
@export var percent_mods: Dictionary[BodyMap.Stat, float] = {}

static func can_fuse(a: Allele, b: Allele) -> bool:
	return a != null and b != null \
		and a != b \
		and a.get_script() == b.get_script() \
		and a.slot == b.slot \
		and a.allele_name == b.allele_name \
		and a.tier == b.tier \
		and a.tier < MAX_TIER

static func fuse(a: Allele, b: Allele) -> Allele:
	if not can_fuse(a, b):
		return null
	var fused: Allele = a.duplicate(true)
	fused.tier = a.tier + 1
	return fused

func get_damage_pips() -> Dictionary:
	return {}

func get_tooltip() -> String:
	return tooltip.format(_tooltip_subs())

func _tooltip_subs() -> Dictionary:
	var subs := {}
	for stat in flat_mods:
		subs[BodyMap.Stat.keys()[stat].to_lower()] = flat_mods[stat] * tier
	for stat in percent_mods:
		subs[BodyMap.Stat.keys()[stat].to_lower() + "_pct"] = roundi(percent_mods[stat] * tier * 100.0)
	return subs

func flat_for(stat: BodyMap.Stat) -> float:
	return flat_mods.get(stat, 0) * tier

func percent_for(stat: BodyMap.Stat) -> float:
	return percent_mods.get(stat, 0.0) * tier

# Passive Stat buffs/nerfs
func modify_stat(base_value: float, _yipee_data) -> float:
	return base_value

#Daily life triggers
func on_day_start() -> void:
	pass

func on_breed() -> void:
	pass

# Combat triggers
func on_battle_start() -> void:
	pass

func on_adjacent_ally_attack() -> void:
	pass

func on_ally_take_damage() -> void:
	pass

func on_status_gained() -> void:
	pass

func on_attack(_damage_data: DamageInfo, _battle) -> void:
	pass

func on_hit(_damage_data: DamageInfo, _battle) -> void:
	pass

func on_crit(_damage_data: DamageInfo, _battle) -> void:
	pass

func on_take_damage(_damage_data: DamageInfo, _battle) -> void:
	pass

func on_death(_battle) -> void:
	pass
