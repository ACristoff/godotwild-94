class_name Allele
extends Resource

enum Side { LEFT, RIGHT }

@export var side: Allele.Side
@export var slot: Helix.Slot

@export var allele_name: String = ""
@export var tooltip: String = ""
@export var tier: int = 1

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

func on_take_damage(_damage_data: DamageInfo, _battle) -> void:
	pass

func on_death(_battle) -> void:
	pass
