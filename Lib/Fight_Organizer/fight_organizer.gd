class_name FightOrganizer extends Node

@export var brackets: Array[Bracket] 

func is_player_fight_day() -> bool:
	return SignalBus.current_day % 2 == 0

func get_next_fight() -> Level:
	if is_player_fight_day():
		var player_fight := SnapshotStore.load_random_opponent(SignalBus.current_day - 1)
		if player_fight != null:
			return player_fight
	var current_wins = SignalBus.victories
	var current_bracket = brackets[current_wins]
	var random_fight_num = randi_range(0, current_bracket.levels.size() - 1)
	var next_fight = current_bracket.levels[random_fight_num]
	return next_fight
