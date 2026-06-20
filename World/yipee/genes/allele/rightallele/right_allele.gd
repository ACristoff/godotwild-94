class_name RightAllele extends Allele

@export var body_part: Texture2D
@export var body_target: BodyMap.Part = BodyMap.Part.NONE
@export var yip_color: Color = Color.WHITE
@export var set_id: StringName
@export var buff: float = 0.0

func _init():
	side = Allele.Side.RIGHT

#small passive buff for this slot's stat
func modify_stat(base_value: float, _yipee_data) -> float:
	match BodyMap.SLOT_BUFF.get(slot, BodyMap.BuffMode.NONE):
		BodyMap.BuffMode.FLAT:
			return base_value + buff * tier
		BodyMap.BuffMode.PERCENT:
			return base_value * (1.0 + buff * tier)
		_:
			return base_value

func flat_for(stat: BodyMap.Stat) -> float:
	if BodyMap.STAT_SLOTS[stat].has(slot) and BodyMap.SLOT_BUFF.get(slot, BodyMap.BuffMode.NONE) == BodyMap.BuffMode.FLAT:
		return buff * tier
	return 0.0

func percent_for(stat: BodyMap.Stat) -> float:
	if BodyMap.STAT_SLOTS[stat].has(slot) and BodyMap.SLOT_BUFF.get(slot, BodyMap.BuffMode.NONE) == BodyMap.BuffMode.PERCENT:
		return buff * tier
	return 0.0
