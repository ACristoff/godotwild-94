class_name Attack extends Node

const HITMARKER = preload("uid://bikprebh0m0p1")
signal attack_ready(damage: DamageInfo)
signal progress_changed(fraction: float)

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
	
	
	progress_changed.emit(_elapsed / cooldown)

func make_damage() -> DamageInfo:
	var damage := DamageInfo.new()
	damage.amount = power
	damage.source = get_parent()
	AudMan.play_sfx_wav(HITMARKER, -16.0, false)
	$"../ActionsAnim".play("Attack")
	$"../ThrowPunchAnim".play("Punch")
	return damage
