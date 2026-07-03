extends CanvasLayer

var sfx = 100.0
var music = 100.0
var all_sounds = 100.0
const UI_TICK_MINOR = preload("uid://beme2e24c1ser")

@export var in_main = false

func _ready() -> void:
	all_sounds = db_to_linear(AudioServer.get_bus_volume_db(0)) * 100
	music = db_to_linear(AudioServer.get_bus_volume_db(1)) * 100
	sfx = db_to_linear(AudioServer.get_bus_volume_db(2)) * 100

	$ButtonRefresh5/ButtonRefresh7/MarginContainer/VBoxContainer/HBoxContainer/Value/ASL.text = str(int(round(all_sounds)), "%")
	$ButtonRefresh5/ButtonRefresh7/MarginContainer/VBoxContainer/HBoxContainer/Value/ML.text = str(int(round(music)), "%")
	$ButtonRefresh5/ButtonRefresh7/MarginContainer/VBoxContainer/HBoxContainer/Value/SFXL.text = str(int(round(sfx)), "%")


func _exit_tree() -> void:
	get_tree().paused = false

func _on_asdn_pressed() -> void:
	if all_sounds <= 0:
		return
	else:
		all_sounds -= 10
		$ButtonRefresh5/ButtonRefresh7/MarginContainer/VBoxContainer/HBoxContainer/Value/ASL.text = str(int(all_sounds), "%")
		AudioServer.set_bus_volume_db(
			0, linear_to_db(all_sounds / 100)
		)
func _on_asup_pressed() -> void:
	if all_sounds >= 100:
		return
	else:
		all_sounds += 10
		$ButtonRefresh5/ButtonRefresh7/MarginContainer/VBoxContainer/HBoxContainer/Value/ASL.text = str(int(all_sounds), "%")
		AudioServer.set_bus_volume_db(
			0, linear_to_db(all_sounds / 100)
		)

func _on_sfxdn_pressed() -> void:
	if sfx <= 0:
		return
	else:
		sfx -= 10
		$ButtonRefresh5/ButtonRefresh7/MarginContainer/VBoxContainer/HBoxContainer/Value/SFXL.text = str(int(sfx), "%")
		AudioServer.set_bus_volume_db(
							2, linear_to_db(sfx / 100)
						)
func _on_sfxup_pressed() -> void:
	if sfx >= 100:
		return
	else:
		sfx += 10
		$ButtonRefresh5/ButtonRefresh7/MarginContainer/VBoxContainer/HBoxContainer/Value/SFXL.text = str(int(sfx), "%")
		AudioServer.set_bus_volume_db(
							2, linear_to_db(sfx / 100)
						)


func _on_main_menu_button_pressed() -> void:
	SignalBus.game_state_changed.emit("Main")


func _on_restart_button_pressed() -> void:
	pass # Replace with function body.


func _on_back_button_pressed() -> void:
	queue_free()


func _on_mup_pressed() -> void:
	if music >= 100:
		return
	else:
		music += 10
		$ButtonRefresh5/ButtonRefresh7/MarginContainer/VBoxContainer/HBoxContainer/Value/ML.text = str(int(music), "%")
		AudioServer.set_bus_volume_db(
					1, linear_to_db(music / 100)
				)


func _on_mdn_pressed() -> void:
	if music <= 0:
		return
	else:
		music -= 10
		$ButtonRefresh5/ButtonRefresh7/MarginContainer/VBoxContainer/HBoxContainer/Value/ML.text = str(int(music), "%")
		AudioServer.set_bus_volume_db(
					1, linear_to_db(music / 100)
				)
