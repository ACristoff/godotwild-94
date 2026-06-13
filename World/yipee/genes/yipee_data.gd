class_name YipeeData
extends Resource

## Yipee data resource, base stats + genes
## this is what gets saved, bred, and modified in the lab.
## final (derived) stats = base stat run through the strand in the matching slot.

@export var yipee_name: String = ""

@export_group("Base Stats")
@export var base_health: float = 10.0
@export var base_attack: float = 1.0
@export var base_cooldown: float = 3.0

@export var helix: Helix

func _init() -> void:
	if helix == null:
		helix = Helix.new()


func get_health() -> float:
	return _derived(base_health, Helix.Slot.HEALTH)
 
 
func get_attack() -> float:
	return _derived(base_attack, Helix.Slot.ATTACK)
 
 
func get_cooldown() -> float:
	return _derived(base_cooldown, Helix.Slot.COOLDOWN)
 
 
func _derived(base: float, slot: Helix.Slot) -> float:
	var strand := helix.get_strand(slot)
	return strand.modify_stat(base, self) if strand else base
 

func clone() -> YipeeData:
	return duplicate(true) as YipeeData
