class_name FireAllele extends LeftAllele

@export var burn_stacks: int = 3

func on_attack(damage_data: DamageInfo, battle) -> void:
	damage_data.type = DamageInfo.Type.FIRE

func on_hit(damage_data: DamageInfo, battle) -> void:
	damage_data.target.status.apply(StatusEffects.Kind.BURN, burn_stacks)

func get_damage_pips() -> Dictionary:
	return { "FIRE": burn_stacks }
