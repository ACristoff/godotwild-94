extends MarginContainer

var ailment_name: String : set = _set_ailment_name
var value: int : set = _set_value

@onready var label: Label = $HBoxContainer/DamageToolyip2/Label
@onready var damage_toolyip: NinePatchRect = $HBoxContainer/DamageToolyip2
@onready var texture_rect: TextureRect = $HBoxContainer/DamageToolyip3/TextureRect
@onready var damage_toolyip_3: NinePatchRect = $HBoxContainer/DamageToolyip3

func _set_ailment_name(new_name: String) -> void:
	ailment_name = new_name
	if is_node_ready() and TypeColors.colors.has(new_name):
		damage_toolyip.self_modulate = TypeColors.colors[new_name]
		#damage_toolyip_3.self_modulate = TypeColors.colors[new_name]
		print(new_name)
		if not TypeColors.icons.has(new_name):
			return
		texture_rect.texture = load(TypeColors.icons[new_name])
func _set_value(new_value: int) -> void:
	value = new_value
	if is_node_ready():
		label.text = str(new_value)
