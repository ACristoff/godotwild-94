extends Node2D

enum Team { PLAYER, ENEMY, NONE }

@export var battle_speed: float = 1.0

@export var player_team_data := SignalBus.yip_party.values()
@export var enemy_team_data: Array[YipeeData]

var player_team = []
var enemy_team = []

var _battle_over: bool = false

func _spawn(data: YipeeData, pos: Vector2) -> Yipee:
	var yip := preload("res://World/yipee/yipee.tscn").instantiate() as Yipee
	yip.data = data
	yip.position = pos
	
	add_child(yip)
	yip.health_UI.visible = true
	yip.health_UI.current_health = yip.health.current_health
	yip.health_UI.max_health = yip.health.max_health
	yip.health_UI.update_UI()
	return yip

#DEBUG
func generate_random_teams():
	for i in range(1):
		#var new_yip = YipeeData.generate_yip(YipeeData.YipTier.ULTRARARE)
		#player_team_data.append(new_yip)
		var new_yip2 = YipeeData.generate_yip(YipeeData.YipTier.COMMON)
		enemy_team_data.append(new_yip2)
	pass

func _ready():
	generate_random_teams()
	#Spawn player team
	print( 'player team data ', player_team_data)
	for i in range(5):
		if i >= player_team_data.size() or player_team_data[i] == null:
			break
		var spawn = get_node("PlayerTeam/Spawn_" + str(i + 1))
		var new_yip = _spawn(player_team_data[i], spawn.global_position + Vector2(105, 45))
		player_team.append(new_yip)
	#Spawn enemy team
	for i in range(5):
		if i >= enemy_team_data.size() or enemy_team_data[i] == null:
			break
		var spawn = get_node("EnemyTeam/Spawn_" + str(i + 1))
		var new_yip = _spawn(enemy_team_data[i], spawn.global_position + Vector2(105, 45))
		new_yip.body.scale.x = new_yip.body.scale.x * -1 
		new_yip.enemy_flip()
		enemy_team.append(new_yip)
	#Wire up all the yips
	for yip in player_team:
		wire_signals(yip, Team.PLAYER)
	for yip in enemy_team:
		wire_signals(yip, Team.ENEMY)

func wire_signals(yip: Yipee, team: Team):
	yip.attack.attack_ready.connect(_on_attack_ready.bind(team))
	yip.health.died.connect(_on_died.bind(yip))
	yip.status.status_tick.connect(_on_status_tick.bind(yip))

func _on_attack_ready(damage: DamageInfo, team: Team) -> void:
	if _battle_over:
		return
	
	var target: Yipee = null
	if team == Team.PLAYER:
		target = get_first_alive("enemy")
	else:
		target = get_first_alive("player")
	
	if target == null:
		print("No target available!")
		return
	
	#prints(damage, damage.amount, damage.target, team, target)
	var attacker := damage.source as Yipee
	damage.target = target
	print("%s hit %s for %d → %d/%d" % [
		damage.source.data.yipee_name, target.data.yipee_name, damage.amount,
		target.health.current_health, target.health.max_health])
	
	# attacker's strands mutate the OUTGOING hit (FireAllele stamps FIRE here)
	attacker.ability.on_attack(damage, self)
	apply_damage(target, damage)
	# post-hit reactions (splash, lifesteal…) fan out AFTER the hit lands
	attacker.ability.on_hit(damage, self)

func apply_damage(target: Yipee, damage: DamageInfo) -> void:
	# target's strands mutate the INCOMING hit (resist/shield) before it lands
	target.ability.on_take_damage(damage, self)
	target.health.take_damage(damage)
	target.health_UI.health_change(int(damage.amount), damage_type_name(damage))

func damage_type_name(damage: DamageInfo) -> String:
	return DamageInfo.Type.keys()[damage.type]

func check_for_victory() -> Team:
	var player_alive = false
	var enemy_alive = false
	for yip: Yipee in player_team:
		if yip.health.current_health > 0:
			player_alive = true
			break
	for yip: Yipee in enemy_team:
		if yip.health.current_health > 0:
			enemy_alive = true
			break
	if player_alive == true && enemy_alive == false:
		return Team.PLAYER
	if player_alive == false && enemy_alive == true:
		return Team.ENEMY
	return Team.NONE

func get_first_alive(team: String) -> Yipee:
	if team == "player":
		for yip: Yipee in player_team:
			if yip.health.current_health > 0:
				return yip
	elif team == "enemy":
		for yip: Yipee in enemy_team:
			if yip.health.current_health > 0:
				return yip
	return null

func _on_died(corpse: Yipee) -> void:
	if _battle_over:
		return
	
	corpse.ability.on_death(self)
	print(corpse.data.yipee_name, " fucking died!")
	corpse.scale.y = -1
	if check_for_victory() != Team.NONE:
		prints("Battle over!", check_for_victory())
		_battle_over = true
func _on_status_tick(damage: DamageInfo, owner_yip: Yipee) -> void:
	if _battle_over:
		return
	damage.target = owner_yip
	apply_damage(owner_yip, damage)

func _process(delta):
	if _battle_over != true:
		for yip: Yipee in player_team:
			if yip.health.current_health > 0:
				yip.attack.tick(delta * battle_speed)
				yip.status.tick(delta * battle_speed)
		for yip: Yipee in enemy_team:
			if yip.health.current_health > 0:
				yip.attack.tick(delta * battle_speed)
				yip.status.tick(delta * battle_speed)
