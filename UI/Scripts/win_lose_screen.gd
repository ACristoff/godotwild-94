extends Control

const YIP_TROPHY_SHEEN = preload("uid://dau7hd7rch48p")
const YIP_GLASS_BREAK = preload("uid://bt20qh28pdhco")


func _ready():
	
	match SignalBus.current_wins:
		1:
			$VBoxContainer/Trophies/Trophy1.modulate = Color(1.0, 1.0, 1.0, 1.0)
		2:
			$VBoxContainer/Trophies/Trophy1.modulate = Color(1.0, 1.0, 1.0, 1.0)
			$VBoxContainer/Trophies/Trophy2.modulate = Color(1.0, 1.0, 1.0, 1.0)
		3:
			$VBoxContainer/Trophies/Trophy1.modulate = Color(1.0, 1.0, 1.0, 1.0)
			$VBoxContainer/Trophies/Trophy2.modulate = Color(1.0, 1.0, 1.0, 1.0)
			$VBoxContainer/Trophies/Trophy3.modulate = Color(1.0, 1.0, 1.0, 1.0)
		4:
			$VBoxContainer/Trophies/Trophy1.modulate = Color(1.0, 1.0, 1.0, 1.0)
			$VBoxContainer/Trophies/Trophy2.modulate = Color(1.0, 1.0, 1.0, 1.0)
			$VBoxContainer/Trophies/Trophy3.modulate = Color(1.0, 1.0, 1.0, 1.0)
			$VBoxContainer/Trophies/Trophy4.modulate = Color(1.0, 1.0, 1.0, 1.0)
		5:
			$VBoxContainer/Trophies/Trophy1.modulate = Color(1.0, 1.0, 1.0, 1.0)
			$VBoxContainer/Trophies/Trophy2.modulate = Color(1.0, 1.0, 1.0, 1.0)
			$VBoxContainer/Trophies/Trophy3.modulate = Color(1.0, 1.0, 1.0, 1.0)
			$VBoxContainer/Trophies/Trophy4.modulate = Color(1.0, 1.0, 1.0, 1.0)
			$VBoxContainer/Trophies/Trophy5.modulate = Color(1.0, 1.0, 1.0, 1.0)
	update_hearts()

func lost_match():
	#var node = get_node("VBoxContainer/Hearts/Heart" + str(SignalBus.current_health))
	#node.set_slot(slot)
	#SignalBus.current_health -= 1
	update_hearts()
	AudMan.play_sfx_wav(YIP_GLASS_BREAK, 0.0, false)
	if SignalBus.current_health <= 0:
		lose_final()
	else:
		await get_tree().create_timer(1.0).timeout
		next_day()

func lose_final():
	pass
	
func won_match():
	SignalBus.current_wins += 1
	var node = get_node("VBoxContainer/Trophies/Trophy" + str(SignalBus.current_wins))
	#node.set_slot(slot)
	node.modulate = Color(1.0, 1.0, 1.0, 1.0)
	AudMan.play_sfx_wav(YIP_TROPHY_SHEEN, 0.0, false)
	if SignalBus.current_wins >= 6:
		win_final()
	else:
		await get_tree().create_timer(1.0).timeout
		next_day()

func win_final():
	pass
	
func next_day():
	SignalBus.day_finished.emit()

func update_hearts():
	for i in range(1, 4):
		var heart = get_node("VBoxContainer/Hearts/Heart" + str(i))
		if i <= SignalBus.current_health:
			heart.modulate = Color.WHITE
		else:
			heart.modulate = Color("313131")
