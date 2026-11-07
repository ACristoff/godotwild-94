class_name FightOrganizer extends Node

@export var brackets: Array[Bracket] 
@export var player_clash_scene: PackedScene
@export var choice_scenes: Array[PackedScene]

var current_fight: Level
var current_fight_is_npc: bool = false

func is_player_fight_day() -> bool:
	return SignalBus.current_day % 2 == 0

func choose_next_fight() -> Level:
	if is_player_fight_day():
		var player_fight := SnapshotStore.load_random_opponent(SignalBus.current_day - 1)
		if player_fight != null:
			player_fight.intro_animation = player_clash_scene
			return _set_current_fight(player_fight, false)
		var fallback_index := clampi(SignalBus.npc_fights_done - 1, 0, brackets.size() - 1)
		return _set_current_fight(_random_fight(brackets[fallback_index]), false)
	var bracket_index := mini(SignalBus.npc_fights_done, brackets.size() - 1)
	if bracket_index < choice_scenes.size() and choice_scenes[bracket_index] != null:
		var chosen_fight: Level = await _show_fight_choice(choice_scenes[bracket_index])
		return _set_current_fight(chosen_fight, true)
	return _set_current_fight(_random_fight(brackets[bracket_index]), true)

func finish_fight(victory: bool) -> void:
	if current_fight == null:
		return
	if current_fight_is_npc:
		SignalBus.npc_fights_done += 1
	if victory:
		_grant_rewards(current_fight)
		if current_fight.is_final_boss:
			SignalBus.final_boss_defeated = true
	current_fight = null

func _show_fight_choice(choice_scene: PackedScene) -> Level:
	var choice := choice_scene.instantiate()
	add_child(choice)
	var chosen_fight: Level = await choice.fight_chosen
	choice.queue_free()
	return chosen_fight

func _random_fight(bracket: Bracket) -> Level:
	return bracket.levels.pick_random()

func _set_current_fight(level: Level, is_npc: bool) -> Level:
	current_fight = level
	current_fight_is_npc = is_npc
	return level

func _grant_rewards(level: Level) -> void:
	SignalBus.coins += level.reward_coins
	for slot in level.reward_goop:
		var goop_key = BodyMap.Slot.find_key(slot)
		if SignalBus.goop_inventory.has(goop_key):
			SignalBus.goop_inventory[goop_key] += level.reward_goop[slot]
