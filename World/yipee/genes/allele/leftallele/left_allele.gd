class_name LeftAllele extends Allele

@export var flat_mods: Dictionary[BodyMap.Stat, int] = {}
@export var percent_mods: Dictionary[BodyMap.Stat, float] = {}

func _init():
	side = Allele.Side.LEFT

func flat_for(stat: BodyMap.Stat) -> float:
	return flat_mods.get(stat, 0) * tier

func percent_for(stat: BodyMap.Stat) -> float:
	return percent_mods.get(stat, 0.0) * tier
