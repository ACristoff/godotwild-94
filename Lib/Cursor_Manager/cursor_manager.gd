extends Node

const CURSOR_SCALE := 3

enum Pointers {
	CURSOR_ARROW, 
	CURSOR_DNA, 
	CURSOR_MONEY, 
	CURSOR_GRABBED, 
	CURSOR_HEART, 
	CURSOR_GRABBABLE,
	CURSOR_POINT, 
	CURSOR_INFO, 
	CURSOR_QUESTION,
	CURSOR_TEXT,
	CURSOR_GO_TO,
	CURSOR_GO_BACK,
	CURSOR_YIP_TO,
	CURSOR_RECYCLE,
	CURSOR_SETTINGS
}

const CURSORS := {
	Pointers.CURSOR_ARROW: {
		"texture": preload("res://UI/Textures/MousePointers1.png"),
		"shape": Input.CURSOR_ARROW,
		"hotspot": Vector2(1, 1),
	},
	Pointers.CURSOR_DNA: {
		"texture": preload("res://UI/Textures/MousePointers2.png"),
		"shape": Input.CURSOR_POINTING_HAND,
		"hotspot": Vector2(7, 2),
	},
	Pointers.CURSOR_MONEY: {
		"texture": preload("res://UI/Textures/MousePointers3.png"),
		"shape": Input.CURSOR_HELP,
		"hotspot": Vector2(8, 5),
	},
	Pointers.CURSOR_GRABBED: {
		"texture": preload("res://UI/Textures/MousePointers4.png"),
		"shape": Input.CURSOR_MOVE,
		"hotspot": Vector2(8, 5),
	},
	Pointers.CURSOR_GRABBABLE: {
		"texture": preload("res://UI/Textures/MousePointers6.png"),
		"shape": Input.CURSOR_DRAG,
		"hotspot": Vector2(8, 5),
	},
	Pointers.CURSOR_TEXT: {
		"texture": preload("res://UI/Textures/MousePointers10.png"),
		"shape": Input.CURSOR_IBEAM,
		"hotspot": Vector2(7, 13),
	},
}

func _ready() -> void:
	for pointer in CURSORS:
		var entry: Dictionary = CURSORS[pointer]
		Input.set_custom_mouse_cursor(_scaled(entry["texture"]), entry["shape"], entry["hotspot"] * CURSOR_SCALE)

func use(pointer: Pointers) -> void:
	Input.set_default_cursor_shape(CURSORS[pointer]["shape"])

func reset() -> void:
	use(Pointers.CURSOR_ARROW)

func _scaled(texture: Texture2D) -> ImageTexture:
	var image := texture.get_image()
	image.resize(image.get_width() * CURSOR_SCALE, image.get_height() * CURSOR_SCALE, Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(image)
