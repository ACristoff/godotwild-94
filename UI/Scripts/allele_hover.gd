extends Panel

var hovering = false
var current_allele
const ALELLE_UI = preload("uid://cckwntee1s0l4")
var spawn_pos


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var allele = ALELLE_UI.instantiate()
	current_allele = allele
	add_child(allele)
	allele.hide()


func _on_mouse_entered() -> void:
	var screen_size = get_viewport().get_visible_rect().size / 3
	var tt_size = Vector2(107, 22)
	spawn_pos = self.global_position
	current_allele.global_position.y = spawn_pos.y - 25
	current_allele.global_position.x = clamp(current_allele.global_position.x, 0, screen_size.x - tt_size.x)
	current_allele.global_position.y = clamp(current_allele.global_position.y, 0, screen_size.y - tt_size.y)
	current_allele.show()
	current_allele.squish()
	


func _on_mouse_exited() -> void:
	current_allele.hide()
