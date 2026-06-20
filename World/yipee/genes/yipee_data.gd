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


#region Farm Hub stuff
# Yip can only be picked up in the Farm Hub.
# This will also let us know when they are in the farm hub
var can_be_grabbed : bool = false

# If the yip gets dragged off screen, we snap it back to its last known location
# I want them to run back to the old position if possible with a cute animation. We can slide them for now
# When the yip is spawned in the farm hub, set this variable, we will be spawning the yip in the safe areas.
var farm_last_known_position : Vector2 = Vector2.ZERO
#endregion

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
	var flat_sum := 0.0
	var pct_sum := 0.0
	for strand in helix.strands:
		if strand == null:
			continue
		if strand.left:
			flat_sum += strand.left.flat_for(stat)
			pct_sum += strand.left.percent_for(stat)
		if strand.right:
			flat_sum += strand.right.flat_for(stat)
			pct_sum += strand.right.percent_for(stat)
	return maxf(0.0, (base + flat_sum) * (1.0 + pct_sum))

func clone() -> YipeeData:
	return duplicate(true) as YipeeData

static func generate_yip(chosen_tier: YipTier) -> YipeeData:
	var new_yip = YipeeData.new()
	
	new_yip.tier = chosen_tier
	new_yip.base_attack = randi_range(YIP_TABLE[chosen_tier]["ATK"][0], YIP_TABLE[chosen_tier]["ATK"][1])
	new_yip.base_health = randi_range(YIP_TABLE[chosen_tier]["HP"][0], YIP_TABLE[chosen_tier]["HP"][1])
	new_yip.base_cooldown = randf_range(YIP_TABLE[chosen_tier]["COOLDOWN"][0], YIP_TABLE[chosen_tier]["COOLDOWN"][1])
	new_yip.age = randi_range(1,20)
	var new_helix: Helix = Helix.generate_random(chosen_tier)
	new_yip.helix = new_helix
	
	return new_yip
