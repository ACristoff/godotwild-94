class_name FireAllele extends LeftAllele


#Does fire damage, applies fire status
func on_attack(damage_data: DamageInfo, battle) -> void:
	damage_data.type = DamageInfo.Type.FIRE

func on_hit(damage_data: DamageInfo, battle) -> void:
	damage_data.target.status.apply(StatusEffects.Kind.BURN, 3)
