extends "res://UI/Scripts/battle_clash.gd"

const DEFAULT_NAME := "ANON"
const DEFAULT_PORTRAIT := preload("res://UI/Menus/Main_Menu/Textures/Anon.png")
const PORTRAITS := {
	"chud": preload("res://UI/Menus/Main_Menu/Textures/Anon.png"),
	"chudette": preload("res://UI/Menus/Main_Menu/Textures/AnonGirl.png"),
}

func setup(level: Level) -> void:
	$AnonWall/AnonLabel.text = _display_name(SignalBus.player_name)
	$AnonWall/Anon.texture = _portrait_for(SignalBus.player_portrait)
	$EnemyWall/EnemyLabel.text = _display_name(level.level_name)
	$EnemyWall/Drinsaneomode.texture = _portrait_for(level.opponent_portrait)

func _display_name(player_name: String) -> String:
	var trimmed_name := player_name.strip_edges()
	if trimmed_name.is_empty():
		return DEFAULT_NAME
	return trimmed_name

func _portrait_for(portrait_key: String) -> Texture2D:
	return PORTRAITS.get(portrait_key, DEFAULT_PORTRAIT)
