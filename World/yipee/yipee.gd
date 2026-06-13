class_name Yipee 
extends Node2D

##Base Yipee class.

@export var data: YipeeData

@onready var health: Health = $Health

func _ready() -> void:
	health.setup(data.get_health())
