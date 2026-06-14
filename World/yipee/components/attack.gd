class_name Attack extends Node

signal attack_ready(damage: DamageInfo)

var cooldown: float = 2.0
var power: float = 0.0
var _elapsed: float = 0.0

func setup(attack_cooldown: float, attack_power: float) -> void:
	cooldown = attack_cooldown
	power = attack_power
	_elapsed = 0.0

#class_name Health extends Node
#
#signal health_changed(current: int, maximum: int)
##fucking DIED
#signal died
#
#var max_health: int = 0
#var current_health: int = 0
#
#func setup(max_hp: float) -> void:
	#max_health = roundi(max_hp)
	#current_health = max_health
	#health_changed.emit(current_health, max_health)
#
#func take_damage(damage_data: DamageInfo) -> void:
	#if current_health <= 0:
		#return
	#current_health = maxi(current_health - roundi(damage_data.amount), 0)
	#health_changed.emit(current_health, max_health)
	#if current_health <= 0:
		#died.emit()
#
#func heal(amount: float) -> void:
	#if current_health <= 0:
		#return
	#current_health = mini(current_health + roundi(amount), max_health)
	#health_changed.emit(current_health, max_health)
#
#func is_alive() -> bool:
	#return current_health > 0
