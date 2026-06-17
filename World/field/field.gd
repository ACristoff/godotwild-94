class_name Field extends Node2D

var field_level = 3
var base_slot_chance = 25
var base_yip_tier_chance = 25

var yips = 30

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


#var allele_tier_odds: Dictionary = {
	#YipeeData.YipTier.COMMON: 
#}

func _ready():
	for i in yips:
		spawn_yip()


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


func spawn_yip():
	var yip_tier = get_yip_tier()
	#var yip_tier = YipeeData.YipTier.ULTRARARE
	var new_yip_data: YipeeData = YipeeData.generate_yip(yip_tier)
	var new_yip := preload("res://World/yipee/yipee.tscn").instantiate() as Yipee
	var new_helix := Helix.generate_random(yip_tier)
	var mutated_helix : Helix = generate_alleles(yip_tier, new_helix)
	
	new_yip_data.helix = mutated_helix
	new_yip.data = new_yip_data
	new_yip.position = random_location()
	
	
	add_child(new_yip)
