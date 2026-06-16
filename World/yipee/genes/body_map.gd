class_name BodyMap

enum Stat { HEALTH, ATTACK, COOLDOWN, SPECIALIZATION, BREEDING }

const STAT_SLOTS := {
	Stat.HEALTH: [Helix.Slot.HEALTH, Helix.Slot.HEALTH_AUGMENT],
	Stat.ATTACK: [Helix.Slot.ATTACK, Helix.Slot.ATTACK_AUGMENT_1, Helix.Slot.ATTACK_AUGMENT_2],
	Stat.COOLDOWN: [Helix.Slot.COOLDOWN],
	Stat.SPECIALIZATION: [Helix.Slot.SPECIALIZATION],
	Stat.BREEDING: [Helix.Slot.BREED_AUGMENT],
}

#This is for the right alleles
enum BuffMode { FLAT, PERCENT, NONE }

const SLOT_BUFF := {
	Helix.Slot.HEALTH: BuffMode.FLAT,
	Helix.Slot.HEALTH_AUGMENT: BuffMode.PERCENT,
	Helix.Slot.ATTACK: BuffMode.FLAT,
	Helix.Slot.ATTACK_AUGMENT_1: BuffMode.PERCENT,
	Helix.Slot.ATTACK_AUGMENT_2: BuffMode.PERCENT,
	Helix.Slot.COOLDOWN: BuffMode.FLAT,
	Helix.Slot.SPECIALIZATION: BuffMode.NONE,
	Helix.Slot.BREED_AUGMENT: BuffMode.NONE,
}

enum Part { NONE, FEET, BODY, WINGS, TAIL, HEAD, MISC, EARS, MOUTH, EYES }
