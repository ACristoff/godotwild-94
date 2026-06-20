class_name FightOrganizer extends Node

@export var brackets: Array[Bracket] 

func get_next_fight() -> Level:
	var current_wins = SignalBus.victories
	var current_bracket = brackets[current_wins]
	var random_fight_num = randi_range(0, current_bracket.levels.size() - 1)
	var next_fight = current_bracket.levels[random_fight_num]
	
	return next_fight
