class_name Attack extends Node

signal attack_ready(damage: DamageInfo)

var cooldown: float = 2.0
var power: float = 0.0
var _elapsed: float = 0.0

func setup(attack_cooldown: float, attack_power: float) -> void:
	cooldown = attack_cooldown
	power = attack_power
	_elapsed = 0.0

func tick(delta) -> void:
	if cooldown <= 0.0:
		return
	
	_elapsed += delta
	while _elapsed >= cooldown:
		_elapsed -= cooldown
		attack_ready.emit(make_damage())

func make_damage() -> DamageInfo:
	var damage := DamageInfo.new()
	damage.amount = power
	damage.source = get_parent()
	return damage
