extends CanvasLayer

@onready var win_lose_screen: Control = $WinLoseScreen


func lost_match():
	win_lose_screen.lost_match()


func won_match():
	win_lose_screen.won_match()
