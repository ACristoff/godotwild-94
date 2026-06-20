extends Node2D

enum Team { PLAYER, ENEMY, NONE }

@export var battle_speed: float = 1.0
@export var level: Level
@onready var enemy_team_data: Array[YipeeData]
var player_team_data := SignalBus.yip_party.values()

var player_team = []
var enemy_team = []

var _battle_started: bool = false
var _battle_over: bool = false

var focused_yip: Yipee = null
@onready var tooltip: Toolyip = $CanvasLayer/YipToolyip

func _spawn(data: YipeeData, pos: Vector2) -> Yipee:
	var yip := preload("res://World/yipee/yipee.tscn").instantiate() as Yipee
	yip.data = data
	yip.position = pos
	
	add_child(yip)
	yip.health_UI.visible = true
	yip.health_UI.current_health = yip.health.current_health
	yip.health_UI.max_health = yip.health.max_health
	yip.health_UI.update_UI()
	wire_yip(yip)
	return yip

#DEBUG
func generate_random_teams():
	for i in range(1):
		#var new_yip = YipeeData.generate_yip(YipeeData.YipTier.ULTRARARE)
		#player_team_data.append(new_yip)
		var new_yip2 = YipeeData.generate_yip(YipeeData.YipTier.COMMON)
		enemy_team_data.append(new_yip2)
	pass


func _on_yip_hovered(yip: Yipee) -> void:
	if _battle_started == false:
		return
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

func wire_yip(yip: Yipee) -> void:
	yip.yip_hovered.connect(_on_yip_hovered)
	yip.yip_unhovered.connect(_on_yip_unhovered)

func _ready():
	tooltip.hide()
	if level:
		enemy_team_data = level.enemy_team
	#generate_random_teams()
	_play_intro()
	#Spawn player team
	print( 'player team data ', player_team_data, SignalBus.yip_party)
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
	

func _play_intro() -> void:
	if level and level.intro_animation:
		var anim := level.intro_animation.instantiate()
		add_child(anim)
		anim.tree_exited.connect(_play_intro_timeline)
	else:
		_play_intro_timeline()

func _play_intro_timeline() -> void:
	if level and level.intro_timeline:
		Dialogic.timeline_ended.connect(_on_intro_finished)
		Dialogic.start(level.intro_timeline)
	else:
		_battle_started = true

func _on_intro_finished() -> void:
	_battle_started = true

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
	target.ability.on_take_damage(damage, self)
	var hp_before := target.health.current_health
	target.health.take_damage(damage)
	var hp_lost := hp_before - target.health.current_health
	target.health_UI.current_shield = target.health.shield
	target.health_UI.health_change(hp_lost, damage_type_name(damage))

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
	var battle_end_cond = check_for_victory()
	if battle_end_cond != Team.NONE:
		prints("Battle over!", check_for_victory())
		_battle_over = true
		$CanvasLayer2/NextButton.visible = true
		#TODO make button visible

func _on_next():
	var battle_end_cond = check_for_victory()
	
	if battle_end_cond == Team.PLAYER:
		SignalBus.battle_finished.emit(true)
	if battle_end_cond == Team.ENEMY:
		SignalBus.battle_finished.emit(false)

func _on_status_tick(damage: DamageInfo, owner_yip: Yipee) -> void:
	if _battle_over:
		return
	damage.target = owner_yip
	apply_damage(owner_yip, damage)

func _process(delta):
	if not _battle_started:
		return
	if _battle_over != true:
		for yip: Yipee in player_team:
			if yip.health.current_health > 0:
				if not yip.status.is_frozen():
					yip.attack.tick(delta * battle_speed)
				yip.status.tick(delta * battle_speed)
		for yip: Yipee in enemy_team:
			if yip.health.current_health > 0:
				if not yip.status.is_frozen():
					yip.attack.tick(delta * battle_speed)
				yip.status.tick(delta * battle_speed)


func _on_next_button_pressed() -> void:
	_on_next()
