class_name Strand extends Resource

@export var slot: BodyMap.Slot
@export var left: LeftAllele
@export var right: RightAllele

func modify_stat(base_value: float, yipee_data) -> float:
	var result := base_value
	if left:
		result = left.modify_stat(result, yipee_data)
	if right:
		result = right.modify_stat(result, yipee_data)
	return result

#Daily life triggers
func on_day_start() -> void:
	if left:
		left.on_day_start()
	if right:
		right.on_day_start()

func on_breed() -> void:
	if left:
		left.on_breed()
	if right:
		right.on_breed()

# Combat triggers
func on_battle_start() -> void:
	if left:
		left.on_battle_start()
	if right:
		right.on_battle_start()

func on_adjacent_ally_attack() -> void:
	if left:
		left.on_adjacent_ally_attack()
	if right:
		right.on_adjacent_ally_attack()

func on_ally_take_damage() -> void:
	if left:
		left.on_ally_take_damage()
	if right:
		right.on_ally_take_damage()

func on_status_gained() -> void:
	if left:
		left.on_status_gained()
	if right:
		right.on_status_gained()

func on_attack(damage_data: DamageInfo, battle) -> void:
	if left:
		left.on_attack(damage_data, battle)
	if right:
		right.on_attack(damage_data, battle)

func on_hit(_damage_data: DamageInfo, _battle) -> void:
	if left:
		left.on_hit(_damage_data, _battle)
	if right:
		right.on_hit(_damage_data, _battle)

func on_take_damage(_damage_data: DamageInfo, _battle) -> void:
	if left:
		left.on_take_damage(_damage_data, _battle)
	if right:
		right.on_take_damage(_damage_data, _battle)

func on_death(_battle) -> void:
	if left:
		left.on_death(_battle)
	if right:
		right.on_death(_battle)

func get_body_part() -> Texture2D:
	if right == null:
		return null
	return right.body_part

func split() -> Array[Allele]:
	var out: Array[Allele] = []
	if left:
		out.append(left)
	if right:
		out.append(right)
	return out

static func combine(new_left: LeftAllele, new_right: RightAllele) -> Strand:
	if new_left == null and new_right == null:
		return null
	if new_left != null and new_right != null and new_left.slot != new_right.slot:
		return null
	var strand := Strand.new()
	strand.left = new_left
	strand.right = new_right
	strand.slot = new_left.slot if new_left != null else new_right.slot
	return strand
