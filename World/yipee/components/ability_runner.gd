class_name AbilityRunner extends Node

var helix: Helix

func setup(yipee_helix: Helix) -> void:
	helix = yipee_helix

#Daily life triggers
func on_day_start() -> void:
	if helix == null:
		return
	for strand: Strand in helix.strands:
		if strand:
			strand.on_day_start()

func on_breed() -> void:
	if helix == null:
		return
	for strand: Strand in helix.strands:
		if strand:
			strand.on_breed()

# Combat triggers
func on_attack(damage_data: DamageInfo, battle) -> void:
	if helix == null:
		return
	for strand: Strand in helix.strands:
		if strand:
			strand.on_attack(damage_data, battle)

func on_battle_start() -> void:
	if helix == null:
		return
	for strand: Strand in helix.strands:
		if strand:
			strand.on_battle_start()

func on_adjacent_ally_attack() -> void:
	if helix == null:
		return
	for strand: Strand in helix.strands:
		if strand:
			strand.on_adjacent_ally_attack()

func on_ally_take_damage() -> void:
	if helix == null:
		return
	for strand: Strand in helix.strands:
		if strand:
			strand.on_ally_take_damage()

func on_status_gained() -> void:
	if helix == null:
		return
	for strand: Strand in helix.strands:
		if strand:
			strand.on_status_gained()

func on_hit(damage_data: DamageInfo, battle) -> void:
	if helix == null:
		return
	for strand: Strand in helix.strands:
		if strand:
			strand.on_hit(damage_data, battle)

func on_take_damage(damage_data: DamageInfo, battle) -> void:
	if helix == null:
		return
	for strand: Strand in helix.strands:
		if strand:
			strand.on_take_damage(damage_data, battle)

func on_death(battle) -> void:
	if helix == null:
		return
	for strand: Strand in helix.strands:
		if strand:
			strand.on_death(battle)
