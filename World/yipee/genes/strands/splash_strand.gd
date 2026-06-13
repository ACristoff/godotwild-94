class_name SplashStrand extends Strand

@export var radius: int = 1
@export var falloff: float = 0.5

func on_hit(damage_data: DamageInfo, battle):
	for enemy in battle.enemies_near(damage_data.target.formation_position, radius):
		if enemy == damage_data.target:
			continue
		battle.apply_damage(enemy, damage_data.scaled(falloff))
