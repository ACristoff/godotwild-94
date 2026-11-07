class_name AlllelePip extends TextureRect

var hovering = false
var current_strand: Strand
#var allele_data: Allele
#const ALELLE_UI = preload("uid://cckwntee1s0l4")
var spawn_pos
@onready var left_line := $"../../../../Line2D"
@onready var right_line := $"../../../../Line2D2"
@onready var type_dmg_l: TextureRect = $"../../AlleleInformation/MarginContainer/HBoxContainer/RightAlelle/TypeDmg"
@onready var type_dmg_r: TextureRect = $"../../AlleleInformation/MarginContainer/HBoxContainer/LeftAlelle/TypeDmg"
@onready var name_l: NinePatchRect = $"../../AlleleInformation/MarginContainer/HBoxContainer/LeftAlelle/MarginContainer2/Name"
@onready var name_r: NinePatchRect = $"../../AlleleInformation/MarginContainer/HBoxContainer/RightAlelle/MarginContainer2/NameText"
@onready var allele_ui_visual := $"../.."

var skill : Sprite2D
var vanity : Sprite2D
var dna_skill : TextureRect
var dna_vanity : TextureRect
var focus_r : Sprite2D
var focus_l : Sprite2D
var rotate_speed : float
var rotate_dir : bool = false

signal strand_hovered

const SLOT_COLORS := {
	BodyMap.Slot.HEALTH:         "779422",
	BodyMap.Slot.HEALTH_AUGMENT: "0eb56d",
	BodyMap.Slot.ATTACK:         "9c2424",
	BodyMap.Slot.ATTACK_AUGMENT: "d14830",
	BodyMap.Slot.COOLDOWN:       "5662cc",
	BodyMap.Slot.SPECIALIZATION: "cc4bae",
	BodyMap.Slot.BREED_AUGMENT:  "784bcc",
	BodyMap.Slot.NONE:           "3d3d3d",
}
const SLOT_ICONS := {
	BodyMap.Slot.HEALTH:         "res://UI/Textures/ui_effecticons/heal_icon.png",
	BodyMap.Slot.HEALTH_AUGMENT: "res://UI/Textures/ui_effecticons/heal_aug.png",
	BodyMap.Slot.ATTACK:         "res://UI/Textures/ui_effecticons/attack_icon.png",
	BodyMap.Slot.ATTACK_AUGMENT: "res://UI/Textures/ui_effecticons/attack_aug_icon.png",
	BodyMap.Slot.COOLDOWN:       "res://UI/Textures/ui_effecticons/haste_icon.png",
	BodyMap.Slot.SPECIALIZATION: "res://UI/Textures/ui_effecticons/null_icon.png",
	BodyMap.Slot.BREED_AUGMENT:  "res://UI/Textures/ui_effecticons/breed_icon.png",
	BodyMap.Slot.NONE:           "res://UI/Textures/ui_effecticons/null_icon.png",
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rotate_speed = randf_range(0.7, 0.9)
	rotate_dir = randi() % 2 == 1
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	skill = find_child("SkillIn", true, false)
	vanity = find_child("VanityIn", true, false)
	dna_skill = find_child("DnaSkill", true, false)
	dna_vanity = find_child("DnaVanity", true, false)
	focus_l = find_child("DnaFocusLight_L", true, false)
	focus_r = find_child("DnaFocusLight_R", true, false)
	focus_l.hide()
	focus_r.hide()

func _process(_delta: float) -> void:
	if rotate_dir:
		focus_l.rotation_degrees += rotate_speed
		focus_r.rotation_degrees += rotate_speed
	else:
		focus_l.rotation_degrees -= rotate_speed
		focus_r.rotation_degrees -= rotate_speed

func _on_mouse_entered() -> void:
	allele_ui_visual._cooldown_show()
	left_line.set_point_position(0, skill.global_position)
	right_line.set_point_position(0, vanity.global_position)
	#TODO
	if current_strand == null:
		strand_hovered.emit(current_strand)
		type_dmg_r.texture = null
		type_dmg_l.texture = null
		name_r.modulate = Color(1.0, 1.0, 1.0, 1.0)
		name_l.modulate = Color(1.0, 1.0, 1.0, 1.0)
		dna_skill.hide()
		dna_vanity.hide()
		return
	else:
		strand_hovered.emit(current_strand)
		#if current_strand != null:
		var slot_type = current_strand.slot
		var slot_color = SLOT_COLORS[current_strand.slot]
		var slot_icon = SLOT_ICONS[current_strand.slot]
		print(slot_type, slot_color, 'slot type')
		#BodyMap.Slot.keys()[strand.slot]
		if current_strand != null:
			if current_strand.left != null:
				if slot_color:
					type_dmg_r.texture = load(slot_icon)
					name_l.modulate = slot_color
			else:
				type_dmg_r.texture = null
				name_l.modulate = Color(1.0, 1.0, 1.0, 1.0)
			if current_strand.right != null:
				if slot_color:
					type_dmg_l.texture = load(slot_icon)
					name_r.modulate = slot_color
			else:
				type_dmg_l.texture = null
				name_r.modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			type_dmg_r.texture = null
			type_dmg_l.texture = null
			name_r.modulate = Color(1.0, 1.0, 1.0, 1.0)
			name_l.modulate = Color(1.0, 1.0, 1.0, 1.0)


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
		#var slot_icon = SLOT_ICONS[current_strand.slot]
		print(slot_type, slot_color, 'slot type')
		#BodyMap.Slot.keys()[strand.slot]
		if current_strand.left != null:
			skill.frame = 0
			dna_skill.show()
			focus_l.show()
			if slot_color:
				dna_skill.modulate = slot_color
				focus_l.modulate = slot_color
				#type_dmg_r.texture = load(slot_icon)
				#name_l.modulate = slot_color
		else:
			skill.frame = 1
			dna_skill.hide()
			focus_l.hide()
			#type_dmg_l.texture = null
			#name_l.modulate = Color(1.0, 1.0, 1.0, 1.0)
		if current_strand.right != null:
			vanity.frame = 0
			dna_vanity.show()
			focus_r.show()
			if slot_color:
				dna_vanity.modulate = slot_color
				focus_r.modulate = slot_color
				#type_dmg_l.texture = load(slot_icon)
				#name_r.modulate = slot_color
		else:
			vanity.frame = 1
			dna_vanity.hide()
			focus_r.hide()
			#type_dmg_r.texture = null
			#name_r.modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		focus_r.hide()
		focus_l.hide()
		#type_dmg_r.texture = null
		#type_dmg_l.texture = null
		#name_r.modulate = Color(1.0, 1.0, 1.0, 1.0)
		#name_l.modulate = Color(1.0, 1.0, 1.0, 1.0)
