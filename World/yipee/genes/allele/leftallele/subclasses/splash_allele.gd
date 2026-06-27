class_name SplashAllele extends LeftAllele

@export var radius: int = 1
@export var falloff: float = 0.25

func on_hit(damage_data: DamageInfo, battle) -> void:
	var hit_yip: Yipee = damage_data.target
	if hit_yip == null:
		return
	var team: Array = battle.player_team if battle.player_team.has(hit_yip) else battle.enemy_team
	var index := team.find(hit_yip)
	if index == -1:
		return
	for offset in range(-radius, radius + 1):
		if offset == 0:
			continue
		var neighbour_index = index + offset
		if neighbour_index < 0 or neighbour_index >= team.size():
			continue
		var neighbour: Yipee = team[neighbour_index]
		if neighbour == null || !neighbour.health.is_alive():
			continue
		var splash = damage_data.scaled(effective_falloff())
		splash.target = neighbour
		battle.apply_damage(neighbour, splash)



func effective_falloff() -> float:
	return minf(falloff * tier, 1.0)

func _tooltip_subs() -> Dictionary:
	var subs := super()
	subs["falloff_pct"] = roundi(effective_falloff() * 100.0)
	subs["radius"] = radius
	return subs
