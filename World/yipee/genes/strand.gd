class_name Strand extends Resource

@export var slot: Helix.Slot
@export var left: LeftAllele
@export var right: RightAllele

func modify_stat(base_value: float, yipee_data) -> float:
	var result := base_value
	if left:
		result = left.modify_stat(result, yipee_data)
	if right:
		result = right.modify_stat(result, yipee_data)
	return result

func get_body_part() -> Texture2D:
	if right == null:
		return null
	return right.body_part

func split() -> Array[Allele]:
	return [left, right]

static func combine(new_left: LeftAllele, new_right: RightAllele) -> Strand:
	if new_left == null or new_right == null:
		return null
	if new_left.slot != new_right.slot:
		return null
	var strand := Strand.new()
	strand.left = new_left
	strand.right = new_right
	strand.slot = new_left.slot
	return strand
