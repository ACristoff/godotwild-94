class_name YipeeData
extends Resource

## Yipee data resource, base stats + genes
## this is what gets saved, bred, and modified in the lab.
## final (derived) stats = base stat run through the strand in the matching slot.

@export var yipee_name: String = ""

@export_group("Base Stats")
@export var base_health: int = 10
@export var base_attack: int = 1
@export var base_cooldown: float = 3.0

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
