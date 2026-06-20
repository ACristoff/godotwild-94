class_name Field extends Node2D

var field_level = 0
var base_slot_chance = 25
var base_yip_tier_chance = 25

var yips_to_spawn = 3 + field_level

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

@onready var coin_label: Label = $CanvasLayer/Control/HBoxContainer/MarginContainer2/CoinLabel
@onready var tooltip: Toolyip = $CanvasLayer/YipToolyip

var all_yips:  Array[Yipee] = []

var focused_yip: Yipee = null



func _ready():
	#tooltip.yip_owner = self
	coin_label.text = str(SignalBus.coins)
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
	focused_yip = yip

func _on_yip_unhovered() -> void:
	print('yip unhovered')
	tooltip.hide()
	focused_yip = null

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
			strand.left = AlleleLibrary.random_left(strand.slot, yip_tier_dictionaries[field_level])
	return helix

func random_location() -> Vector2:
	var x = randi_range(0, 1920)
	var y = randi_range(0, 1080)
	var random = Vector2(x, y)
	return random

func clear_yips() -> void:
	var yip_count = all_yips.size()
	var total_yips = all_yips.duplicate()
	for i in yip_count:
		var yip = total_yips[i]
		all_yips.erase(yip)
		yip.queue_free()
		print(all_yips)

func spawn_yip() -> Yipee:
	var yip_tier = get_yip_tier()
	var new_yip_data: YipeeData = YipeeData.generate_yip(yip_tier)
	var new_yip := preload("res://World/yipee/yipee.tscn").instantiate() as Yipee
	generate_alleles(yip_tier, new_yip_data.helix)
	new_yip.data = new_yip_data
	new_yip.position = random_location()
	
	add_child(new_yip)
	return new_yip

func buy_yip(yip_bought: Yipee) -> void:
	var yip_cost = calculate_yip_price(yip_bought)
	print(yip_cost, '<- price')
	if check_coinage(yip_cost) == false:
		print('not enough money!')
		return
	else:
	#happy path
		spend_coins(yip_cost)
		SignalBus.yip_inventory.append(yip_bought.data)
		all_yips.erase(yip_bought)
		#SignalBus.yip_party[1] = yip_bought.data
		var empty_slot = check_empty_party()
		if empty_slot > 0:
			SignalBus.yip_party[empty_slot] = yip_bought.data
		yip_bought.queue_free()
		tooltip.hide()
		print(SignalBus.yip_inventory)

func check_empty_party() -> int:
	for slot in SignalBus.yip_party:
		print('slot', slot)
		if SignalBus.yip_party[slot] == null:
			return slot
	return 0

func spend_coins(cost: int) -> void:
	SignalBus.coins -= cost
	coin_label.text = str(SignalBus.coins)
	print('yip bought for', cost, '.', 'left in wallet' )
	pass

func check_coinage(price: int):
	if price <= SignalBus.coins:
		return true
	else:
		return false

func calculate_yip_price(yip: Yipee) -> int:
	var cost = 3
	match yip.data.tier:
		YipeeData.YipTier.UNCOMMON:
			cost = 4
		YipeeData.YipTier.RARE:
			cost = 5
		YipeeData.YipTier.ULTRARARE:
			cost = 6
	return cost

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if focused_yip:
			print('buy yip', focused_yip)
			buy_yip(focused_yip)

func _on_refresh_button_pressed():
	clear_yips()
	for i in yips_to_spawn:
		var new_yip = spawn_yip()
		wire_yip(new_yip)
		all_yips.append(new_yip)
	pass # Replace with function body.


func _on_farm_button_pressed():
	SignalBus.go_to.emit(SignalBus.Locations.FARM)
