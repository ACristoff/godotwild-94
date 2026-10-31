extends NinePatchRect


func _allele_show():
	$CooldownDamage.show()
	$CooldownDamage2.hide()
func _cooldown_show():
	$CooldownDamage2.show()
	$CooldownDamage.hide()
