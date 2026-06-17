class_name Field extends Node2D

var field_level = 0
var base_slot_chance = 25
var base_yip_tier_chance = 25

var yips = 3

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

var allele_tier_odds: Dictionary = {
	
}

func _ready():
	for i in yips:
		spawn_yip()


func get_yip_tier():
	var random = randi_range(0, 100)
	var current_odds = yip_tier_dictionaries[field_level]
	
	var total = 0
	for odd in current_odds:
		total += current_odds[odd]
		if random < total:
			return odd

func get_allele_tier():
	pass

func generate_allele():
	
	pass

func random_location() -> Vector2:
	var x = randi_range(200, 800)
	var y = randi_range(200, 800)
	var random = Vector2(x, y)
	return random


func spawn_yip():
	var yip_tier = get_yip_tier()
	var new_yip_data: YipeeData = YipeeData.generate_yip(yip_tier)
	var new_yip := preload("res://World/yipee/yipee.tscn").instantiate() as Yipee
	var new_helix := Helix.generate_random()
	new_yip_data.helix = new_helix
	new_yip.data = new_yip_data
	new_yip.position = random_location()
	
	
	add_child(new_yip)
