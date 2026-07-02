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
		"HP": [10, 15],
		"ATK": [1, 3],
		"COOLDOWN": [7.0, 8.0],
	},
	YipTier.UNCOMMON: {
		"HP": [16, 21],
		"ATK": [4, 6],
		"COOLDOWN": [6.5, 6.9],
	},
	YipTier.RARE: {
		"HP": [22, 30],
		"ATK": [7, 9],
		"COOLDOWN": [5, 6.4],
	},
	YipTier.ULTRARARE: {
		"HP": [31, 42],
		"ATK": [10, 14],
		"COOLDOWN": [4, 4.9],
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

# Each yip can only breed once per day; reset on day end
var bred_today : bool = false

# If the yip gets dragged off screen, we snap it back to its last known location
# I want them to run back to the old position if possible with a cute animation. We can slide them for now
# When the yip is spawned in the farm hub, set this variable, we will be spawning the yip in the safe areas.
var farm_last_known_position : Vector2 = Vector2.ZERO

# Remember party location between scenes if placed in a party
@export_range(0, 5, 1) var yip_party_slot : int 

# Remember party location between scenes if placed in a party
@export_range(0, 2, 1) var yip_barn_slot : int 
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
	return maxf(0.1, (base + flat_sum) * (1.0 + pct_sum))

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

## Breed two parents: best tier of either, averaged base stats, combined helix.
static func breed(parent_a: YipeeData, parent_b: YipeeData) -> YipeeData:
	var child := YipeeData.new()
	child.tier = maxi(parent_a.tier, parent_b.tier)
	child.base_health = roundi((parent_a.base_health + parent_b.base_health) / 2.0)
	child.base_attack = roundi((parent_a.base_attack + parent_b.base_attack) / 2.0)
	child.base_cooldown = (parent_a.base_cooldown + parent_b.base_cooldown) / 2.0
	child.age = 0
	child.helix = Helix.combine(parent_a.helix, parent_b.helix)
	child.yip_party_slot = 0
	child.yip_barn_slot = 0
	child.farm_last_known_position = Vector2.ZERO
	return child
