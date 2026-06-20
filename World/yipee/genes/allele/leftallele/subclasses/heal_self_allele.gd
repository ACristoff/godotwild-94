class_name SelfHealAllele extends LeftAllele

@export var heal_amount: int = 5

func effective_heal() -> int:
	return heal_amount * tier

func on_hit(damage_data: DamageInfo, battle) -> void:
	var attacker := damage_data.source as Yipee
	attacker.health.heal(effective_heal())
	attacker.health_UI.current_health = attacker.health.current_health
	attacker.health_UI.update_UI()

func _tooltip_subs() -> Dictionary:
	var subs := super()
	subs["heal"] = effective_heal()
	return subs
