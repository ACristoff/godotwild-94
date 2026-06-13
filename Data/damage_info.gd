class_name DamageInfo
extends RefCounted

#To be honest I'm not sure how many types and effects we'll support, this is a constraint thing
enum Type { PHYSICAL, FIRE, POISON, ICE, PIERCE, LIFESTEAL }

#Defaults to 0 damage
var amount: float = 0.0
#Defaults to physical damage
var type: Type = Type.PHYSICAL
var source: Node2D
var target: Node2D
#Any additional tags, types, effects etc.
var tags: Array[StringName] = []

#This would be for splash damage
func scaled(factor: float) -> DamageInfo:
	var copy := DamageInfo.new()
	copy.amount = amount * factor
	copy.type = type
	copy.source = source
	copy.target = target
	copy.tags = tags.duplicate()
	return copy
