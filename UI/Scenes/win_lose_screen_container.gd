extends CanvasLayer

@onready var win_lose_screen: Control = $WinLoseScreen


func lost_match():
	win_lose_screen.lost_match()
	SignalBus.current_matches -= 1


func won_match():
	win_lose_screen.won_match()
	SignalBus.victories += 1
