extends Node

#Turn off unused signal warning in project to get rid of the dumb warnings
#I KNOW WHAT IM DOING GODOT HECK OFF
var permadeath: bool = false
var yip_inventory: Array[YipeeData] = []
var yip_party = {
	1: null,
	2: null,
	3: null,
	4: null,
	5: null
}
var coins: int = 6
enum Locations { FARM, FIELD, LAB, BATTLE }

#const areas = {
	#
#}

# Signal that will be triggered when game pauses
signal pause_game

# Signal that will be triggered when game pauses
signal game_state_changed(new_state)

signal debug_mode(debug_type)

signal transition_start

signal transition_finished

signal finish_transition

signal go_to(new_area: Locations)
