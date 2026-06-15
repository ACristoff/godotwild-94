extends MarginContainer

var ailment_name : String
var value : int
@onready var label: Label = $DamageToolyip/Label
@onready var damage_toolyip: NinePatchRect = $DamageToolyip

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label.text = str(value)
	match name:
		"FIRE":
			damage_toolyip.self_modulate = TypeColors.colors["FIRE"]
		"POISON":
			damage_toolyip.self_modulate = TypeColors.colors["POISON"]
		"WEB":
			damage_toolyip.self_modulate = TypeColors.colors["WEB"]
		"ICE":
			damage_toolyip.self_modulate = TypeColors.colors["ICE"]
		"ELECTRIC":
			damage_toolyip.self_modulate = TypeColors.colors["ELECTRIC"]
		"BLEED":
			damage_toolyip.self_modulate = TypeColors.colors["BLEED"]
		"HAZED":
			damage_toolyip.self_modulate = TypeColors.colors["HAZED"]
