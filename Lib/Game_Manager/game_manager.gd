extends Node

class_name Game_Manager

#Game Manager:
#This node is not necessarily meant to be an autoload, but rather sit at the top of the node hierarchy
#Nodes get switched out as children of this node and this is where game-wide data is stored
#By default, you'd put the node configuration of what is meant to run on launch and have things loop back to main menu

@export var debug_mode: bool = false

@onready var menu_ui: CanvasLayer = $MenuUI

@onready var main_menu = preload("res://UI/Menus/Main_Menu/main_menu.tscn")
@onready var settings_menu
@onready var credits_menu
#@onready var load_save_menu = preload("res://UI/Menus/LoadSave/load_save.tscn")
@onready var game = preload("res://World/main_game.tscn")

#@onready var current_menu = $Transitions/Splash

var current_scene = null

@onready var Menu_Scenes: Dictionary = {
	"Main": main_menu,
	"Start": game,
	"Settings": 'NOT DONE YET BOZO',
	"Credits": 'NOT DONE YET BOZO',
	"Pause": 'NOT DONE YET BOZO',
	"Quit": 'Quit za gameo'
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.game_state_changed.connect(change_scene.bind())
	print(Engine.get_version_info())
	if debug_mode == true:
		$Transitions/Splash.queue_free()
		SignalBus.game_state_changed.emit("Main")
		SignalBus.game_started = true


func change_scene(new_state: String):
	if debug_mode == true:
		prints('top level scene changed', new_state, Menu_Scenes[new_state])
	if new_state == "Start":
		menu_ui.queue_free()
		var new_scene = Menu_Scenes[new_state].instantiate()
		add_child(new_scene)
		current_scene = new_scene
		return OK
	if new_state == "Main":
		_clear_menu_ui()
		var new_scene = Menu_Scenes[new_state].instantiate()
		$MenuUI.add_child(new_scene)
		current_scene = new_scene
		return OK
	if new_state == "Quit":
		get_tree().quit()
	if Menu_Scenes[new_state] is not String:
		var new_scene = Menu_Scenes[new_state].instantiate()
		menu_ui.add_child(new_scene)

func _clear_menu_ui() -> void:
	for child in $MenuUI.get_children():
		child.queue_free()
