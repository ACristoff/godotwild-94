class_name Strand
extends Resource

@export var display_name: String = ""

# Stat buffs/nerfs
func modify_stat(base_value: float, damage_data) -> float:
	return base_value

func _on_attack(damage_data: DamageInfo, battle):
	pass

func on_hit(damage_data: DamageInfo, battle):
	pass

func on_take_damage(damage_data: DamageInfo, battle):
	pass

func on_death(battle):
	pass

func on_breed():
	pass
