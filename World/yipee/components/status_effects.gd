class_name StatusEffects extends Node


signal status_tick(damage: DamageInfo)
# for the health-bar pips ([health_bar.gd] update_ailments(name, value))
signal effects_changed(status_name: String, value: int)

enum Kind { BURN, POISON }

const TICK_INTERVALS := {
	Kind.BURN: 0.5,
	Kind.POISON: 1.0,
}

var _effects: Dictionary = {}


func apply(kind: Kind, stacks: int) -> void:
	if _effects.has(kind):
		_effects[kind].stacks += stacks
	else:
		_effects[kind] = StatusEffect.new(kind, stacks)
	effects_changed.emit(_visual_name(kind), _effects[kind].stacks)

func tick(delta: float) -> void:
	if _effects.is_empty():
		return
	
	for kind in _effects.keys():
		var effect: StatusEffect = _effects[kind]
		effect.clock += delta
		var interval: float = TICK_INTERVALS.get(kind, 1.0)
		if effect.clock < interval:
			continue
		effect.clock -= interval
	
		_emit_tick_damage(effect)
		effect.stacks -= 1
		if effect.stacks <= 0:
			_effects.erase(kind)
			effects_changed.emit(_visual_name(kind), 0)
		else:
			effects_changed.emit(_visual_name(kind), effect.stacks)


func _emit_tick_damage(effect: StatusEffect) -> void:
	var dmg := DamageInfo.new()
	dmg.amount = effect.stacks
	dmg.type = _kind_to_type(effect.kind)
	status_tick.emit(dmg)

func _visual_name(kind: Kind) -> String:
	return DamageInfo.Type.keys()[_kind_to_type(kind)]

func _kind_to_type(kind: Kind) -> DamageInfo.Type:
	match kind:
		Kind.BURN: return DamageInfo.Type.FIRE
		Kind.POISON: return DamageInfo.Type.POISON
		_: return DamageInfo.Type.PHYSICAL
