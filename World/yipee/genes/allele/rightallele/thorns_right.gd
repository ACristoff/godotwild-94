class_name ThornsRight extends RightAllele

@export var reflect_amount: int = 2

func on_take_damage(damage_data: DamageInfo, battle) -> void:
	var attacker = damage_data.source
	if attacker == null:
		return
	var thorn := DamageInfo.new()
	thorn.amount = reflect_amount * tier
	thorn.type = DamageInfo.Type.PHYSICAL
	thorn.source = damage_data.target
	thorn.target = attacker
	battle.apply_damage(attacker, thorn)
