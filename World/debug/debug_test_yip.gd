extends Node

func _ready() -> void:
	#var data := YipeeData.new()      # base_health = 10
#
	## flat +2 health cosmetic for the HEALTH slot
	#var flat := RightAllele.new()
	#flat.slot = Helix.Slot.HEALTH
	#flat.buff = 2.0
#
	## +10% health cosmetic for the HEALTH_AUGMENT slot
	#var pct := RightAllele.new()
	#pct.slot = Helix.Slot.HEALTH_AUGMENT
	#pct.buff = 0.1
#
	## wrap each in a strand (left can stay empty — modify_stat null-guards it)
	#var s1 := Strand.new()
	#s1.slot = Helix.Slot.HEALTH
	#s1.right = flat
#
	#var s2 := Strand.new()
	#s2.slot = Helix.Slot.HEALTH_AUGMENT
	#s2.right = pct
#
	#data.helix.set_strand(Helix.Slot.HEALTH, s1)
	#data.helix.set_strand(Helix.Slot.HEALTH_AUGMENT, s2)
#
	#print("health = ", data.get_health())   # expect (10 + 2) * 1.1 = 13.2
	#var new_yip: YipeeData = YipeeData.generate_yip(YipeeData.YipTier.COMMON)
	#prints(new_yip,"age", new_yip.age, "attack", new_yip.base_attack, "health", new_yip.base_health, new_yip.base_cooldown)
	#var new_yip2: YipeeData = YipeeData.generate_yip(YipeeData.YipTier.COMMON)
	#prints(new_yip2,"age", new_yip2.age, "attack", new_yip2.base_attack, "health", new_yip2.base_health, new_yip2.base_cooldown)
	
	pass
