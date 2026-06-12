extends SubViewportContainer

func _ready():
	GameManager.subviewport_shader = self
	position = position.round()
