extends CanvasLayer

const YIP_VS_BONK = preload("uid://cgj1x1lw7b77j")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match SignalBus.player_portrait:
		"chud":
			$AnonWall/Anon.texture = load("res://UI/Menus/Main_Menu/Textures/Anon.png")
		"chudette":
			$AnonWall/Anon.texture = load("res://UI/Menus/Main_Menu/Textures/AnonGirl.png")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func play_sound():
	AudMan.play_sfx_wav(YIP_VS_BONK, 0.0, false)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
