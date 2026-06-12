extends Label

func _ready() -> void:
	pass
	Engine.max_fps = 60

func _process(delta: float) -> void:
	text = ("FPS: ") + str(Engine.get_frames_per_second())
