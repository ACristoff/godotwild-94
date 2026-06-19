extends Control

var current_health = 3
var current_wins = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func lost_match():
	var node = get_node("VBoxContainer/Hearts/Heart" + str(current_health))
	#node.set_slot(slot)
	current_health -= 1
	node.modulate = Color(0.194, 0.194, 0.194, 1.0)
	if current_health <= 0:
		lose_final()
	else:
		next_day()
func lose_final():
	pass
	
func won_match():
	var node = get_node("VBoxContainer/Trophies/Trophy" + str(current_wins))
	#node.set_slot(slot)
	current_wins += 1
	node.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if current_wins >= 6:
		win_final()
	else:
		next_day()
func win_final():
	pass
	
func next_day():
	pass
