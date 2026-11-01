class_name AlllelePip extends TextureRect

var hovering = false
var current_strand: Strand
#var allele_data: Allele
#const ALELLE_UI = preload("uid://cckwntee1s0l4")
var spawn_pos
@onready var left_line := $"../../../Line2D"
@onready var right_line := $"../../../Line2D2"
@onready var allele_ui_visual := $"../.."

var skill : Sprite2D
var vanity : Sprite2D
var dna_skill : TextureRect
var dna_vanity : TextureRect

signal strand_hovered

const SLOT_COLORS := {
	BodyMap.Slot.HEALTH:         "779422",
	BodyMap.Slot.HEALTH_AUGMENT: "5f70e0",
	BodyMap.Slot.ATTACK:         "9c2424",
	BodyMap.Slot.ATTACK_AUGMENT: "d14830",
	BodyMap.Slot.COOLDOWN:       "56bccc",
	BodyMap.Slot.SPECIALIZATION: "cc4bae",
	BodyMap.Slot.BREED_AUGMENT:  "784bcc",
	BodyMap.Slot.NONE:           "3d3d3d",
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	skill = find_child("SkillIn", true, false)
	vanity = find_child("VanityIn", true, false)
	dna_skill = find_child("DnaSkill", true, false)
	dna_vanity = find_child("DnaVanity", true, false)


func _on_mouse_entered() -> void:
	allele_ui_visual._cooldown_show()
	left_line.set_point_position(0, skill.global_position)
	right_line.set_point_position(0, vanity.global_position)
	#TODO
	if current_strand == null:
		strand_hovered.emit(current_strand)
		return
	else:
		strand_hovered.emit(current_strand)


func _on_mouse_exited() -> void:
	allele_ui_visual._allele_show()


func set_strand(strand: Strand) -> void:
	current_strand = strand
	vanity.frame = 1
	skill.frame = 1
	dna_vanity.hide()
	dna_skill.hide()
	if current_strand != null:
		var slot_type = current_strand.slot
		var slot_color = SLOT_COLORS[current_strand.slot]
		print(slot_type, slot_color, 'slot type')
		#BodyMap.Slot.keys()[strand.slot]
		if current_strand.left != null:
			skill.frame = 0
			dna_skill.show()
			if slot_color:
				dna_skill.modulate = slot_color
		else:
			skill.frame = 1
			dna_skill.hide()
		if current_strand.right != null:
			vanity.frame = 0
			dna_vanity.show()
			if slot_color:
				dna_vanity.modulate = slot_color
		else:
			vanity.frame = 1
			dna_vanity.hide()
		
