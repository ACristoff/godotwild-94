class_name FireAllele extends LeftAllele

@export var burn_stacks: int = 3

func effective_stacks() -> int:
	return burn_stacks * tier

func _tooltip_subs() -> Dictionary:
	var subs := super()
	subs["stacks"] = effective_stacks()
	return subs

func on_attack(damage_data: DamageInfo, battle) -> void:
	damage_data.type = DamageInfo.Type.FIRE

func on_hit(damage_data: DamageInfo, battle) -> void:
	damage_data.target.status.apply(StatusEffects.Kind.BURN, effective_stacks())

func get_damage_pips() -> Dictionary:
	return { "FIRE": effective_stacks() }
