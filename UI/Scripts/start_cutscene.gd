extends Node2D

var hit_amnt = 0
var letteropened = false
var yip_tut = 0
# Called when the node enters the scene tree for the first time.

const LETTER_IMPACT = preload("uid://dxdi7wy5wcxmn")
const LETTER_OPEN = preload("uid://duikmvorwvx5")

func _ready() -> void:
	Dialogic.signal_event.connect(bye_pointy)

func bye_pointy(arg):
	if arg == "baeappears":
		$Baesyip.hide()

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
		4:
			return

func letter_hit():
	AudMan.play_sfx_wav(LETTER_IMPACT, 0.0, false)
func letter_open():
	AudMan.play_sfx_wav(LETTER_OPEN, 0.0, false)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "OpenLetter":
		letteropened = true
	if anim_name == "ByeByeLetter":
		$TutorialBox.show()


func _on_button_2_pressed() -> void:
	if hit_amnt == 3 and letteropened == true:
		$AnimationPlayer.play("ByeByeLetter")
		hit_amnt = 4


func _on_tutorial_box_next() -> void:
	$TutorialBox.hide()
	$TutorialBox2.show()

func _on_tutorial_box_2_next() -> void:
	$TutorialBox2.hide()
	$TutorialBox4.show()

func _on_tutorial_box_4_next() -> void:
	$TutorialBox4.hide()
	$TutorialBox5.show()

func _on_tutorial_box_5_next() -> void:
	$TutorialBox5.hide()
	$TutorialBox6.show()

func _on_tutorial_box_6_next() -> void:
	$TutorialBox6.hide()
	$TutorialBox7.show()

func _on_tutorial_box_7_next() -> void:
	$TutorialBox7.hide()
	$TutorialBox8.show()

func _on_tutorial_box_8_next() -> void:
	$TutorialBox8.hide()
	$TutorialBox9.show()

func _on_tutorial_box_9_next() -> void:
	$TutorialBox9.hide()
	$TutorialBox10.show()

func _on_tutorial_box_10_next() -> void:
	$TutorialBox10.hide()
	Dialogic.start("Intro")
	

#DEBUG
	
