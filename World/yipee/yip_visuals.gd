class_name YipBody extends Node2D

@onready var body_parts: Node2D = $"."

@onready var feet: Sprite2D = $Feet
@onready var body: Sprite2D = $Body
@onready var wings: Sprite2D = $Wings
@onready var tail: Sprite2D = $Tail
@onready var head: Sprite2D = $Head
@onready var misc: Sprite2D = $Misc
@onready var ears: Sprite2D = $Ears
@onready var mouth: Sprite2D = $Mouth
@onready var eyes: Sprite2D = $Eyes

var _part_sprites: Dictionary

var main_color : Color
var size_mult : float = 1.0

func _ready() -> void:
	_part_sprites = {
		BodyMap.Part.FEET: feet,
		BodyMap.Part.BODY: body,
		BodyMap.Part.WINGS: wings,
		BodyMap.Part.TAIL: tail,
		BodyMap.Part.HEAD: head,
		BodyMap.Part.MISC: misc,
		BodyMap.Part.EARS: ears,
		BodyMap.Part.MOUTH: mouth,
		BodyMap.Part.EYES: eyes,
	}

func apply_helix(helix: Helix) -> void:
	if helix == null:
		return
	var dyes: Array[Color] = []
	
	for strand in helix.strands:
		#check for empty strand
		if strand == null:
			continue
		if strand.right == null:
			continue
		#get right allele
		var right: RightAllele = strand.right
		#assign the body part
		if right.yip_color != Color.WHITE:
			dyes.append(right.yip_color)
		if right.body_target == BodyMap.Part.NONE:
			continue
		if right.body_part != null:
			_part_sprites[right.body_target].texture = right.body_part
	var body_color := Color.WHITE
	if not dyes.is_empty():
		body_color = Color(0, 0, 0)
		for new_color in dyes:
			body_color += new_color
		body_color /= dyes.size()
	_update_color(body_color)


func _update_size(mult : float):
	size_mult = mult
	body_parts.scale *= size_mult

func _update_color(color : Color):
	feet.material.set_shader_parameter("to_color", color)
	feet.material.set_shader_parameter("modulate_color", color)
	body.material.set_shader_parameter("to_color", color)
	body.material.set_shader_parameter("modulate_color", color)
	wings.material.set_shader_parameter("to_color", color)
	wings.material.set_shader_parameter("modulate_color", color)
	tail.material.set_shader_parameter("to_color", color)
	tail.material.set_shader_parameter("modulate_color", color)
	head.material.set_shader_parameter("to_color", color)
	head.material.set_shader_parameter("modulate_color", color)
	misc.material.set_shader_parameter("to_color", color)
	misc.material.set_shader_parameter("modulate_color", color)
	ears.material.set_shader_parameter("to_color", color)
	ears.material.set_shader_parameter("modulate_color", color)
	mouth.material.set_shader_parameter("to_color", color)
	mouth.material.set_shader_parameter("modulate_color", color)
	

func _update_feet(sprite : Texture2D):
	feet.texture = sprite
func _update_body(sprite : Texture2D):
	body.texture = sprite
func _update_wings(sprite : Texture2D):
	wings.texture = sprite
func _update_tail(sprite : Texture2D):
	tail.texture = sprite
func _update_head(sprite : Texture2D):
	head.texture = sprite
func _update_misc(sprite : Texture2D):
	misc.texture = sprite
func _update_ears(sprite : Texture2D):
	ears.texture = sprite
func _update_mouth(sprite : Texture2D):
	mouth.texture = sprite
func _update_eyes(sprite : Texture2D):
	eyes.texture = sprite
