class_name ShieldAllele extends LeftAllele

@export var shield_amount: int = 5

func effective_shield() -> int:
	return shield_amount * tier

func on_hit(damage_data: DamageInfo, battle) -> void:
	var attacker := damage_data.source as Yipee
	attacker.health.shield += effective_shield()
	attacker.health_UI.current_shield = attacker.health.shield
	attacker.health_UI.update_UI()

func _tooltip_subs() -> Dictionary:
	var subs := super()
	subs["shield"] = effective_shield()
	return subs
