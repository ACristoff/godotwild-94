class_name Field extends Node2D

var field_level = 3
var base_slot_chance = 25
var base_yip_tier_chance = 25

var yips_to_spawn = 3

var yip_tier_odds_0: Dictionary = {
	YipeeData.YipTier.COMMON: 50,
	YipeeData.YipTier.UNCOMMON: 30,
	YipeeData.YipTier.RARE: 15,
	YipeeData.YipTier.ULTRARARE: 5
}

var yip_tier_odds_1: Dictionary = {
	YipeeData.YipTier.COMMON: 40,
	YipeeData.YipTier.UNCOMMON: 30,
	YipeeData.YipTier.RARE: 20,
	YipeeData.YipTier.ULTRARARE: 10
}

var yip_tier_odds_2: Dictionary = {
	YipeeData.YipTier.COMMON: 20,
	YipeeData.YipTier.UNCOMMON: 25,
	YipeeData.YipTier.RARE: 40,
	YipeeData.YipTier.ULTRARARE: 15
}

var yip_tier_odds_3: Dictionary = {
	YipeeData.YipTier.COMMON: 5,
	YipeeData.YipTier.UNCOMMON: 45,
	YipeeData.YipTier.RARE: 30,
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

@onready var tooltip = $CanvasLayer/YipToolyip

var all_yips:  Array[Yipee] = []

func _ready():
	#tooltip.yip_owner = self
	tooltip.hide()
	for i in yips_to_spawn:
		var new_yip = spawn_yip()
		wire_yip(new_yip)
		all_yips.append(new_yip)

func wire_yip(yip: Yipee) -> void:
	yip.yip_hovered.connect(_on_yip_hovered)
	yip.yip_unhovered.connect(_on_yip_unhovered)

func _on_yip_hovered(yip: Yipee) -> void:
	print('im hovered')
	var screen_size = get_viewport().get_visible_rect().size / 3
	tooltip.display(yip)
	var screen_pos = yip.get_global_transform_with_canvas().origin
	tooltip.global_position = $CanvasLayer.transform.affine_inverse() * screen_pos
	tooltip.global_position.y -= 99
	tooltip.global_position.x -= 55
	tooltip.global_position.x = clamp(tooltip.global_position.x, 0, screen_size.x - tooltip.tt_size.x)
	tooltip.global_position.y = clamp(tooltip.global_position.y, 0, screen_size.y - tooltip.tt_size.y)

func _on_yip_unhovered() -> void:
	print('yip unhovered')
	tooltip.hide()

func get_yip_tier():
	var random = randi_range(0, 99)
	var current_odds = yip_tier_dictionaries[field_level]
	
	var total = 0
	for odd in current_odds:
		total += current_odds[odd]
		if random < total:
			return odd

func chance_to_fill(yip_tier: YipeeData.YipTier) -> bool:
	var random = randi_range(0, 99)
	var current_odds = allele_fill_chance_by_tier[yip_tier]
	
	if random < current_odds:
		return true
	return false

func generate_alleles(tier: YipeeData.YipTier, helix: Helix) -> Helix:
	for strand in helix.strands:
		if strand == null:
			continue
		
		if chance_to_fill(tier) == true:
			#right
			strand.right = AlleleLibrary.random_right(strand.slot, yip_tier_dictionaries[field_level])
		if chance_to_fill(tier) == true:
			#left
			pass
	return helix

func random_location() -> Vector2:
	var x = randi_range(0, 1920)
	var y = randi_range(0, 1080)
	var random = Vector2(x, y)
	return random

func clear_yips() -> void:
	for yip in all_yips:
		
		all_yips.erase(yip)
		yip.queue_free()

func spawn_yip() -> Yipee:
	var yip_tier = get_yip_tier()
	#var yip_tier = YipeeData.YipTier.ULTRARARE
	var new_yip_data: YipeeData = YipeeData.generate_yip(yip_tier)
	var new_yip := preload("res://World/yipee/yipee.tscn").instantiate() as Yipee
	generate_alleles(yip_tier, new_yip_data.helix)
	new_yip.data = new_yip_data
	new_yip.position = random_location()
	
	
	add_child(new_yip)
	return new_yip


func _on_refresh_button_pressed():
	clear_yips()
