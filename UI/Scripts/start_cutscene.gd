extends Node2D

var hit_amnt = 0
var letteropened = false
var yip_tut = 0
var field_level = 2
var base_slot_chance = 25
var base_yip_tier_chance = 25
var spawn_pos : Marker2D
var spawned_num : int = 1
var yips_to_spawn : int = 3

var yip_tier_odds_0: Dictionary = {
	YipeeData.YipTier.COMMON: 95,
	YipeeData.YipTier.UNCOMMON: 4,
	YipeeData.YipTier.RARE: 1,
	YipeeData.YipTier.ULTRARARE: 0
}

var yip_tier_odds_1: Dictionary = {
	YipeeData.YipTier.COMMON: 60,
	YipeeData.YipTier.UNCOMMON: 25,
	YipeeData.YipTier.RARE: 10,
	YipeeData.YipTier.ULTRARARE: 5
}

var yip_tier_odds_2: Dictionary = {
	YipeeData.YipTier.COMMON: 10,
	YipeeData.YipTier.UNCOMMON: 40,
	YipeeData.YipTier.RARE: 40,
	YipeeData.YipTier.ULTRARARE: 10
}

var yip_tier_odds_3: Dictionary = {
	YipeeData.YipTier.COMMON: 0,
	YipeeData.YipTier.UNCOMMON: 30,
	YipeeData.YipTier.RARE: 50,
	YipeeData.YipTier.ULTRARARE: 20
}

var yip_tier_dictionaries = [
	yip_tier_odds_0,
	yip_tier_odds_1,
	yip_tier_odds_2,
	yip_tier_odds_3
]

var allele_fill_chance_by_tier = {
	YipeeData.YipTier.COMMON: 25,
	YipeeData.YipTier.UNCOMMON: 50,
	YipeeData.YipTier.RARE: 55,
	YipeeData.YipTier.ULTRARARE: 90
}

var yip_costs = {
	YipeeData.YipTier.COMMON: 3,
	YipeeData.YipTier.UNCOMMON: 4,
	YipeeData.YipTier.RARE: 5,
	YipeeData.YipTier.ULTRARARE: 6
}
var all_yips:  Array[Yipee] = []

var focused_yip: Yipee = null

var resserved_spots : Array[Vector2] = []
@onready var tooltip: Toolyip = $CanvasLayer/MouseHover
# Called when the node enters the scene tree for the first time.

const LETTER_IMPACT = preload("uid://dxdi7wy5wcxmn")
const LETTER_OPEN = preload("uid://duikmvorwvx5")

func _ready() -> void:
	AudMan.play_music(preload("res://Assets/Audio/Music/Learning the Ropes.mp3"))
	$Lab/WorldEnvironment.environment = null
	Dialogic.signal_event.connect(bye_pointy)
	tooltip.hide()

func bye_pointy(arg):
	if arg == "baeappears":
		$Baesyip.hide()
	if arg == "drlogic_finished":
		generate_field_stock()
		spawn_field_stock()

func _on_button_pressed() -> void:
	match  hit_amnt:
		0:
			hit_amnt += 1
			$AnimationPlayer.play("Attempt1")
		1:
			hit_amnt += 1
			$AnimationPlayer.play("Attempt2")
		2:
			hit_amnt += 1
			#$AnimationPlayer.play("RESET")
			$Node2D.rotation_degrees = 0
			$AnimationPlayer.play("OpenLetter")
		3:
			return
		4:
			return

func letter_hit():
	AudMan.play_sfx_wav(LETTER_IMPACT, 0.0, false)
func letter_open():
	AudMan.play_sfx_wav(LETTER_OPEN, 0.0, false)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "OpenLetter":
		letteropened = true
	if anim_name == "ByeByeLetter":
		Dialogic.start("DrLogic")
		$Button2.mouse_filter = 3
		$Button.mouse_filter = 3
		#$TutorialBox.show()


func _on_button_2_pressed() -> void:
	if hit_amnt == 3 and letteropened == true:
		$AnimationPlayer.play("ByeByeLetter")
		hit_amnt = 4
		
