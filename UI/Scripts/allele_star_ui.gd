extends TextureRect

var hovering = false
var current_allele
var allele_data: Allele
const ALELLE_UI = preload("uid://cckwntee1s0l4")
var spawn_pos
@onready var left_line := $"../../../Line2D"
@onready var right_line := $"../../../Line2D2"
@onready var allele_ui_visual := $"../.."

var skill : Sprite2D
var vanity : Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	skill = find_child("SkillIn", true, false)
	vanity = find_child("VanityIn", true, false)


func _on_mouse_entered() -> void:
	allele_ui_visual._cooldown_show()
	left_line.set_point_position(0, skill.global_position)
	right_line.set_point_position(0, vanity.global_position)
	if allele_data == null:
		return
	current_allele.show()


func _on_mouse_exited() -> void:
	allele_ui_visual._allele_show()


func set_allele(allele: Allele, side: String, slot_key: String) -> void:
	allele_data = allele
	if current_allele == null or allele == null:
		return
	current_allele.update_info(allele.allele_name, side, allele.get_tooltip(), slot_key, allele.tier)
