extends Node2D

@onready var child_scene = $StartCutscene

const location_dictionary = {
	SignalBus.Locations.FARM: '',
	SignalBus.Locations.FIELD: '',
	SignalBus.Locations.LAB: '',
	SignalBus.Locations.BATTLE: '',
}

func change_location() -> void:
	
	pass

## Called when the node enters the scene tree for the first time.
#func _ready():
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
