class_name FireAllele extends LeftAllele


#Does fire damage, applies fire status
func on_attack(damage_data: DamageInfo, battle) -> void:
	damage_data.type = DamageInfo.Type.FIRE
