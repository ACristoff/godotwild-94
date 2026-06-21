extends Control

func ready():
	match SignalBus.current_health:
		1:
			pass
		2:
			pass
		3:
			pass
	match SignalBus.current_wins:
		1:
			pass
		2:
			pass
		3:
			pass
		4:
			pass

func lost_match():
	var node = get_node("VBoxContainer/Hearts/Heart" + str(SignalBus.current_health))
	#node.set_slot(slot)
	SignalBus.current_health -= 1
	node.modulate = Color(0.194, 0.194, 0.194, 1.0)
	if SignalBus.current_health <= 0:
		lose_final()
	else:
		await get_tree().create_timer(5.0).timeout
		next_day()

func lose_final():
	pass
	
func won_match():
	var node = get_node("VBoxContainer/Trophies/Trophy" + str(SignalBus.current_wins))
	#node.set_slot(slot)
	SignalBus.current_wins += 1
	node.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if SignalBus.current_wins >= 6:
		win_final()
	else:
		await get_tree().create_timer(5.0).timeout
		next_day()

func win_final():
	pass
	
func next_day():
	SignalBus.day_finished.emit()
