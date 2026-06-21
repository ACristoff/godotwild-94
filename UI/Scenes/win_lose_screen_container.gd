extends CanvasLayer

@onready var win_lose_screen: Control = $WinLoseScreen


func lost_match():
	SignalBus.current_health -= 1
	win_lose_screen.lost_match()


func won_match():
	SignalBus.victories += 1
	win_lose_screen.won_match()



func _on_main_menu_button_pressed() -> void:
	SignalBus.game_state_changed.emit("Main")
