extends Control


func _on_start_pressed():
	SignalBus.game_state_changed.emit("Start")

func _on_settings_pressed():
	SignalBus.game_state_changed.emit("Settings")

func _on_credits_pressed():
	SignalBus.game_state_changed.emit("Credits")

func _on_quit_pressed():
	SignalBus.game_state_changed.emit("Quit")
