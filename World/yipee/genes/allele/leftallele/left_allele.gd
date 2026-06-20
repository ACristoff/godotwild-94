class_name LeftAllele extends Allele

@export var flat_mods: Dictionary[BodyMap.Stat, int] = {}
@export var percent_mods: Dictionary[BodyMap.Stat, float] = {}

func _init():
	side = Allele.Side.LEFT

func get_tooltip() -> String:
	var subs := {}
	for stat in flat_mods:
		subs[BodyMap.Stat.keys()[stat].to_lower()] = flat_mods[stat] * tier
	for stat in percent_mods:
		subs[BodyMap.Stat.keys()[stat].to_lower() + "_pct"] = roundi(percent_mods[stat] * tier * 100.0)
	return tooltip.format(subs)

func flat_for(stat: BodyMap.Stat) -> float:
	return flat_mods.get(stat, 0) * tier

func percent_for(stat: BodyMap.Stat) -> float:
	return percent_mods.get(stat, 0.0) * tier
