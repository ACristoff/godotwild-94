class_name ChargeFrontAllele extends LeftAllele

@export var charge_amount: float = 1.0

func effective_charge() -> float:
	return charge_amount * tier

func on_attack(damage_data: DamageInfo, battle) -> void:
	var owner := damage_data.source as Yipee
	var team: Array = battle.player_team if battle.player_team.has(owner) else battle.enemy_team
	var idx := team.find(owner)
	if idx <= 0:
		return
	var ally: Yipee = team[idx - 1]
	if ally != null and ally.health.is_alive():
		ally.attack.charge(effective_charge())

func _tooltip_subs() -> Dictionary:
	var subs := super()
	subs["charge"] = effective_charge()
	return subs
