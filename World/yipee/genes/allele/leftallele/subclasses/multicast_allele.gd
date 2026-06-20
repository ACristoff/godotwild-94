class_name MulticastAllele extends LeftAllele

const RECAST_TAG := &"multicast"

@export var recast_delay: float = 0.1

func on_attack(damage_data: DamageInfo, battle) -> void:
	if damage_data.tags.has(RECAST_TAG):
		return
	_recast(damage_data.source as Yipee, battle)

func _recast(attacker: Yipee, battle) -> void:
	for i in tier:
		await battle.get_tree().create_timer(recast_delay / battle.battle_speed).timeout
		if battle._battle_over or not attacker.health.is_alive():
			return
		var recast := attacker.attack.make_damage()
		recast.tags.append(RECAST_TAG)
		attacker.attack.attack_ready.emit(recast)

func _tooltip_subs() -> Dictionary:
	var subs := super()
	subs["casts"] = tier
	return subs
