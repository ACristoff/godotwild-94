class_name ChargeAllele extends LeftAllele

@export var charge_amount: float = 1.0

func effective_charge() -> float:
	return charge_amount * tier

func on_attack(damage_data: DamageInfo, battle) -> void:
	var owner := damage_data.source as Yipee
	var team: Array = battle.player_team if battle.player_team.has(owner) else battle.enemy_team
	var idx := team.find(owner)
	if idx == -1:
		return
	for offset: int in [-1, 1]:
		var i := idx + offset
		if i < 0 or i >= team.size():
			continue
		var ally: Yipee = team[i]
		if ally != null and ally.health.is_alive():
			ally.attack.charge(effective_charge())

func _tooltip_subs() -> Dictionary:
	var subs := super()
	subs["charge"] = effective_charge()
	return subs
