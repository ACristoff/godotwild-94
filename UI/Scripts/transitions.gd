extends Control

signal transition_finished
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func game_to_black():
	$AnimationPlayer.play("Transition_Out")
	#emit_signal("transition_finished")
	
func black_to_game():
	$AnimationPlayer.play("Transition_In")
	#emit_signal("transition_finished")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Transition_Out" or "Transition_In":
		emit_signal("transition_finished")
