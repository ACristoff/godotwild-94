class_name Field extends Node2D

var field_level = 0
var base_slot_chance = 25
var base_yip_tier_chance = 25

var yips_to_spawn : int = 3 + field_level

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

@onready var coin_label: Label = $CanvasLayer/Control/HBoxContainer/MarginContainer2/CoinLabel
@onready var tooltip: Toolyip = $CanvasLayer/YipToolyip

var all_yips:  Array[Yipee] = []

var focused_yip: Yipee = null

var resserved_spots : Array[Vector2] = []


const MIN_DISTANCE_BETWEEN_POINTS: float = 200.0
const MAX_ATTEMPTS_PER_POINT : int = 30

#region Built in
func _ready():
	#tooltip.yip_owner = self
	coin_label.text = str(SignalBus.coins)
	tooltip.hide()
	field_level = clampi(SignalBus.victories, 0, 4)
	update_field_labels()
	resserved_spots = get_random_point_in_area(yips_to_spawn)
	print("RESERVED SPOTS HERE:", resserved_spots)
	for i in (yips_to_spawn):
		var new_yip = spawn_yip(i)
		wire_yip(new_yip)
		all_yips.append(new_yip)

func update_field_labels():
	var field_sign = $UpgradeSign/UpgradeField
	field_sign.text = "Lv. " + str(field_level + 1)
	
	var rates = $UpgradeSign/RateLabel
	var yip_odds = yip_tier_dictionaries[field_level]
	var stringy_common = "COMMON " + str(yip_odds[YipeeData.YipTier.COMMON]) + "% \n"
	var stringy_uncommon = "UNCOMMON " + str(yip_odds[YipeeData.YipTier.UNCOMMON]) + "% \n"
	var stringy_rare = "RARE " + str(yip_odds[YipeeData.YipTier.RARE]) + "% \n"
	var stringy_ultrarare = "ULTRA-RARE " + str(yip_odds[YipeeData.YipTier.ULTRARARE]) + "% \n"
	var final = stringy_common + stringy_uncommon + stringy_rare + stringy_ultrarare
	rates.text = final

# So we clear all reservered spots when we leave
func _exit_tree() -> void:
	resserved_spots = []
	pass
#endregion

#region Signal
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
#endregion

#region Allelle stuff
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

func clear_yips() -> void:
	var yip_count = all_yips.size()
	var total_yips = all_yips.duplicate()
	for i in yip_count:
		var yip = total_yips[i]
		all_yips.erase(yip)
		yip.queue_free()
		print(all_yips)
		
#endregion

#region Location

## Picks a random spot for a yip to spawn in, tries to space yips away from eachother, not guranteed.
func get_random_point_in_area(count : int) -> Array[Vector2]:
	# Array to store each collision shape
	var shapes : Array[CollisionShape2D] = []
	
	# Grab each Collisionshape2D
	for child in %FieldArea.get_children():
		# Check if its shape is CollisionShape2D
		if child is CollisionShape2D:
			# Check if its shape is RectangleShape2D
			if child.shape is RectangleShape2D:
				shapes.append(child)
				
	# Error if we don't have any grazing spot
	if shapes.is_empty():
		push_error("Why is this empty stupid add some grazing space!!!!!!")
		return []
		
	# Pointts we can use as spots
	var points : Array[Vector2] = []
	
	# Active List for poisson distribution
	var active_list : Array[Vector2] = []
	
	# Seed with one random valid point from a random box
	var first_point : Vector2 = _random_point_in_random_shape(shapes)
	points.append(first_point)
	active_list.append(first_point)
	
	# Keep creating points as long as there is at least one active point to grow from and havent reached number of yips (count)
	while active_list.size() > 0 and points.size() < count:
		# Pick a random point in active list to spawn a new point from
		var active_index : int = randi() % active_list.size() # Index of point we will grow from
		var base_point : Vector2 = active_list[active_index]
		
		# Tracker for valid point or not
		var found_valid : bool = false
		
		# Iterating until we hit limit
		for i in MAX_ATTEMPTS_PER_POINT:
			
			# Point a random angle in a circle
			var angle : float = randf_range(0.0, TAU)
			# Pick a random distance within said circle
			var dist : float = randf_range(MIN_DISTANCE_BETWEEN_POINTS, MIN_DISTANCE_BETWEEN_POINTS * 5.3)
			# Grab the actual normal coordinate at angle and distance, convert it back to regular points
			var candidate : Vector2 = base_point + Vector2(cos(angle), sin(angle)) * dist
			
			# Check if it falls within any of our grazing areas
			if not _is_inside_any_shape(candidate, shapes):
				continue
				
			# Check if it is far enough from all of our points
			if not _is_far_enough(candidate, points):
				continue
			
			# We found a valid point so add it to the list
			points.append(candidate)
			
			# update our active list, we found a new viable canidate, update bool and stop attempting for this base point
			active_list.append(candidate)
			found_valid = true
			break
		
		# We exuasted all tries for this canidate point so remove it from the list
		if not found_valid:
			active_list.remove_at(active_index)
			
	# We didn't produce enough points for our yips so generate random points
	if points.size() < count:
		var remaining : int = count - points.size()
		push_warning("Only found %d spaced points, filling remaining %d with plain random points" % [points.size(), remaining])
		
		for i in remaining:
			points.append(_random_point_in_random_shape(shapes))
	
	return points
	

