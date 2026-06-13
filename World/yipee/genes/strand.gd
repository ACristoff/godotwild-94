class_name Strand
extends Resource

@export var display_name: String = ""
@export var tooltip: String = ""

# Stat buffs/nerfs
func modify_stat(base_value: float, yipee_data) -> float:
	return base_value

func on_attack(damage_data: DamageInfo, battle) -> void:
	pass

func on_hit(damage_data: DamageInfo, battle) -> void:
	pass

func on_take_damage(damage_data: DamageInfo, battle) -> void:
	pass

func on_death(battle) -> void:
	pass

func on_breed() -> void:
	pass
