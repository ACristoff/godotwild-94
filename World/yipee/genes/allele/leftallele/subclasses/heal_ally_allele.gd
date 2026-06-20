class_name HealAllele extends LeftAllele

@export var heal_amount: int = 5

func effective_heal() -> int:
	return heal_amount * tier

func on_attack(damage_data: DamageInfo, battle) -> void:
	damage_data.amount = 0
	damage_data.type = DamageInfo.Type.HEAL
	var attacker := damage_data.source as Yipee
	var allies: Array = battle.player_team if battle.player_team.has(attacker) else battle.enemy_team
	var target := _lowest_health_ally(allies)
	if target == null:
		return
	target.health.heal(effective_heal())
	target.health_UI.current_health = target.health.current_health
	target.health_UI.update_UI()

func _lowest_health_ally(allies: Array) -> Yipee:
	var best: Yipee = null
	var best_missing := 0
	for ally: Yipee in allies:
		if not ally.health.is_alive():
			continue
		var missing := ally.health.max_health - ally.health.current_health
		if missing <= 0:
			continue  # already at full HP, skip
		if best == null or missing > best_missing:
			best = ally
			best_missing = missing
	return best

func _tooltip_subs() -> Dictionary:
	var subs := super()
	subs["heal"] = effective_heal()
	return subs
