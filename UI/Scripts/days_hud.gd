extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MarginContainer3/MarginContainer2/HBoxContainer/WinsLabel.text = str(SignalBus.victories)
	$MarginContainer3/MarginContainer2/HBoxContainer/LivesLabel.text = str(SignalBus.current_health)
	$MarginContainer3/MarginContainer/DaysLabel.text = str("Day ",SignalBus.current_day)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
