extends Control

const YIP_TROPHY_SHEEN = preload("uid://dau7hd7rch48p")
const YIP_GLASS_BREAK = preload("uid://bt20qh28pdhco")
const YIP_BATTLE_VICTORY = preload("uid://qxt87ungmeso")


func _ready():
	AudMan.stop_music()
	update_trophies()
	update_hearts()

func update_trophies():
	for i in range(1, 6):
		var trophy = get_node("VBoxContainer/Trophies/Trophy" + str(i))
		if i <= SignalBus.victories:
			trophy.modulate = Color.WHITE
		else:
			trophy.modulate = Color("313131")

func lost_match():
	update_hearts()
	AudMan.play_sfx_wav(YIP_GLASS_BREAK, 0.0, false)
	if SignalBus.current_health <= 0:
		lose_final()
	else:
		await get_tree().create_timer(1.0).timeout
		next_day()

func lose_final():
	if SignalBus.permadeath:
		$"../TerminationDeathMode".show()
	$"../AnimationPlayer".play("Death")
	
func won_match():
	update_trophies()
	AudMan.play_sfx_wav(YIP_TROPHY_SHEEN, 0.0, false)
	if SignalBus.victories >= 5:
		win_final()
	else:
		await get_tree().create_timer(1.0).timeout
		next_day()

func win_final():
	$"../PromotionLetter".show()
	$"../AnimationPlayer".play("Death")
	AudMan.play_sfx_wav(YIP_BATTLE_VICTORY, 0.0, false)
	
func next_day():
	SignalBus.day_finished.emit()

func update_hearts():
	for i in range(1, 4):
		var heart = get_node("VBoxContainer/Hearts/Heart" + str(i))
		if i <= SignalBus.current_health:
			heart.modulate = Color.WHITE
		else:
			heart.modulate = Color("313131")
