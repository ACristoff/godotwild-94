extends Node2D

var hit_amnt = 0
var letteropened = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


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


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "OpenLetter":
		letteropened = true
	if anim_name == "ByeByeLetter":
		Dialogic.start("Intro")


func _on_button_2_pressed() -> void:
	if hit_amnt == 3 and letteropened == true:
		$AnimationPlayer.play("ByeByeLetter")
