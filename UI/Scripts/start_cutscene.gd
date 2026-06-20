extends Node2D

var hit_amnt = 0
var letteropened = false
# Called when the node enters the scene tree for the first time.

const LETTER_IMPACT = preload("uid://dxdi7wy5wcxmn")
const LETTER_OPEN = preload("uid://duikmvorwvx5")


func _on_button_pressed() -> void:
	match  hit_amnt:
		0:
			hit_amnt += 1
			$AnimationPlayer.play("Attempt1")
		1:
			hit_amnt += 1
			$AnimationPlayer.play("Attempt2")
		2:
			hit_amnt += 1
			#$AnimationPlayer.play("RESET")
			$Node2D.rotation_degrees = 0
			$AnimationPlayer.play("OpenLetter")
		3:
			return

func letter_hit():
	AudMan.play_sfx_wav(LETTER_IMPACT, 0.0, false)
func letter_open():
	AudMan.play_sfx_wav(LETTER_OPEN, 0.0, false)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "OpenLetter":
		letteropened = true
	if anim_name == "ByeByeLetter":
		Dialogic.start("Intro")


func _on_button_2_pressed() -> void:
	if hit_amnt == 3 and letteropened == true:
		$AnimationPlayer.play("ByeByeLetter")
