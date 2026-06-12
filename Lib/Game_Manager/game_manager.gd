extends Node

class_name Game_Manager

##Game Manager:
##This node is not necessarily meant to be an autoload, but rather sit at the top of the node hierarchy
##Nodes get switched out as children of this node and this is where game-wide data is stored
##By default, you'd put the node configuration of what is meant to run on launch and have things loop back to main menu

@export var debug_mode: bool = false

@onready var menu_ui: CanvasLayer = $MenuUI

@onready var main_menu = preload("res://UI/Menus/Main_Menu/main_menu.tscn")
@onready var settings_menu
@onready var credits_menu
@onready var game

var subviewport_shader : Node

#@onready var current_menu = $Transitions/Splash

@onready var Menu_Scenes: Dictionary = {
	"Main": main_menu,
	"Start": 'NOT DONE YET BOZO',
	"Settings": 'NOT DONE YET BOZO',
	"Credits": 'NOT DONE YET BOZO',
	"Pause": 'NOT DONE YET BOZO',
	"Quit": 'Quit za gameo'
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.game_state_changed.connect(change_scene.bind())

func change_scene(new_state: String):
	if debug_mode == true:
		prints('scene changed', new_state, Menu_Scenes[new_state])
	if new_state == "Quit":
		get_tree().quit()
	if Menu_Scenes[new_state] is not String:
		var new_scene = Menu_Scenes[new_state].instantiate()
		menu_ui.add_child(new_scene)
	
