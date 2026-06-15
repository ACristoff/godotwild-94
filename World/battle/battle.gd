extends Node2D

enum Team { PLAYER, ENEMY, NONE }

@export var battle_speed: float = 1.0

@export var player_team_data: Array[YipeeData]
@export var enemy_team_data: Array[YipeeData]

var player_team = []
var enemy_team = []

var _battle_over: bool = false

func _spawn(data: YipeeData, pos: Vector2) -> Yipee:
	var yip := preload("res://World/yipee/yipee.tscn").instantiate() as Yipee
	yip.data = data
	yip.position = pos
	add_child(yip)
	return yip

func _ready():
	#Spawn player team
	for i in range(5):
		if i >= player_team_data.size() or player_team_data[i] == null:
			break
		var spawn = get_node("PlayerTeam/Spawn_" + str(i + 1))
		var new_yip = _spawn(player_team_data[i], spawn.global_position)
		player_team.append(new_yip)
	#Spawn enemy team
	for i in range(5):
		if i >= enemy_team_data.size() or enemy_team_data[i] == null:
			break
		var spawn = get_node("EnemyTeam/Spawn_" + str(i + 1))
		var new_yip = _spawn(enemy_team_data[i], spawn.global_position)
		new_yip.scale.x = -1
		enemy_team.append(new_yip)
	#Wire up all the yips
	for yip in player_team:
		wire_signals(yip, Team.PLAYER)
	for yip in enemy_team:
		wire_signals(yip, Team.ENEMY)

func wire_signals(yip: Yipee, team: Team):
	yip.attack.attack_ready.connect(_on_attack_ready.bind(team))
	yip.health.died.connect(_on_died.bind(yip))

func _on_attack_ready(damage: DamageInfo, team: Team) -> void:
	if _battle_over:
		return
	
	var target = null
	if team == Team.PLAYER:
		target = get_first_alive("enemy")
	else:
		target = get_first_alive("player")
	
	if target == null:
		print("No target available!")
		return
	
	#prints(damage, damage.amount, damage.target, team, target)
	damage.target = target
	print("%s hit %s for %d → %d/%d" % [
		damage.source.data.yipee_name, target.data.yipee_name, damage.amount,
		target.health.current_health, target.health.max_health])
	target.health.take_damage(damage)



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
	
	print(corpse.data.yipee_name, " fucking died!")
	corpse.scale.y = -1
	if check_for_victory() != Team.NONE:
		print("Battle over!", check_for_victory())
		_battle_over = true

func _process(delta):
	if _battle_over != true:
		for yip: Yipee in player_team:
			if yip.health.current_health > 0:
				yip.attack.tick(delta * battle_speed)
		for yip: Yipee in enemy_team:
			if yip.health.current_health > 0:
				yip.attack.tick(delta * battle_speed)
