extends CanvasLayer

signal fight_chosen(level: Level)

const CARD_PATH := "MarginContainer/HBoxContainer/Challenger%d/VBoxContainer"

@export var fights: Array[Level]

var _buttons: Array[Button] = []

func _ready() -> void:
	for index in fights.size():
		var fight := fights[index]
		if fight == null:
			continue
		var card := get_node(CARD_PATH % (index + 1))
		var button: Button = card.get_node("TrainerPortrait/Button")
		button.pressed.connect(_on_card_pressed.bind(index))
		_buttons.append(button)
		card.get_node("MarginContainer2/HBoxContainer/CoinsLabel").text = "%d coins" % fight.reward_coins
		card.get_node("MarginContainer3/HBoxContainer/AlleleLabel").text = _goop_text(fight)
		card.get_node("MarginContainer3").visible = not fight.reward_goop.is_empty()

func _goop_text(fight: Level) -> String:
	var lines: PackedStringArray = []
	for slot in fight.reward_goop:
		lines.append("%d %s Goop" % [fight.reward_goop[slot], Toolyip.SLOT_KEYS[slot]])
	return "\n".join(lines)

func _on_card_pressed(index: int) -> void:
	for button in _buttons:
		button.disabled = true
	fight_chosen.emit(fights[index])
