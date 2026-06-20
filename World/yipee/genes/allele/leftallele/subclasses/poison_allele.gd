class_name PoisonAllele extends LeftAllele

@export var poison_stacks: int = 3

func effective_stacks() -> int:
	return poison_stacks * tier

func _tooltip_subs() -> Dictionary:
	var subs := super()
	subs["stacks"] = effective_stacks()
	return subs

func on_attack(damage_data: DamageInfo, battle) -> void:
	damage_data.type = DamageInfo.Type.POISON

func on_hit(damage_data: DamageInfo, battle) -> void:
	damage_data.target.status.apply(StatusEffects.Kind.POISON, effective_stacks())

func get_damage_pips() -> Dictionary:
	return { "POISON": effective_stacks() }
