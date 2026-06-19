extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
