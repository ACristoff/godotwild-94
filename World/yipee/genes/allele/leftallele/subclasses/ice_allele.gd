class_name IceAllele extends LeftAllele

@export var ice_stacks: int = 3

func effective_stacks() -> int:
	return ice_stacks * tier

func _tooltip_subs() -> Dictionary:
	var subs := super()
	subs["stacks"] = effective_stacks()
	return subs

func on_attack(damage_data: DamageInfo, battle) -> void:
	damage_data.type = DamageInfo.Type.ICE

func on_hit(damage_data: DamageInfo, battle) -> void:
	damage_data.target.status.apply(StatusEffects.Kind.ICE, effective_stacks())

func get_damage_pips() -> Dictionary:
	return { "ICE": effective_stacks() }
