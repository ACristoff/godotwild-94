class_name YipeeData
extends Resource

## Yipee data resource, base stats + genes
## this is what gets saved, bred, and modified in the lab.
## final (derived) stats = base stat run through the strand in the matching slot.

enum YipTier {
	COMMON,
	UNCOMMON,
	RARE,
	ULTRARARE
}

const YIP_TABLE := {
	YipTier.COMMON: {
		"HP": [40, 80],
		"ATK": [1, 5],
		"COOLDOWN": [4.5, 8.0],
	},
	YipTier.UNCOMMON: {
		"HP": [60, 100],
		"ATK": [6, 15],
		"COOLDOWN": [4.0, 7.5],
	},
	YipTier.RARE: {
		"HP": [120, 230],
		"ATK": [16, 40],
		"COOLDOWN": [3.5, 6.0],
	},
	YipTier.ULTRARARE: {
		"HP": [300, 400],
		"ATK": [41, 70],
		"COOLDOWN": [3.0, 5.5],
	},
}

@export var yipee_name: String = ""
@export var age: int = 0
@export var tier: YipTier = YipTier.COMMON

@export_group("Base Stats")
@export var base_health: int = 40
@export var base_attack: int = 1
@export var base_cooldown: float = 6

@export var helix: Helix

func _init() -> void:
	if helix == null:
		helix = Helix.new()

func get_health() -> float:
	return _derived(base_health, BodyMap.Stat.HEALTH)

func get_attack() -> float:
	return _derived(base_attack, BodyMap.Stat.ATTACK)

func get_cooldown() -> float:
	return _derived(base_cooldown, BodyMap.Stat.COOLDOWN)

func _derived(base: float, stat: BodyMap.Stat) -> float:
	var result := base
	for slot: Helix.Slot in BodyMap.STAT_SLOTS[stat]:
		var strand := helix.get_strand(slot)
		if strand:
			result = strand.modify_stat(result, self)
	return result

func clone() -> YipeeData:
	return duplicate(true) as YipeeData



static func generate_yip(tier: YipTier) -> YipeeData:
	var new_yip = YipeeData.new()
	
	new_yip.tier = tier
	new_yip.base_attack = randi_range(YIP_TABLE[tier]["ATK"][0], YIP_TABLE[tier]["ATK"][1])
	new_yip.base_health = randi_range(YIP_TABLE[tier]["HP"][0], YIP_TABLE[tier]["HP"][1])
	new_yip.base_cooldown = randf_range(YIP_TABLE[tier]["COOLDOWN"][0], YIP_TABLE[tier]["COOLDOWN"][1])
	return new_yip