func spawn_field_stock() -> void:
	#resserved_spots = get_random_point_in_area(SignalBus.field_stock.size())
	for i in SignalBus.field_stock.size():
		var new_yip = spawn_yip(SignalBus.field_stock[i], i)
		wire_yip(new_yip)
		all_yips.append(new_yip)
		
func wire_yip(yip: Yipee) -> void:
	yip.z_index = 100
	yip.yip_hovered.connect(_on_yip_hovered)
	yip.yip_unhovered.connect(_on_yip_unhovered)
	
func _on_yip_hovered(yip: Yipee) -> void:
	if not is_instance_valid(yip):
		print("SHIT")
		return

	tooltip.display_beside(yip)
	CursorManager.use(CursorManager.Pointers.CURSOR_MONEY)
	focused_yip = yip

func _on_yip_unhovered() -> void:
	print('yip unhovered')
	tooltip.request_hide()
	CursorManager.reset()
	focused_yip = null
		
func spawn_yip(data: YipeeData, index : int) -> Yipee:
	var new_yip := preload("res://World/yipee/yipee.tscn").instantiate() as Yipee
	new_yip.data = data
	var node_name = "Marker2D" + str(spawned_num)
	var found_node = get_node(node_name)
	if found_node:
		new_yip.position = found_node.global_position
	add_child(new_yip)
	spawned_num += 1
	new_yip.cost_of_yip.visible = true
	new_yip.cost.text = "$" + str(yip_costs[data.tier])
	
	#random idle animation
	new_yip.idle_state.start()
	
	return new_yip

func generate_alleles(tier: YipeeData.YipTier, helix: Helix) -> Helix:
	for strand in helix.strands:
		if strand == null:
			continue
		
		if chance_to_fill(tier) == true:
			#right
			strand.right = AlleleLibrary.random_right(strand.slot, yip_tier_dictionaries[field_level])
		if chance_to_fill(tier) == true:
			#left
			strand.left = AlleleLibrary.random_left(strand.slot, yip_tier_dictionaries[field_level])
	return helix

func chance_to_fill(yip_tier: YipeeData.YipTier) -> bool:
	var random = randi_range(0, 99)
	var current_odds = allele_fill_chance_by_tier[yip_tier]
	
	if random < current_odds:
		return true
	return false
	
func generate_field_stock() -> void:
	SignalBus.field_stock.clear()
	for i in yips_to_spawn:
		var yip_tier = get_yip_tier()
		var new_yip_data: YipeeData = YipeeData.generate_yip(yip_tier)
		generate_alleles(yip_tier, new_yip_data.helix)
		SignalBus.field_stock.append(new_yip_data)
		
func get_yip_tier():
	var random = randi_range(0, 99)
	var current_odds = yip_tier_dictionaries[field_level]
	
	var total = 0
	for odd in current_odds:
		total += current_odds[odd]
		if random < total:
			return odd

func _on_tutorial_box_next() -> void:
	$TutorialBox.hide()
	$TutorialBox2.show()

func _on_tutorial_box_2_next() -> void:
	$TutorialBox2.hide()
	$TutorialBox4.show()

func _on_tutorial_box_4_next() -> void:
	$TutorialBox4.hide()
	$TutorialBox5.show()

func _on_tutorial_box_5_next() -> void:
	$TutorialBox5.hide()
	$TutorialBox6.show()

func _on_tutorial_box_6_next() -> void:
	$TutorialBox6.hide()
	$TutorialBox7.show()

func _on_tutorial_box_7_next() -> void:
	$TutorialBox7.hide()
	$TutorialBox8.show()

func _on_tutorial_box_8_next() -> void:
	$TutorialBox8.hide()
	$TutorialBox9.show()

func _on_tutorial_box_9_next() -> void:
	$TutorialBox9.hide()
	$TutorialBox10.show()

func _on_tutorial_box_10_next() -> void:
	$TutorialBox10.hide()
	Dialogic.start("Intro")
	

#DEBUG
	
