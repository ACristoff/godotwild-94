extends MarginContainer

var ailment_name: String : set = _set_ailment_name
var value: int : set = _set_value

@onready var label: Label = $DamageToolyip/Label
@onready var damage_toolyip: NinePatchRect = $DamageToolyip


func _set_ailment_name(new_name: String) -> void:
	ailment_name = new_name
	if is_node_ready() and TypeColors.colors.has(new_name):
		damage_toolyip.self_modulate = TypeColors.colors[new_name]

func _set_value(new_value: int) -> void:
	value = new_value
	if is_node_ready():
		label.text = str(new_value)
