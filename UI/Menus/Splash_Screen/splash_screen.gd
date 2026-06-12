extends Control

@onready var drumsfx = preload("res://UI/Menus/Splash_Screen/Sfx/bp_cadence.mp3")
@onready var bereparedosfx = [
	preload("res://UI/Menus/Splash_Screen/Sfx/b01.wav"),
	preload("res://UI/Menus/Splash_Screen/Sfx/b02.wav"),
	preload("res://UI/Menus/Splash_Screen/Sfx/b03.wav"),
	preload("res://UI/Menus/Splash_Screen/Sfx/b04.wav"),
	preload("res://UI/Menus/Splash_Screen/Sfx/b05.wav"),
	preload("res://UI/Menus/Splash_Screen/Sfx/b06.wav"),
	preload("res://UI/Menus/Splash_Screen/Sfx/b07.wav"),
	preload("res://UI/Menus/Splash_Screen/Sfx/b08.wav"),
	preload("res://UI/Menus/Splash_Screen/Sfx/b09.wav"),
]

func _play_splash_sfx():
	AudMan.play_sfx(drumsfx)

func _play_beretchan_sfx():
	var _random = randi_range(0,bereparedosfx.size() - 1)
	AudMan.play_sfx_wav(bereparedosfx[_random], 1)

func call_menu():
	SignalBus.game_state_changed.emit("Main")

func _on_splash_anim_animation_finished(anim_name):
	if anim_name == 'splash':
		queue_free()