## Picks a random shape, generates a random point inside its local bound then convert to global.
func _random_point_in_random_shape(shapes : Array[CollisionShape2D]) -> Vector2:
	var shape_node : CollisionShape2D = shapes[randi() % shapes.size()]
	var rect_shape : RectangleShape2D = shape_node.shape
	var extents : Vector2 = rect_shape.size / 2.0
	var local_point : Vector2 = Vector2(randf_range(-extents.x, extents.x), randf_range(-extents.y, extents.y))
	return shape_node.to_global(local_point)

## Checks if a global point is inside any of our shapes  (grazing areas)
func _is_inside_any_shape(global_point : Vector2, shapes : Array[CollisionShape2D]) -> bool:
	for shape_node in shapes:
		var local_point : Vector2 = shape_node.to_local(global_point)
		var rect_shape : RectangleShape2D = shape_node.shape
		var extents : Vector2 = rect_shape.size / 2.0
		
		# Use abs to cover both positive and negative distance
		if abs(local_point.x) <= extents.x and abs(local_point.y) <= extents.y:
			return true
	return false

## Checks to see if a point is far enough basically
func _is_far_enough(point : Vector2, existing_points : Array[Vector2]) -> bool:
	for p in existing_points:
		if point.distance_to(p) < MIN_DISTANCE_BETWEEN_POINTS:
			return false
	return true

func spawn_yip(index : int) -> Yipee:
	var yip_tier = get_yip_tier()
	var new_yip_data: YipeeData = YipeeData.generate_yip(yip_tier)
	var new_yip := preload("res://World/yipee/yipee.tscn").instantiate() as Yipee
	generate_alleles(yip_tier, new_yip_data.helix)
	
	new_yip.data = new_yip_data
	new_yip.position = resserved_spots[index]
	add_child(new_yip)
	
	new_yip.cost_of_yip.visible = true
	var yip_cost = yip_costs[yip_tier]
	new_yip.cost.text = "$" + str(yip_cost)
	
	# So they do the idle animation
	new_yip.animation_player.play(&"IdleNormal")
	
	return new_yip
	
#endregion

#region Buying stuff

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
			yip_bought.data.yip_party_slot = 6 - empty_slot
		yip_bought.queue_free()
		tooltip.hide()
		print(SignalBus.yip_inventory)
		SignalBus.first_yip_bought = true

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
	
#endregion

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if focused_yip:
			print('buy yip', focused_yip)
			buy_yip(focused_yip)

func _on_refresh_button_pressed():
	clear_yips()
	for i in yips_to_spawn:
		var new_yip = spawn_yip(i)
		wire_yip(new_yip)
		all_yips.append(new_yip)


func _on_farm_button_pressed():
	SignalBus.go_to.emit(SignalBus.Locations.FARM)
