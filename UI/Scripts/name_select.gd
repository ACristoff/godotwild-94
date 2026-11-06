extends Control

var player_name : String = ""
var player_portrait : String = ""

func _on_button_pressed() -> void:
	player_name = $MarginContainer/TextEdit.text
	if !player_name.is_empty() and !player_portrait.is_empty():
		print($MarginContainer/TextEdit.text)
		SignalBus.game_state_changed.emit("Start")

func _on_man_pressed() -> void:
	player_portrait = "chud"
	$VBoxContainer/MarginContainer/HBoxContainer/TextureRect/Man/MarginContainer.show()
	$VBoxContainer/MarginContainer/HBoxContainer/TextureRect2/Woman/MarginContainer.hide()

func _on_woman_pressed() -> void:
	player_portrait = "chudette"
	$VBoxContainer/MarginContainer/HBoxContainer/TextureRect/Man/MarginContainer.hide()
	$VBoxContainer/MarginContainer/HBoxContainer/TextureRect2/Woman/MarginContainer.show()
