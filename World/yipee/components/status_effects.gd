class_name StatusEffects extends Node


signal status_tick(damage: DamageInfo)
signal effects_changed(status_name: String, value: int)

enum Kind { BURN, POISON, ICE }

const TICK_INTERVALS := {
	Kind.BURN: 0.5,
	Kind.POISON: 1.0,
}

# seconds before the first melt tick
# each melt shrinks the interval (accelerates)
const ICE_MELT_START := 0.6   
const ICE_MELT_DECAY := 0.85  

var _effects: Dictionary = {}
var _health: Health = null


func setup(owner_health: Health) -> void:
	_health = owner_health

func apply(kind: Kind, stacks: int) -> void:
	if _effects.has(kind):
		_effects[kind].stacks += stacks
	else:
		_effects[kind] = StatusEffect.new(kind, stacks)
	effects_changed.emit(_visual_name(kind), _effects[kind].stacks)

func is_frozen() -> bool:
	return _effects.has(Kind.ICE) and _effects[Kind.ICE].frozen

func tick(delta: float) -> void:
	if _effects.is_empty():
		return
	
	for kind in _effects.keys():
		var effect: StatusEffect = _effects[kind]
		if kind == Kind.ICE:
			_tick_ice(effect, delta)
			continue
		
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


func _tick_ice(effect: StatusEffect, delta: float) -> void:
	if not effect.frozen:
		if _health and _health.current_health <= effect.stacks:
			effect.frozen = true
			effect.melt_interval = ICE_MELT_START
			effect.clock = 0.0
			effects_changed.emit("FREEZE", effect.stacks)
		return
	
	effect.clock += delta
	if effect.clock < effect.melt_interval:
		return
	effect.clock -= effect.melt_interval
	effect.melt_interval *= ICE_MELT_DECAY
	
	effect.stacks -= 1
	if effect.stacks <= 0:
		_effects.erase(Kind.ICE)
		effects_changed.emit("FREEZE", 0)
	else:
		effects_changed.emit("FREEZE", effect.stacks)


func _emit_tick_damage(effect: StatusEffect) -> void:
	var dmg := DamageInfo.new()
	dmg.amount = effect.stacks
	dmg.type = _kind_to_type(effect.kind)
	if effect.kind == Kind.POISON:
		dmg.tags.append(&"ignore_shield")
	status_tick.emit(dmg)

func _visual_name(kind: Kind) -> String:
	return DamageInfo.Type.keys()[_kind_to_type(kind)]

func _kind_to_type(kind: Kind) -> DamageInfo.Type:
	match kind:
		Kind.BURN: return DamageInfo.Type.FIRE
		Kind.POISON: return DamageInfo.Type.POISON
		Kind.ICE: return DamageInfo.Type.ICE
		_: return DamageInfo.Type.PHYSICAL
