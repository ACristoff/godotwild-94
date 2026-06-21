extends Control

signal transition_finished
signal screen_covered
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#SignalBus.go_to
	pass



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
		queue_free()

func over_whole():
	emit_signal("screen_covered")
