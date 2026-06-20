extends Node2D

@onready var child_scene = $StartCutscene

const location_dictionary = {
	SignalBus.Locations.FARM: preload("res://World/farm/farm_hub.tscn"),
	SignalBus.Locations.FIELD: preload("res://World/field/field.tscn"),
	SignalBus.Locations.LAB: preload("res://World/lab/lab.tscn"),
	SignalBus.Locations.BATTLE: preload("res://World/battle/battle.tscn"),
	SignalBus.Locations.WIN_LOSE: preload("res://UI/Scenes/win_lose_screen.tscn")
}

func change_location(location: SignalBus.Locations) -> void:
	print('going to new location', location)
	var new_location = location_dictionary[location].instantiate()
	add_child(new_location)
	child_scene.queue_free()
	child_scene = new_location

## Called when the node enters the scene tree for the first time.
func _ready():
	#change_location(SignalBus.Locations.FARM)
	SignalBus.go_to.connect(change_location)
	SignalBus.day_finished.connect(_on_day_end)
	#SignalBus.opening_scene_finished.connect(_on_opening_finished)
	Dialogic.signal_event.connect(_on_opening_finished)
	SignalBus.battle_finished.connect(_on_battle_finished)

func _on_battle_finished(victory: bool) -> void:
	change_location(SignalBus.Locations.WIN_LOSE)
	await get_tree().create_timer(2.0).timeout
	if victory == true:
		child_scene.won_match()
	else:
		child_scene.lost_match()


func _on_opening_finished(argument: String) -> void:
	if argument == "opening_finished":
		SignalBus.game_started = true
		change_location(SignalBus.Locations.FIELD)

func _on_day_end() -> void:
	SignalBus.coins += 6
	for yip in SignalBus.yip_inventory:
		yip.age += 1
	change_location(SignalBus.Locations.FARM)
