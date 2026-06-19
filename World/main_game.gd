extends Node2D

@onready var child_scene = $StartCutscene

const location_dictionary = {
	SignalBus.Locations.FARM: preload("res://World/farm/farm_hub.tscn"),
	SignalBus.Locations.FIELD: '',
	SignalBus.Locations.LAB: '',
	SignalBus.Locations.BATTLE: '',
}

func change_location(location: SignalBus.Locations) -> void:
	
	child_scene.queue_free()
	
	pass

## Called when the node enters the scene tree for the first time.
func _ready():
	change_location(SignalBus.Locations.FARM)
	pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
