extends Control

var permadeath = false

func _ready() -> void:
	SignalBus.permadeath = permadeath

func _on_start_pressed():
	SignalBus.game_state_changed.emit("Start")

func _on_settings_pressed():
	SignalBus.game_state_changed.emit("Settings")

func _on_credits_pressed():
	SignalBus.game_state_changed.emit("Credits")

func _on_quit_pressed():
	SignalBus.game_state_changed.emit("Quit")

func _on_feedback_pressed() -> void:
	pass # Replace with function body.


func _on_button_pressed() -> void:
	if !permadeath:
		$AnimationPlayer.play("deathmode")
		permadeath = true
	else:
		$AnimationPlayer.play_backwards("deathmode")
		permadeath = false
	SignalBus.permadeath = permadeath
