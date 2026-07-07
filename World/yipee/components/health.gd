class_name Health extends Node

const HURT_HIT = preload("uid://bngmp5ra6pka1")
signal health_changed(current: int, maximum: int)

#fucking DIED
signal died

var max_health: int = 0

var current_health: int = 0

var shield: int = 0

func setup(max_hp: float) -> void:
	max_health = roundi(max_hp)
	current_health = max_health
	health_changed.emit(current_health, max_health)

func take_damage(damage_data: DamageInfo) -> void:
	AudMan.play_sfx_wav(HURT_HIT, -16.0, false)
	$"../HitAnim".play("GotHit")
	$"../ActionsAnim".play("Hit")
	if current_health <= 0:
		return
	var incoming := roundi(damage_data.amount)
	if shield > 0 and not damage_data.tags.has(&"ignore_shield"):
		var absorbed := mini(shield, incoming)
		shield -= absorbed
		incoming -= absorbed
	current_health = maxi(current_health - incoming, 0)
	health_changed.emit(current_health, max_health)
	if current_health <= 0:
		$"..".dead = true
		died.emit()
		$"../HealthBar".hide()
		$"../AnimScaleHandle/VisualYip/Buff".hide()
		$"../AnimScaleHandle/VisualYip/Debuff".hide()
		$"../AnimScaleHandle/VisualYip/Ice".hide()
		$"../AnimScaleHandle/VisualYip/Fire".hide()
		$"../AnimScaleHandle/VisualYip/Poison".hide()

func heal(amount: float) -> void:
	if current_health <= 0:
		return
	current_health = mini(current_health + roundi(amount), max_health)
	health_changed.emit(current_health, max_health)

func is_alive() -> bool:
	return current_health > 0
