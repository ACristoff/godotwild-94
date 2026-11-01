extends NinePatchRect


func _cooldown_show():
	$AlleleInformation.show()
	$CooldownInformation.hide()

func _allele_show():
	$CooldownInformation.show()
	$AlleleInformation.hide()
