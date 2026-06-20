extends Node2D
var yip_placed = true



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_screen()

func update_screen():
	pass
	if yip_placed:
		$Control/SubViewportContainer/SubViewport/DNATestScreen.show()
		$Control/SubViewportContainer/SubViewport/Cyanspeenspritesheet.hide()
		$Arrow.hide()
		$PlaceYip.hide()
		$NoConnectionFound.modulate = Color(0.0, 0.0, 0.0, 0.0)
	else:
		$Control/SubViewportContainer/SubViewport/DNATestScreen.hide()
		$Control/SubViewportContainer/SubViewport/Cyanspeenspritesheet.show()
		$Arrow.show()
		$PlaceYip.show()
		$NoConnectionFound.modulate = Color(1.0, 1.0, 1.0, 1.0)
