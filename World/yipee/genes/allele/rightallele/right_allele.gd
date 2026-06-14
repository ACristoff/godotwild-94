class_name RightAllele extends Allele

@export var body_part: Texture2D
@export var set_id: StringName

func _init():
	side = Allele.Side.RIGHT

#small modify value type shit
func modify_stat(base_value: float, yipee_data) -> float:
	return base_value
